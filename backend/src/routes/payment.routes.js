const express = require('express');
const router = express.Router();
const Transaction = require('../models/Transaction');
const GeneratedContract = require('../models/GeneratedContract');
const Template = require('../models/Template');
const User = require('../models/User');
const { verifyToken } = require('../middleware/auth');
const paymobService = require('../services/paymob.service');

// 1. Get Public Paymob Configuration (Environment, Public Keys, Test Data)
router.get('/paymob/config', (req, res) => {
  res.json({
    env: paymobService.config.env,
    isLive: paymobService.config.isLive,
    currency: paymobService.config.currency,
    publicKey: paymobService.config.publicKey,
    cardIntegrationId: paymobService.config.cardIntegrationId,
    walletIntegrationId: paymobService.config.walletIntegrationId,
    iframeId: paymobService.config.iframeId,
    testCard: paymobService.config.testCard,
    testWallet: paymobService.config.testWallet
  });
});

// 2. Initiate Paymob Payment Order & Payment Key
router.post('/paymob/initiate', verifyToken, async (req, res) => {
  try {
    const { 
      amount, 
      type = 'contract', // 'contract' | 'consultation' | 'topup'
      title = 'خدمة قانونية',
      paymentMethod = 'card', // 'card' | 'wallet'
      contractId
    } = req.body;

    if (!amount || Number(amount) <= 0) {
      return res.status(400).json({ error: 'المبلغ غير صالح للعملية' });
    }

    const merchantOrderId = `OQOODY-${type.toUpperCase()}-${Date.now()}`;
    const integrationId = (paymentMethod === 'wallet' && paymobService.config.walletIntegrationId)
      ? paymobService.config.walletIntegrationId 
      : paymobService.config.cardIntegrationId;

    // Step A: Paymob Auth
    const authToken = await paymobService.authenticate();

    // Step B: Paymob Order
    const order = await paymobService.createOrder({
      authToken,
      amount: Number(amount),
      merchantOrderId,
      items: [
        {
          name: title,
          amount_cents: Math.round(Number(amount) * 100),
          description: `سداد رسوم ${title} عبر منصة عقودي`,
          quantity: '1'
        }
      ]
    });

    // Step C: Paymob Payment Key
    const billingData = {
      firstName: req.user.fullName ? req.user.fullName.split(' ')[0] : 'عميل',
      lastName: req.user.fullName ? req.user.fullName.split(' ').slice(1).join(' ') || 'عقودي' : 'عقودي',
      email: req.user.email || 'client@oqoody.com',
      phone: req.user.phone || '+201000000000',
      city: req.user.city || 'Cairo'
    };

    const paymentToken = await paymobService.generatePaymentKey({
      authToken,
      amount: Number(amount),
      orderId: order.id,
      integrationId,
      billingData
    });

    const iframeUrl = paymobService.getIframeUrl(paymentToken);

    res.json({
      success: true,
      paymentToken,
      orderId: order.id,
      merchantOrderId,
      amount: Number(amount),
      currency: paymobService.config.currency,
      iframeUrl,
      env: paymobService.config.env,
      isLive: paymobService.config.isLive
    });
  } catch (err) {
    console.error('[Paymob Initiate Error]:', err);
    res.status(500).json({ error: err.message || 'فشل تجهيز عملية الدفع عبر باي موب' });
  }
});

// 3. Process Card or Mobile Wallet Payment & Record in MongoDB
router.post('/paymob/process', verifyToken, async (req, res) => {
  try {
    const {
      paymentToken,
      orderId,
      paymentMethod = 'card', // 'card' | 'wallet'
      cardData,
      walletNumber,
      amount,
      contractData, // { templateId, contractType, filledVariables, assignedLawyerId }
      description
    } = req.body;

    if (!paymentToken) {
      return res.status(400).json({ error: 'رمز الدفع (Payment Token) مطلوب' });
    }

    let payResult;
    if (paymentMethod === 'card') {
      if (!cardData || !cardData.cardNumber || !cardData.cvv) {
        return res.status(400).json({ error: 'بيانات البطاقة البنكية غير مكتملة' });
      }
      payResult = await paymobService.payWithCard({ paymentToken, cardData });
    } else if (paymentMethod === 'wallet') {
      if (!walletNumber) {
        return res.status(400).json({ error: 'رقم المحفظة الإلكترونية مطلوب' });
      }
      payResult = await paymobService.payWithWallet({ paymentToken, walletNumber });
    } else {
      return res.status(400).json({ error: 'وسيلة الدفع غير مدعومة' });
    }

    if (!payResult.success) {
      return res.status(400).json({
        success: false,
        error: payResult.error || 'تم رفض العملية من البنك أو بوابة باي موب. يرجى التحقق من بيانات الدفع.'
      });
    }

    const paymobTxId = String(payResult.id || `PMB-${Date.now()}`);
    const paymobOrdId = String(orderId || `ORD-${Date.now()}`);

    // Record the Payment Transaction in MongoDB
    const transaction = await Transaction.create({
      userId: req.user._id,
      type: 'contract_fee',
      amount: Number(amount || 0),
      currency: paymobService.config.currency,
      status: 'completed',
      description: description || `دفع رسوم عقد عبر باي موب (${paymentMethod === 'card' ? 'بطاقة بنكية' : 'محفظة'})`,
      referenceId: paymobTxId,
      paymentGateway: 'paymob',
      paymobTransactionId: paymobTxId,
      paymobOrderId: paymobOrdId,
      paymentMethod,
      isLive: paymobService.config.isLive,
      paymobResponse: payResult.data || {}
    });

    let generatedContract = null;

    // If contractData is supplied, automatically generate/confirm the contract as PAID!
    if (contractData && contractData.templateId) {
      const template = await Template.findById(contractData.templateId);
      if (template) {
        let renderedContent = template.content;
        const filled = contractData.filledVariables || {};
        for (const [key, value] of Object.entries(filled)) {
          const regex = new RegExp(`\\{\\{${key}\\}\\}`, 'g');
          renderedContent = renderedContent.replace(regex, String(value || ''));
        }

        generatedContract = await GeneratedContract.create({
          templateId: template._id,
          clientId: req.user._id,
          assignedLawyerId: contractData.assignedLawyerId || null,
          contractType: contractData.contractType || 'instant',
          title: template.title,
          filledVariables: filled,
          renderedContent,
          status: contractData.contractType === 'lawyer_review' ? 'pending_review' : 'completed',
          price: Number(amount || template.autoGeneratePrice),
          paymentStatus: 'paid',
          paymentGateway: 'paymob',
          paymobOrderId: paymobOrdId,
          paymobTransactionId: paymobTxId,
          transactionId: transaction._id
        });

        generatedContract = await GeneratedContract.findById(generatedContract._id)
          .populate('templateId', 'title category')
          .populate('clientId', 'fullName phone email')
          .populate('assignedLawyerId', 'fullName phone email');
      }
    }

    res.json({
      success: true,
      message: 'تم تأكيد الدفع الإلكتروني بنجاح واكتمال المعاملة عبر باي موب',
      transactionId: transaction._id,
      paymobTransactionId: paymobTxId,
      paymobOrderId: paymobOrdId,
      paymentMethod,
      amount: Number(amount || 0),
      isLive: paymobService.config.isLive,
      contract: generatedContract,
      redirectionUrl: payResult.redirection_url || null
    });
  } catch (err) {
    console.error('[Paymob Process Error]:', err);
    res.status(500).json({ error: err.message || 'فشل معالجة الدفع عبر باي موب' });
  }
});

// 4. Paymob Webhook / Callback Handler with HMAC Signature Verification
router.post('/paymob/webhook', async (req, res) => {
  try {
    const hmacHeader = req.query.hmac || req.headers['x-paymob-hmac'] || '';
    const transactionObj = req.body.obj || req.body;

    if (!transactionObj) {
      return res.status(400).send('No payload');
    }

    // Verify HMAC
    const isValid = paymobService.verifyHmac(transactionObj, hmacHeader);
    if (!isValid) {
      console.warn('[Paymob Webhook] Invalid HMAC signature received');
      return res.status(403).json({ error: 'Invalid HMAC signature' });
    }

    const paymobTxId = String(transactionObj.id);
    const paymobOrderId = String(transactionObj.order ? (transactionObj.order.id || transactionObj.order) : '');
    const isSuccess = transactionObj.success === true;
    const amountEgp = (transactionObj.amount_cents || 0) / 100;

    console.log(`[Paymob Webhook] Tx: ${paymobTxId}, Order: ${paymobOrderId}, Success: ${isSuccess}, Amount: ${amountEgp}`);

    // Update existing transaction or record new
    let transaction = await Transaction.findOne({ paymobTransactionId: paymobTxId });
    if (!transaction) {
      // Find user if available
      let userId = null;
      if (transactionObj.order && transactionObj.order.merchant_order_id) {
        const contract = await GeneratedContract.findOne({ paymobOrderId });
        if (contract) userId = contract.clientId;
      }

      transaction = await Transaction.create({
        userId: userId || '000000000000000000000000',
        type: 'contract_fee',
        amount: amountEgp,
        currency: transactionObj.currency || 'EGP',
        status: isSuccess ? 'completed' : 'failed',
        description: `إشعار تلقائي من باي موب (Webhook) - معاملة رقم ${paymobTxId}`,
        referenceId: paymobTxId,
        paymentGateway: 'paymob',
        paymobTransactionId: paymobTxId,
        paymobOrderId: paymobOrderId,
        paymentMethod: transactionObj.source_data ? (transactionObj.source_data.type || 'card') : 'card',
        isLive: paymobService.config.isLive,
        paymobResponse: transactionObj
      });
    } else {
      transaction.status = isSuccess ? 'completed' : 'failed';
      transaction.paymobResponse = transactionObj;
      await transaction.save();
    }

    // Update contract if associated
    if (isSuccess && paymobOrderId) {
      await GeneratedContract.updateMany(
        { paymobOrderId },
        { 
          $set: { 
            paymentStatus: 'paid',
            paymobTransactionId: paymobTxId,
            transactionId: transaction._id
          } 
        }
      );
    }

    res.status(200).json({ received: true });
  } catch (err) {
    console.error('[Paymob Webhook Error]:', err);
    res.status(500).json({ error: err.message });
  }
});

// 5. Get Payment Transactions from MongoDB
router.get('/transactions', verifyToken, async (req, res) => {
  try {
    const isSuperAdmin = req.user.role === 'super_admin';
    const filter = isSuperAdmin ? {} : { userId: req.user._id };

    const transactions = await Transaction.find(filter)
      .populate('userId', 'fullName phone email role')
      .sort({ createdAt: -1 })
      .limit(100);

    res.json(transactions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 6. Legacy / Fallback Mock Checkout
router.post('/mock-checkout', verifyToken, async (req, res) => {
  try {
    const { type, amount, referenceId, description, paymentMethod = 'credit_card' } = req.body;

    if (!amount || amount <= 0) {
      return res.status(400).json({ error: 'المبلغ غير صالح للعملية' });
    }

    const txTypeMap = {
      contract: 'contract_fee',
      consultation: 'consultation_fee',
      escrow: 'escrow_deposit',
      topup: 'wallet_topup'
    };

    const txType = txTypeMap[type] || 'contract_fee';

    const transaction = await Transaction.create({
      userId: req.user._id,
      type: txType,
      amount: Number(amount),
      status: 'completed',
      description: description || `عملية دفع ناجحة عبر ${paymentMethod}`,
      referenceId: referenceId || `PAY-${Date.now()}`,
      paymentGateway: 'paymob',
      isLive: paymobService.config.isLive
    });

    res.json({
      success: true,
      transactionId: transaction._id,
      amount: Number(amount),
      paymentMethod,
      timestamp: transaction.createdAt,
      message: 'تم تأكيد الدفع الإلكتروني بنجاح'
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

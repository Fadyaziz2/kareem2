const express = require('express');
const router = express.Router();
const Transaction = require('../models/Transaction');
const User = require('../models/User');
const { verifyToken } = require('../middleware/auth');

// Instant Mock Payment Processor
router.post('/mock-checkout', verifyToken, async (req, res) => {
  try {
    const { 
      type, // 'contract' | 'consultation' | 'escrow' | 'topup'
      amount, 
      referenceId, 
      description,
      paymentMethod = 'credit_card' // 'credit_card' | 'fawry' | 'wallet'
    } = req.body;

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

    // If topup, credit the wallet
    if (type === 'topup') {
      await User.findByIdAndUpdate(req.user._id, {
        $inc: { walletBalance: Number(amount) }
      });
    }

    // Record the transaction
    const transaction = await Transaction.create({
      userId: req.user._id,
      type: txType,
      amount: Number(amount),
      status: 'completed',
      description: description || `عملية دفع ${type} ناجحة عبر ${paymentMethod}`,
      referenceId: referenceId || `MOCK-PAY-${Date.now()}`
    });

    res.json({
      success: true,
      transactionId: transaction._id,
      amount: Number(amount),
      paymentMethod,
      timestamp: transaction.createdAt,
      message: 'تم تأكيد الدفع الإلكتروني بنجاح واكتمال المعاملة فورياً'
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;


const express = require('express');
const router = express.Router();
const Transaction = require('../models/Transaction');
const WithdrawalRequest = require('../models/WithdrawalRequest');
const User = require('../models/User');
const Escrow = require('../models/Escrow');
const { verifyToken } = require('../middleware/auth');

// Get wallet balance and transactions
router.get('/transactions', verifyToken, async (req, res) => {
  try {
    const transactions = await Transaction.find({ userId: req.user._id })
      .sort({ createdAt: -1 });

    const user = await User.findById(req.user._id).select('walletBalance');

    // Calculate held escrow amount for this user
    const escrows = await Escrow.find({
      $or: [{ partyA: req.user._id }, { partyB: req.user._id }],
      status: { $in: ['active', 'disputed'] }
    });

    let heldBalance = 0;
    escrows.forEach(e => {
      e.milestones.forEach(m => {
        if (m.status === 'held_in_escrow' || m.status === 'submitted' || m.status === 'disputed') {
          heldBalance += m.amount;
        }
      });
    });

    res.json({
      walletBalance: user ? user.walletBalance : 0,
      heldBalance,
      transactions
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Mock wallet top-up
router.post('/topup', verifyToken, async (req, res) => {
  try {
    const { amount } = req.body;
    if (!amount || amount <= 0) {
      return res.status(400).json({ error: 'يرجى إدخال مبلغ صحيح للشحن' });
    }

    const user = await User.findByIdAndUpdate(
      req.user._id,
      { $inc: { walletBalance: Number(amount) } },
      { new: true }
    );

    const transaction = await Transaction.create({
      userId: req.user._id,
      type: 'wallet_topup',
      amount: Number(amount),
      status: 'completed',
      description: `شحن فوري لرصيد المحفظة عبر الدفع الإلكتروني`,
      referenceId: `TOPUP-${Date.now()}`
    });

    res.json({
      message: 'تم شحن المحفظة بنجاح',
      walletBalance: user.walletBalance,
      transaction
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Request withdrawal (Lawyers)
router.post('/withdraw', verifyToken, async (req, res) => {
  try {
    const { amount, bankName, iban, accountHolder } = req.body;
    if (!amount || amount <= 0) {
      return res.status(400).json({ error: 'المبلغ غير صالح للسحب' });
    }

    const user = await User.findById(req.user._id);
    if (!user || user.walletBalance < amount) {
      return res.status(400).json({ error: 'الرصيد المتاح في المحفظة لا يكفي لإتمام طلب السحب' });
    }

    // Deduct from wallet balance
    user.walletBalance -= Number(amount);
    await user.save();

    const request = await WithdrawalRequest.create({
      lawyerId: req.user._id,
      amount: Number(amount),
      bankName,
      iban,
      accountHolder: accountHolder || user.fullName,
      status: 'pending'
    });

    await Transaction.create({
      userId: req.user._id,
      type: 'withdrawal',
      amount: Number(amount),
      status: 'pending',
      description: `طلب سحب أرباح بنكي إلى ${bankName} (${iban.slice(-6)})`,
      referenceId: request._id.toString()
    });

    res.status(201).json({
      message: 'تم تسجيل طلب السحب وجاري مراجعته والتحويل لحسابك البنكي',
      withdrawalRequest: request,
      walletBalance: user.walletBalance
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;


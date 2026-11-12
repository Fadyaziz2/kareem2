const express = require('express');
const router = express.Router();
const Lawyer = require('../models/Lawyer');
const User = require('../models/User');

// Get lawyers with filter (if status query is passed, e.g. ?status=all, return all)
router.get('/', async (req, res) => {
  try {
    const { status } = req.query;
    const filter = (status && status !== 'all') ? { verificationStatus: status } : (status === 'all' ? {} : { verificationStatus: 'approved' });
    const list = await Lawyer.find(filter).populate('userId', 'fullName phone email city isVerified');
    res.json(list);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// Admin verify/reject lawyer
router.patch('/:id/verify', async (req, res) => {
  try {
    const { verificationStatus, rejectionReason, commissionRate } = req.body;
    const updateData = {};
    if (verificationStatus) updateData.verificationStatus = verificationStatus;
    if (rejectionReason !== undefined) updateData.rejectionReason = rejectionReason;
    if (commissionRate !== undefined) updateData.commissionRate = commissionRate;

    const lawyer = await Lawyer.findByIdAndUpdate(req.params.id, updateData, { new: true })
      .populate('userId', 'fullName phone email city isVerified');

    if (!lawyer) return res.status(404).json({ error: 'المحامي غير موجود' });

    if (verificationStatus === 'approved' && lawyer.userId) {
      await User.findByIdAndUpdate(lawyer.userId._id, { isVerified: true });
    }

    res.json({ message: 'تم تحديث حالة اعتماد المحامي بنجاح', lawyer });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;

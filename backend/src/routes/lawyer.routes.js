const express = require('express');
const router = express.Router();
const Lawyer = require('../models/Lawyer');
const User = require('../models/User');

// Get lawyers with search, specialization, and status filters
router.get('/', async (req, res) => {
  try {
    const { status, search, degree, specialization } = req.query;
    const filter = (status && status !== 'all') 
      ? { verificationStatus: status } 
      : (status === 'all' ? {} : { verificationStatus: 'approved' });

    if (degree && degree !== 'all') {
      filter.degree = degree;
    }
    if (specialization && specialization !== 'all') {
      filter.specializations = { $in: [specialization] };
    }

    let query = Lawyer.find(filter).populate('userId', 'fullName phone email city isVerified');

    const lawyers = await query.exec();

    // If search text provided, filter by populated user fullName or barNumber
    let filtered = lawyers;
    if (search) {
      const q = search.toLowerCase();
      filtered = lawyers.filter(l => 
        (l.userId && l.userId.fullName && l.userId.fullName.toLowerCase().includes(q)) ||
        (l.barNumber && l.barNumber.toLowerCase().includes(q)) ||
        (l.specializations && l.specializations.some(s => s.toLowerCase().includes(q)))
      );
    }

    res.json(filtered);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get single lawyer profile
router.get('/:id', async (req, res) => {
  try {
    const lawyer = await Lawyer.findById(req.params.id).populate('userId', 'fullName phone email city isVerified');
    if (!lawyer) {
      // also check if id was userId
      const byUser = await Lawyer.findOne({ userId: req.params.id }).populate('userId', 'fullName phone email city isVerified');
      if (byUser) return res.json(byUser);
      return res.status(404).json({ error: 'المحامي غير موجود' });
    }
    res.json(lawyer);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Admin verify/reject lawyer
router.patch('/:id/verify', async (req, res) => {
  try {
    const { verificationStatus, rejectionReason, commissionRate } = req.body;
    const updateData = {};
    if (verificationStatus) updateData.verificationStatus = verificationStatus;
    if (rejectionReason !== undefined) updateData.rejectionReason = rejectionReason;
    if (commissionRate !== undefined) updateData.commissionRate = Number(commissionRate);

    const lawyer = await Lawyer.findByIdAndUpdate(req.params.id, updateData, { new: true })
      .populate('userId', 'fullName phone email city isVerified');

    if (!lawyer) return res.status(404).json({ error: 'المحامي غير موجود' });

    if (verificationStatus === 'approved' && lawyer.userId) {
      await User.findByIdAndUpdate(lawyer.userId._id, { isVerified: true });
    }

    res.json({ message: 'تم تحديث حالة اعتماد المحامي بنجاح', lawyer });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Lawyer = require('../models/Lawyer');
const Escrow = require('../models/Escrow');
const Dispute = require('../models/Dispute');

router.get('/dashboard-stats', async (req, res) => {
  try {
    res.json({
      totalUsers: await User.countDocuments(),
      approvedLawyers: await Lawyer.countDocuments({ verificationStatus: 'approved' }),
      pendingLawyers: await Lawyer.countDocuments({ verificationStatus: 'pending' }),
      activeEscrows: await Escrow.countDocuments({ status: 'active' }),
      openDisputes: await Dispute.countDocuments({ status: { $in: ['open', 'under_investigation'] } })
    });
  } catch (err) { res.status(500).json({ error: err.message }); }
});
module.exports = router;

const express = require('express');
const router = express.Router();
const Dispute = require('../models/Dispute');
const Escrow = require('../models/Escrow');
const User = require('../models/User');

router.get('/', async (req, res) => {
  try {
    const disputes = await Dispute.find()
      .populate({
        path: 'escrowId',
        populate: [
          { path: 'partyA', select: 'fullName phone email walletBalance' },
          { path: 'partyB', select: 'fullName phone email walletBalance' }
        ]
      })
      .populate('raisedBy', 'fullName phone email role')
      .populate('arbitrationVerdict.decidedBy', 'fullName')
      .sort({ createdAt: -1 });
    res.json(disputes);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

router.post('/', async (req, res) => {
  try {
    const { escrowId, milestoneId, raisedBy, reason, details, priority, evidenceFiles } = req.body;
    const escrow = await Escrow.findById(escrowId);
    if (escrow) {
      const ms = escrow.milestones.id(milestoneId);
      if (ms) ms.status = 'disputed';
      escrow.status = 'disputed';
      await escrow.save();
    }
    const dispute = await Dispute.create({
      escrowId,
      milestoneId,
      raisedBy,
      reason,
      details,
      priority: priority || 'high',
      evidenceFiles: evidenceFiles || []
    });
    res.status(201).json(dispute);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// Arbitration Executive Ruling Endpoint
router.patch('/:id/resolve', async (req, res) => {
  try {
    const { resolutionType, splitPartyA, splitPartyB, notes, decidedBy } = req.body;
    const dispute = await Dispute.findById(req.params.id);
    if (!dispute) return res.status(404).json({ error: 'ملف النزاع غير موجود' });

    const escrow = await Escrow.findById(dispute.escrowId);
    if (!escrow) return res.status(404).json({ error: 'عقد الضمان المرتبط غير موجود' });

    const milestone = escrow.milestones.id(dispute.milestoneId);
    const amount = milestone ? milestone.amount : 0;

    let refundA = 0;
    let releaseB = 0;

    if (resolutionType === 'full_refund_partyA') {
      refundA = amount;
      releaseB = 0;
    } else if (resolutionType === 'full_release_partyB') {
      refundA = 0;
      releaseB = amount;
    } else if (resolutionType === 'custom_split') {
      refundA = splitPartyA ?? 0;
      releaseB = splitPartyB ?? 0;
    }

    // Update Wallets
    if (refundA > 0 && escrow.partyA) {
      await User.findByIdAndUpdate(escrow.partyA, { $inc: { walletBalance: refundA } });
    }
    if (releaseB > 0 && escrow.partyB) {
      await User.findByIdAndUpdate(escrow.partyB, { $inc: { walletBalance: releaseB } });
    }

    // Update Milestone & Escrow
    if (milestone) {
      milestone.status = 'released';
    }
    escrow.status = 'active';
    await escrow.save();

    // Update Dispute
    dispute.status = 'resolved';
    dispute.arbitrationVerdict = {
      resolutionType,
      splitPartyA: refundA,
      splitPartyB: releaseB,
      notes,
      decidedBy: decidedBy || null,
      decidedAt: new Date()
    };
    await dispute.save();

    res.json({
      message: 'تم إصدار الحكم التحكيمي وتحديث الأرصدة وحالة الضمان بنجاح',
      dispute,
      escrow
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

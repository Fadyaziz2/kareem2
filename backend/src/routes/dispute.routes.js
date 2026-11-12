const express = require('express');
const router = express.Router();
const Dispute = require('../models/Dispute');
const Escrow = require('../models/Escrow');
const User = require('../models/User');
const Transaction = require('../models/Transaction');
const { verifyToken, optionalAuth } = require('../middleware/auth');

// Get all disputes
router.get('/', optionalAuth, async (req, res) => {
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
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get single dispute
router.get('/:id', optionalAuth, async (req, res) => {
  try {
    const dispute = await Dispute.findById(req.params.id)
      .populate({
        path: 'escrowId',
        populate: [
          { path: 'partyA', select: 'fullName phone email walletBalance' },
          { path: 'partyB', select: 'fullName phone email walletBalance' },
          { path: 'linkedContractId', select: 'title renderedContent' }
        ]
      })
      .populate('raisedBy', 'fullName phone email role')
      .populate('arbitrationVerdict.decidedBy', 'fullName');

    if (!dispute) {
      return res.status(404).json({ error: 'ملف النزاع غير موجود' });
    }
    res.json(dispute);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Raise Dispute (Freezes funds immediately)
router.post('/', verifyToken, async (req, res) => {
  try {
    const { escrowId, milestoneId, reason, details, priority = 'urgent', evidenceFiles } = req.body;

    const escrow = await Escrow.findById(escrowId);
    if (!escrow) {
      return res.status(404).json({ error: 'عقد الضمان غير موجود' });
    }

    if (milestoneId) {
      const ms = escrow.milestones.id(milestoneId);
      if (ms) ms.status = 'disputed';
    }
    escrow.status = 'disputed';
    await escrow.save();

    const dispute = await Dispute.create({
      escrowId,
      milestoneId,
      raisedBy: req.user._id,
      reason,
      details,
      priority,
      evidenceFiles: evidenceFiles || [],
      status: 'open'
    });

    const populated = await Dispute.findById(dispute._id)
      .populate('escrowId')
      .populate('raisedBy', 'fullName phone email');

    res.status(201).json(populated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Arbitration Executive Ruling Endpoint
router.patch('/:id/resolve', optionalAuth, async (req, res) => {
  try {
    const { resolutionType, splitPartyA, splitPartyB, notes, decidedBy } = req.body;
    const dispute = await Dispute.findById(req.params.id);
    if (!dispute) return res.status(404).json({ error: 'ملف النزاع غير موجود' });

    const escrow = await Escrow.findById(dispute.escrowId);
    if (!escrow) return res.status(404).json({ error: 'عقد الضمان المرتبط غير موجود' });

    const milestone = escrow.milestones.id(dispute.milestoneId);
    const amount = milestone ? milestone.amount : escrow.totalAmount;

    let refundA = 0;
    let releaseB = 0;

    if (resolutionType === 'full_refund_partyA') {
      refundA = amount;
      releaseB = 0;
    } else if (resolutionType === 'full_release_partyB') {
      refundA = 0;
      releaseB = amount;
    } else if (resolutionType === 'custom_split') {
      refundA = Number(splitPartyA ?? 0);
      releaseB = Number(splitPartyB ?? 0);
    }

    // Update Wallets & Record Transactions
    if (refundA > 0 && escrow.partyA) {
      await User.findByIdAndUpdate(escrow.partyA, { $inc: { walletBalance: refundA } });
      await Transaction.create({
        userId: escrow.partyA,
        type: 'escrow_refund',
        amount: refundA,
        status: 'completed',
        description: `استرداد تحكيمي لصالح الطرف الأول من نزاع: ${escrow.title}`,
        referenceId: dispute._id.toString()
      });
    }

    if (releaseB > 0 && escrow.partyB) {
      await User.findByIdAndUpdate(escrow.partyB, { $inc: { walletBalance: releaseB } });
      await Transaction.create({
        userId: escrow.partyB,
        type: 'escrow_release',
        amount: releaseB,
        status: 'completed',
        description: `صرف تحكيمي لصالح الطرف الثاني من نزاع: ${escrow.title}`,
        referenceId: dispute._id.toString()
      });
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
      notes: notes || 'تم الفصل وإصدار القرار التحكيمي البات من هيئة الرقابة والتحكيم.',
      decidedBy: req.user ? req.user._id : (decidedBy || null),
      decidedAt: new Date()
    };
    await dispute.save();

    const populated = await Dispute.findById(dispute._id)
      .populate('escrowId')
      .populate('raisedBy', 'fullName phone email')
      .populate('arbitrationVerdict.decidedBy', 'fullName');

    res.json({
      message: 'تم إصدار الحكم التحكيمي وتحديث الأرصدة وحالة الضمان بنجاح',
      dispute: populated,
      escrow
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

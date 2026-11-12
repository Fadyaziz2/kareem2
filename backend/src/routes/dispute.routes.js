const express = require('express');
const router = express.Router();
const Dispute = require('../models/Dispute');
const Escrow = require('../models/Escrow');

router.post('/', async (req, res) => {
  try {
    const { escrowId, milestoneId, raisedBy, reason, details } = req.body;
    const escrow = await Escrow.findById(escrowId);
    if (escrow) {
      const ms = escrow.milestones.id(milestoneId);
      if (ms) ms.status = 'disputed';
      escrow.status = 'disputed';
      await escrow.save();
    }
    const dispute = await Dispute.create({ escrowId, milestoneId, raisedBy, reason, details });
    res.status(201).json(dispute);
  } catch (err) { res.status(500).json({ error: err.message }); }
});
module.exports = router;

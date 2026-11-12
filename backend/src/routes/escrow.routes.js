const express = require('express');
const router = express.Router();
const Escrow = require('../models/Escrow');

router.post('/', async (req, res) => {
  try {
    res.status(201).json(await Escrow.create(req.body));
  } catch (err) { res.status(500).json({ error: err.message }); }
});

router.patch('/:id/milestones/:mId/release', async (req, res) => {
  try {
    const escrow = await Escrow.findById(req.params.id);
    if (!escrow) return res.status(404).json({ error: 'Not found' });
    const ms = escrow.milestones.id(req.params.mId);
    ms.status = 'released';
    await escrow.save();
    res.json({ message: 'تم تحرير الدفعة', escrow });
  } catch (err) { res.status(500).json({ error: err.message }); }
});
module.exports = router;

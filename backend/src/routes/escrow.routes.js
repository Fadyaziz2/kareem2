const express = require('express');
const router = express.Router();
const Escrow = require('../models/Escrow');

router.get('/', async (req, res) => {
  try {
    const list = await Escrow.find()
      .populate('partyA', 'fullName phone email walletBalance')
      .populate('partyB', 'fullName phone email walletBalance')
      .sort({ createdAt: -1 });
    res.json(list);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

router.post('/', async (req, res) => {
  try {
    res.status(201).json(await Escrow.create(req.body));
  } catch (err) { res.status(500).json({ error: err.message }); }
});

router.patch('/:id/milestones/:mId/release', async (req, res) => {
  try {
    const escrow = await Escrow.findById(req.params.id);
    if (!escrow) return res.status(404).json({ error: 'عقد الضمان غير موجود' });
    const ms = escrow.milestones.id(req.params.mId);
    if (!ms) return res.status(404).json({ error: 'الدفعة غير موجودة' });
    ms.status = 'released';
    
    // Check if all milestones are released
    const allReleased = escrow.milestones.every(m => m.status === 'released');
    if (allReleased) {
      escrow.status = 'completed';
    }
    await escrow.save();
    res.json({ message: 'تم تحرير الدفعة بنجاح', escrow });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

router.patch('/:id/freeze', async (req, res) => {
  try {
    const escrow = await Escrow.findById(req.params.id);
    if (!escrow) return res.status(404).json({ error: 'عقد الضمان غير موجود' });
    escrow.status = escrow.status === 'frozen' ? 'active' : 'frozen';
    await escrow.save();
    res.json({ message: escrow.status === 'frozen' ? 'تم تجميد العملية بنجاح' : 'تم إلغاء تجميد العملية', escrow });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;

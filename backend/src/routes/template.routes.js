const express = require('express');
const router = express.Router();
const Template = require('../models/Template');

router.get('/', async (req, res) => {
  try {
    res.json(await Template.find().sort({ createdAt: -1 }));
  } catch (err) { res.status(500).json({ error: err.message }); }
});

router.post('/', async (req, res) => {
  try {
    res.status(201).json(await Template.create(req.body));
  } catch (err) { res.status(500).json({ error: err.message }); }
});

router.put('/:id', async (req, res) => {
  try {
    const updated = await Template.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updated) return res.status(404).json({ error: 'النموذج غير موجود' });
    res.json(updated);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

router.delete('/:id', async (req, res) => {
  try {
    await Template.findByIdAndDelete(req.params.id);
    res.json({ message: 'تم حذف النموذج بنجاح' });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;

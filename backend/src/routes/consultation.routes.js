const express = require('express');
const router = express.Router();
const Consultation = require('../models/Consultation');

router.get('/', async (req, res) => {
  try {
    const list = await Consultation.find()
      .populate('clientId', 'fullName phone email city')
      .populate('lawyerId', 'fullName phone email city')
      .sort({ createdAt: -1 });
    res.json(list);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

router.post('/', async (req, res) => {
  try {
    res.status(201).json(await Consultation.create(req.body));
  } catch (err) { res.status(500).json({ error: err.message }); }
});

router.get('/user/:userId', async (req, res) => {
  try {
    res.json(await Consultation.find({ clientId: req.params.userId }).populate('lawyerId', 'fullName'));
  } catch (err) { res.status(500).json({ error: err.message }); }
});

router.patch('/:id/reassign', async (req, res) => {
  try {
    const { lawyerId } = req.body;
    const consultation = await Consultation.findByIdAndUpdate(
      req.params.id,
      { lawyerId, status: 'in_progress' },
      { new: true }
    ).populate('clientId', 'fullName phone email').populate('lawyerId', 'fullName phone email');
    res.json({ message: 'تم إعادة توجيه الاستشارة بنجاح', consultation });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

router.patch('/:id/status', async (req, res) => {
  try {
    const { status, responseNotes } = req.body;
    const consultation = await Consultation.findByIdAndUpdate(
      req.params.id,
      { ...(status && { status }), ...(responseNotes && { responseNotes }) },
      { new: true }
    );
    res.json(consultation);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;

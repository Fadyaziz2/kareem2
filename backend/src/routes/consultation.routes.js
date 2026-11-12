const express = require('express');
const router = express.Router();
const Consultation = require('../models/Consultation');

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
module.exports = router;

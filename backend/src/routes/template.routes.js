const express = require('express');
const router = express.Router();
const Template = require('../models/Template');

router.get('/', async (req, res) => {
  try {
    res.json(await Template.find());
  } catch (err) { res.status(500).json({ error: err.message }); }
});

router.post('/', async (req, res) => {
  try {
    res.status(201).json(await Template.create(req.body));
  } catch (err) { res.status(500).json({ error: err.message }); }
});
module.exports = router;

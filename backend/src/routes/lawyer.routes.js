const express = require('express');
const router = express.Router();
const Lawyer = require('../models/Lawyer');

router.get('/', async (req, res) => {
  try {
    const list = await Lawyer.find({ verificationStatus: 'approved' }).populate('userId', 'fullName phone email city');
    res.json(list);
  } catch (err) { res.status(500).json({ error: err.message }); }
});
module.exports = router;

const express = require('express');
const router = express.Router();
const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

router.post('/register', async (req, res) => {
  try {
    const { fullName, phone, email, password, role, city } = req.body;
    const exists = await User.findOne({ $or: [{ phone }, { email }] });
    if (exists) return res.status(400).json({ error: 'المستخدم مسجل بالفعل' });
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await User.create({ fullName, phone, email, password: hashedPassword, role, city });
    const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET || 'secret');
    res.status(201).json({ token, user });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

router.post('/login', async (req, res) => {
  try {
    const { emailOrPhone, password } = req.body;
    const user = await User.findOne({ $or: [{ email: emailOrPhone }, { phone: emailOrPhone }] });
    if (!user) return res.status(404).json({ error: 'الحساب غير موجود' });
    const ok = await bcrypt.compare(password, user.password);
    if (!ok) return res.status(401).json({ error: 'كلمة المرور خاطئة' });
    const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET || 'secret');
    res.json({ token, user });
  } catch (err) { res.status(500).json({ error: err.message }); }
});
module.exports = router;

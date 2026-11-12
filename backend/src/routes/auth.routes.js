const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Lawyer = require('../models/Lawyer');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { verifyToken } = require('../middleware/auth');

// Register (Client or Lawyer)
router.post('/register', async (req, res) => {
  try {
    const { 
      fullName, 
      phone, 
      email, 
      password, 
      role = 'client', 
      city = 'القاهرة',
      barNumber,
      degree,
      specializations,
      consultationRate,
      bio
    } = req.body;

    const exists = await User.findOne({ $or: [{ phone }, { email }] });
    if (exists) {
      return res.status(400).json({ error: 'المستخدم مسجل بالفعل بهذا الهاتف أو البريد الإلكتروني' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await User.create({
      fullName,
      phone,
      email,
      password: hashedPassword,
      role: role === 'lawyer' ? 'lawyer' : 'client',
      city,
      isVerified: role !== 'lawyer' // clients verified by default, lawyers pending review
    });

    let lawyerProfile = null;
    if (role === 'lawyer') {
      lawyerProfile = await Lawyer.create({
        userId: user._id,
        barNumber: barNumber || `EGY-BAR-${Math.floor(10000 + Math.random() * 90000)}`,
        degree: degree || 'ابتدائي',
        specializations: Array.isArray(specializations) ? specializations : (specializations ? [specializations] : ['عقود تجارية']),
        consultationRate: consultationRate ? Number(consultationRate) : 250,
        bio: bio || 'محامٍ ومستشار قانوني مقيد بالنقابة.',
        verificationStatus: 'pending'
      });
    }

    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET || 'oqoody_super_secret_2026',
      { expiresIn: '30d' }
    );

    const userObj = user.toObject();
    delete userObj.password;

    res.status(201).json({
      token,
      user: {
        ...userObj,
        lawyerProfile: lawyerProfile || undefined
      }
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Login
router.post('/login', async (req, res) => {
  try {
    const { emailOrPhone, password } = req.body;
    if (!emailOrPhone || !password) {
      return res.status(400).json({ error: 'يرجى إدخال الهاتف أو البريد الإلكتروني وكلمة المرور' });
    }

    const user = await User.findOne({
      $or: [{ email: emailOrPhone.trim() }, { phone: emailOrPhone.trim() }]
    });

    if (!user) {
      return res.status(404).json({ error: 'الحساب غير موجود، يرجى التأكد من البيانات أو إنشاء حساب جديد' });
    }

    const ok = await bcrypt.compare(password, user.password);
    if (!ok) {
      return res.status(401).json({ error: 'كلمة المرور غير صحيحة' });
    }

    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET || 'oqoody_super_secret_2026',
      { expiresIn: '30d' }
    );

    let lawyerProfile = null;
    if (user.role === 'lawyer') {
      lawyerProfile = await Lawyer.findOne({ userId: user._id });
    }

    const userObj = user.toObject();
    delete userObj.password;

    res.json({
      token,
      user: {
        ...userObj,
        lawyerProfile: lawyerProfile || undefined
      }
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get Current User (used by SplashScreen and App Startup)
router.get('/me', verifyToken, async (req, res) => {
  try {
    const user = req.user.toObject();
    let lawyerProfile = null;
    if (user.role === 'lawyer') {
      lawyerProfile = await Lawyer.findOne({ userId: user._id });
    }
    res.json({
      user: {
        ...user,
        lawyerProfile: lawyerProfile || undefined
      }
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update Profile
router.put('/profile', verifyToken, async (req, res) => {
  try {
    const { fullName, city, bio, consultationRate, specializations } = req.body;
    const updateData = {};
    if (fullName) updateData.fullName = fullName;
    if (city) updateData.city = city;

    const updatedUser = await User.findByIdAndUpdate(req.user._id, updateData, { new: true }).select('-password');

    let lawyerProfile = null;
    if (updatedUser.role === 'lawyer') {
      const lawyerUpdate = {};
      if (bio) lawyerUpdate.bio = bio;
      if (consultationRate) lawyerUpdate.consultationRate = Number(consultationRate);
      if (specializations) lawyerUpdate.specializations = specializations;

      lawyerProfile = await Lawyer.findOneAndUpdate({ userId: updatedUser._id }, lawyerUpdate, { new: true });
    }

    res.json({
      message: 'تم تحديث البيانات بنجاح',
      user: {
        ...updatedUser.toObject(),
        lawyerProfile: lawyerProfile || undefined
      }
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

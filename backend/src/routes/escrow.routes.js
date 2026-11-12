const express = require('express');
const router = express.Router();
const Escrow = require('../models/Escrow');
const User = require('../models/User');
const Transaction = require('../models/Transaction');
const { verifyToken, optionalAuth } = require('../middleware/auth');

// Get all escrows (scoped to user if client/lawyer)
router.get('/', optionalAuth, async (req, res) => {
  try {
    const filter = {};
    if (req.user && req.user.role !== 'super_admin' && req.user.role !== 'dispute_agent') {
      filter.$or = [{ partyA: req.user._id }, { partyB: req.user._id }];
    }

    const list = await Escrow.find(filter)
      .populate('partyA', 'fullName phone email walletBalance')
      .populate('partyB', 'fullName phone email walletBalance')
      .populate('linkedContractId', 'title contractType')
      .sort({ createdAt: -1 });

    res.json(list);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get single escrow by ID
router.get('/:id', optionalAuth, async (req, res) => {
  try {
    const escrow = await Escrow.findById(req.params.id)
      .populate('partyA', 'fullName phone email walletBalance')
      .populate('partyB', 'fullName phone email walletBalance')
      .populate('linkedContractId', 'title contractType renderedContent');

    if (!escrow) {
      return res.status(404).json({ error: 'عقد الضمان غير موجود' });
    }
    res.json(escrow);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create Escrow deal
router.post('/', verifyToken, async (req, res) => {
  try {
    const { 
      partyBPhoneOrEmail, 
      partyBId,
      title, 
      description, 
      totalAmount, 
      contractDocument, 
      linkedContractId, 
      milestones 
    } = req.body;

    let targetPartyBId = partyBId;
    if (!targetPartyBId && partyBPhoneOrEmail) {
      const foundUser = await User.findOne({
        $or: [
          { email: partyBPhoneOrEmail.trim() },
          { phone: partyBPhoneOrEmail.trim() }
        ]
      });
      if (foundUser) {
        targetPartyBId = foundUser._id;
      } else {
        // Create an invited user placeholder if not exists
        const newUser = await User.create({
          fullName: 'الطرف الثاني (مدعو)',
          phone: partyBPhoneOrEmail.includes('@') ? `010${Math.floor(10000000 + Math.random() * 90000000)}` : partyBPhoneOrEmail,
          email: partyBPhoneOrEmail.includes('@') ? partyBPhoneOrEmail : `user${Date.now()}@oqoody.com`,
          password: 'temp_password',
          role: 'client'
        });
        targetPartyBId = newUser._id;
      }
    }

    if (!targetPartyBId) {
      return res.status(400).json({ error: 'يرجى تحديد بيانات الطرف الثاني (الهاتف أو البريد)' });
    }

    const calculatedMilestones = (milestones && milestones.length > 0) ? milestones : [
      {
        title: 'المرحلة 1: الدفعة المقدمة وبدء التنفيذ',
        percentage: 30,
        amount: Math.round(totalAmount * 0.3),
        terms: 'تسليم المسودة الأولى والمخطط الأولي للعمل.',
        status: 'held_in_escrow'
      },
      {
        title: 'المرحلة 2: إنجاز 70% من الأعمال',
        percentage: 40,
        amount: Math.round(totalAmount * 0.4),
        terms: 'مراجعة المخرجات واجتياز الفحص الأولي.',
        status: 'held_in_escrow'
      },
      {
        title: 'المرحلة 3: التسليم النهائي والاعتماد',
        percentage: 30,
        amount: Math.round(totalAmount * 0.3),
        terms: 'التسليم الكامل للمشروع ومطابقة المواصفات.',
        status: 'held_in_escrow'
      }
    ];

    const escrow = await Escrow.create({
      partyA: req.user._id,
      partyB: targetPartyBId,
      title,
      description,
      totalAmount,
      contractDocument,
      linkedContractId: linkedContractId || null,
      milestones: calculatedMilestones,
      status: 'active'
    });

    // Record Deposit Transaction
    await Transaction.create({
      userId: req.user._id,
      type: 'escrow_deposit',
      amount: totalAmount,
      status: 'completed',
      description: `إيداع وتأمين قيمة عقد الوساطة بالكامل في حساب الضمان: ${title}`,
      referenceId: escrow._id.toString()
    });

    const populated = await Escrow.findById(escrow._id)
      .populate('partyA', 'fullName phone email')
      .populate('partyB', 'fullName phone email');

    res.status(201).json(populated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Party B submits milestone deliverable
router.patch('/:id/milestones/:mId/submit', verifyToken, async (req, res) => {
  try {
    const { submissionNotes, submissionFiles } = req.body;
    const escrow = await Escrow.findById(req.params.id);
    if (!escrow) return res.status(404).json({ error: 'عقد الضمان غير موجود' });

    const ms = escrow.milestones.id(req.params.mId);
    if (!ms) return res.status(404).json({ error: 'الدفعة غير موجودة' });

    ms.status = 'submitted';
    if (submissionNotes) ms.submissionNotes = submissionNotes;
    if (submissionFiles) ms.submissionFiles = submissionFiles;

    await escrow.save();

    const populated = await Escrow.findById(escrow._id)
      .populate('partyA', 'fullName phone email')
      .populate('partyB', 'fullName phone email');

    res.json({ message: 'تم تسليم مخرج المرحلة وإشعار الطرف الأول للمراجعة والتحرير', escrow: populated });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Party A or Admin confirms & releases milestone funds
router.patch('/:id/milestones/:mId/release', optionalAuth, async (req, res) => {
  try {
    const escrow = await Escrow.findById(req.params.id);
    if (!escrow) return res.status(404).json({ error: 'عقد الضمان غير موجود' });

    const ms = escrow.milestones.id(req.params.mId);
    if (!ms) return res.status(404).json({ error: 'الدفعة غير موجودة' });

    ms.status = 'released';

    // Credit Party B's wallet
    await User.findByIdAndUpdate(escrow.partyB, {
      $inc: { walletBalance: ms.amount }
    });

    // Record release transaction
    await Transaction.create({
      userId: escrow.partyB,
      type: 'escrow_release',
      amount: ms.amount,
      status: 'completed',
      description: `تحرير دفعة (${ms.title}) من وساطة: ${escrow.title}`,
      referenceId: escrow._id.toString()
    });

    // Check if all milestones are released
    const allReleased = escrow.milestones.every(m => m.status === 'released');
    if (allReleased) {
      escrow.status = 'completed';
    }

    await escrow.save();

    const populated = await Escrow.findById(escrow._id)
      .populate('partyA', 'fullName phone email')
      .populate('partyB', 'fullName phone email');

    res.json({ message: 'تم تحرير الدفعة المالية ونقل الرصيد إلى محفظة الطرف الثاني بنجاح', escrow: populated });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Freeze / Unfreeze
router.patch('/:id/freeze', optionalAuth, async (req, res) => {
  try {
    const escrow = await Escrow.findById(req.params.id);
    if (!escrow) return res.status(404).json({ error: 'عقد الضمان غير موجود' });

    escrow.status = escrow.status === 'frozen' ? 'active' : 'frozen';
    await escrow.save();

    res.json({ 
      message: escrow.status === 'frozen' ? 'تم تجميد العملية بالكامل إدارياً' : 'تم فك التجميد واستئناف العملية', 
      escrow 
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

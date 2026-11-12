const express = require('express');
const router = express.Router();
const Consultation = require('../models/Consultation');
const Transaction = require('../models/Transaction');
const { verifyToken, optionalAuth } = require('../middleware/auth');

// Get all consultations (with optional role/user scoping)
router.get('/', optionalAuth, async (req, res) => {
  try {
    const { status, type } = req.query;
    const filter = {};
    if (status && status !== 'all') filter.status = status;
    if (type && type !== 'all') filter.type = type;

    // If logged in as client or lawyer, show user's consultations
    if (req.user && req.user.role === 'client') {
      filter.clientId = req.user._id;
    } else if (req.user && req.user.role === 'lawyer') {
      filter.lawyerId = req.user._id;
    }

    const list = await Consultation.find(filter)
      .populate('clientId', 'fullName phone email city')
      .populate('lawyerId', 'fullName phone email city')
      .populate('messages.sender', 'fullName role')
      .sort({ createdAt: -1 });

    res.json(list);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get single consultation with full chat messages
router.get('/:id', optionalAuth, async (req, res) => {
  try {
    const consultation = await Consultation.findById(req.params.id)
      .populate('clientId', 'fullName phone email city')
      .populate('lawyerId', 'fullName phone email city')
      .populate('messages.sender', 'fullName role');

    if (!consultation) {
      return res.status(404).json({ error: 'الاستشارة غير موجودة' });
    }
    res.json(consultation);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Book a consultation
router.post('/', verifyToken, async (req, res) => {
  try {
    const { lawyerId, type, subject, description, price, attachments } = req.body;

    const consultation = await Consultation.create({
      clientId: req.user._id,
      lawyerId: lawyerId || null,
      type: type || 'written',
      subject,
      description,
      attachments: attachments || [],
      price: price || 250,
      status: 'pending',
      messages: [
        {
          sender: req.user._id,
          text: description,
          attachments: attachments || [],
          timestamp: new Date()
        }
      ]
    });

    // Record transaction
    await Transaction.create({
      userId: req.user._id,
      type: 'consultation_fee',
      amount: price || 250,
      status: 'completed',
      description: `حجز استشارة قانونية (${type}): ${subject}`,
      referenceId: consultation._id.toString()
    });

    const populated = await Consultation.findById(consultation._id)
      .populate('clientId', 'fullName phone email city')
      .populate('lawyerId', 'fullName phone email city');

    res.status(201).json(populated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Send message in Consultation Chat Room
router.post('/:id/messages', verifyToken, async (req, res) => {
  try {
    const { text, attachments } = req.body;
    if (!text || !text.trim()) {
      return res.status(400).json({ error: 'نص الرسالة مطلوب' });
    }

    const consultation = await Consultation.findById(req.params.id);
    if (!consultation) {
      return res.status(404).json({ error: 'الاستشارة غير موجودة' });
    }

    consultation.messages.push({
      sender: req.user._id,
      text: text.trim(),
      attachments: attachments || [],
      timestamp: new Date()
    });

    // If lawyer replies, set status to in_progress
    if (req.user.role === 'lawyer' && consultation.status === 'pending') {
      consultation.status = 'in_progress';
    }

    await consultation.save();

    const updated = await Consultation.findById(consultation._id)
      .populate('clientId', 'fullName phone email city')
      .populate('lawyerId', 'fullName phone email city')
      .populate('messages.sender', 'fullName role');

    res.status(201).json(updated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Close or Update consultation status
router.patch('/:id/status', verifyToken, async (req, res) => {
  try {
    const { status, responseNotes } = req.body;
    const updateData = {};
    if (status) updateData.status = status;
    if (responseNotes) updateData.responseNotes = responseNotes;

    const consultation = await Consultation.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true }
    )
      .populate('clientId', 'fullName phone email')
      .populate('lawyerId', 'fullName phone email')
      .populate('messages.sender', 'fullName role');

    res.json(consultation);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Reassign consultation (Admin)
router.patch('/:id/reassign', async (req, res) => {
  try {
    const { lawyerId } = req.body;
    const consultation = await Consultation.findByIdAndUpdate(
      req.params.id,
      { lawyerId, status: 'in_progress' },
      { new: true }
    )
      .populate('clientId', 'fullName phone email')
      .populate('lawyerId', 'fullName phone email');

    res.json({ message: 'تم إعادة توجيه الاستشارة بنجاح', consultation });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

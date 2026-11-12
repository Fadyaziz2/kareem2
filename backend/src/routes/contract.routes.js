const express = require('express');
const router = express.Router();
const GeneratedContract = require('../models/GeneratedContract');
const Template = require('../models/Template');
const Transaction = require('../models/Transaction');
const { verifyToken } = require('../middleware/auth');

// Get my contracts (as client or as reviewing lawyer)
router.get('/my', verifyToken, async (req, res) => {
  try {
    const isLawyer = req.user.role === 'lawyer';
    const filter = isLawyer 
      ? { $or: [{ clientId: req.user._id }, { assignedLawyerId: req.user._id }] }
      : { clientId: req.user._id };

    const contracts = await GeneratedContract.find(filter)
      .populate('templateId', 'title category')
      .populate('clientId', 'fullName phone email')
      .populate('assignedLawyerId', 'fullName phone email')
      .sort({ createdAt: -1 });

    res.json(contracts);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Generate new contract
router.post('/generate', verifyToken, async (req, res) => {
  try {
    const { 
      templateId, 
      contractType = 'instant', 
      filledVariables = {}, 
      assignedLawyerId 
    } = req.body;

    const template = await Template.findById(templateId);
    if (!template) {
      return res.status(404).json({ error: 'نموذج العقد غير موجود' });
    }

    // Determine price
    const price = contractType === 'lawyer_review'
      ? (template.lawyerReviewPrice || 450)
      : (template.autoGeneratePrice || 150);

    // Replace placeholders {{key}} in template content with values from filledVariables
    let renderedContent = template.content;
    for (const [key, value] of Object.entries(filledVariables)) {
      const regex = new RegExp(`\\{\\{${key}\\}\\}`, 'g');
      renderedContent = renderedContent.replace(regex, String(value || ''));
    }

    const contract = await GeneratedContract.create({
      templateId: template._id,
      clientId: req.user._id,
      assignedLawyerId: assignedLawyerId || null,
      contractType,
      title: template.title,
      filledVariables,
      renderedContent,
      status: contractType === 'lawyer_review' ? 'pending_review' : 'completed',
      price,
      paymentStatus: 'paid'
    });

    // Record Transaction
    await Transaction.create({
      userId: req.user._id,
      type: 'contract_fee',
      amount: price,
      status: 'completed',
      description: `رسوم ${contractType === 'lawyer_review' ? 'صياغة ومراجعة قانونية' : 'توليد فوري'} لعقد: ${template.title}`,
      referenceId: contract._id.toString()
    });

    const populated = await GeneratedContract.findById(contract._id)
      .populate('templateId', 'title category')
      .populate('clientId', 'fullName phone email')
      .populate('assignedLawyerId', 'fullName phone email');

    res.status(201).json(populated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get contract by ID
router.get('/:id', verifyToken, async (req, res) => {
  try {
    const contract = await GeneratedContract.findById(req.params.id)
      .populate('templateId')
      .populate('clientId', 'fullName phone email')
      .populate('assignedLawyerId', 'fullName phone email');

    if (!contract) {
      return res.status(404).json({ error: 'العقد غير موجود' });
    }
    res.json(contract);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Lawyer review & approve contract
router.patch('/:id/review', verifyToken, async (req, res) => {
  try {
    const { status, lawyerNotes, updatedContent } = req.body;
    const contract = await GeneratedContract.findById(req.params.id);
    if (!contract) {
      return res.status(404).json({ error: 'العقد غير موجود' });
    }

    if (status) contract.status = status;
    if (lawyerNotes) contract.lawyerNotes = lawyerNotes;
    if (updatedContent) contract.renderedContent = updatedContent;
    contract.assignedLawyerId = req.user._id;

    await contract.save();

    const updated = await GeneratedContract.findById(contract._id)
      .populate('templateId', 'title category')
      .populate('clientId', 'fullName phone email')
      .populate('assignedLawyerId', 'fullName phone email');

    res.json({ message: 'تم تحديث مراجعة العقد بنجاح', contract: updated });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;


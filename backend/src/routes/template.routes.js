const express = require('express');
const router = express.Router();
const Template = require('../models/Template');

// Get all templates with optional category filter
router.get('/', async (req, res) => {
  try {
    const { category, search } = req.query;
    const filter = {};
    if (category && category !== 'all') {
      filter.category = category;
    }
    if (search) {
      filter.$or = [
        { title: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } }
      ];
    }
    const templates = await Template.find(filter).sort({ createdAt: -1 });
    res.json(templates);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get single template
router.get('/:id', async (req, res) => {
  try {
    const template = await Template.findById(req.params.id);
    if (!template) {
      return res.status(404).json({ error: 'نموذج العقد غير موجود' });
    }
    res.json(template);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create template
router.post('/', async (req, res) => {
  try {
    const { 
      title, 
      category, 
      description, 
      content, 
      variables, 
      autoGeneratePrice, 
      lawyerReviewPrice, 
      price, 
      requiresReview 
    } = req.body;

    const template = await Template.create({
      title,
      category,
      description,
      content,
      variables: variables || [],
      autoGeneratePrice: autoGeneratePrice ?? price ?? 150,
      lawyerReviewPrice: lawyerReviewPrice ?? 450,
      price: price ?? autoGeneratePrice ?? 150,
      requiresReview: requiresReview || false
    });

    res.status(201).json(template);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update template
router.put('/:id', async (req, res) => {
  try {
    const updated = await Template.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updated) {
      return res.status(404).json({ error: 'النموذج غير موجود' });
    }
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete template
router.delete('/:id', async (req, res) => {
  try {
    await Template.findByIdAndDelete(req.params.id);
    res.json({ message: 'تم حذف النموذج بنجاح' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

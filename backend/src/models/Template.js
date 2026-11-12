const mongoose = require('mongoose');

const templateVariableSchema = new mongoose.Schema({
  name: { type: String, required: true },
  label: { type: String, required: true },
  type: { type: String, enum: ['text', 'number', 'date', 'select'], default: 'text' },
  options: [{ type: String }], // options for select type
  required: { type: Boolean, default: true },
  defaultValue: { type: String, default: '' }
}, { _id: false });

const templateSchema = new mongoose.Schema({
  title: { type: String, required: true },
  category: { type: String, required: true },
  description: { type: String },
  content: { type: String, required: true },
  placeholders: [{ type: String }],
  variables: [templateVariableSchema],
  autoGeneratePrice: { type: Number, default: 150 },
  lawyerReviewPrice: { type: Number, default: 450 },
  price: { type: Number, default: 150 },
  requiresReview: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Template', templateSchema);

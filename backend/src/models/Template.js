const mongoose = require('mongoose');
const templateSchema = new mongoose.Schema({
  title: { type: String, required: true },
  category: { type: String, required: true },
  description: { type: String },
  content: { type: String, required: true },
  placeholders: [{ type: String }],
  price: { type: Number, default: 0 },
  requiresReview: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now }
});
module.exports = mongoose.model('Template', templateSchema);

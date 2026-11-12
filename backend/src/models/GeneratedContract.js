const mongoose = require('mongoose');

const generatedContractSchema = new mongoose.Schema({
  templateId: { type: mongoose.Schema.Types.ObjectId, ref: 'Template', required: true },
  clientId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  assignedLawyerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  contractType: { type: String, enum: ['instant', 'lawyer_review'], default: 'instant' },
  title: { type: String, required: true },
  filledVariables: { type: mongoose.Schema.Types.Mixed, default: {} },
  renderedContent: { type: String, required: true },
  status: { type: String, enum: ['draft', 'pending_review', 'approved', 'completed'], default: 'completed' },
  price: { type: Number, required: true },
  paymentStatus: { type: String, enum: ['pending', 'paid'], default: 'paid' },
  lawyerNotes: { type: String },
  pdfUrl: { type: String },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('GeneratedContract', generatedContractSchema);


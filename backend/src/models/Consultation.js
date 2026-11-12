const mongoose = require('mongoose');
const consultationSchema = new mongoose.Schema({
  clientId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  lawyerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  type: { type: String, enum: ['written', 'audio_call', 'office_visit'], default: 'written' },
  subject: { type: String, required: true },
  description: { type: String, required: true },
  attachments: [{ type: String }],
  price: { type: Number, required: true },
  status: { type: String, enum: ['pending', 'in_progress', 'completed', 'cancelled'], default: 'pending' },
  responseNotes: { type: String },
  createdAt: { type: Date, default: Date.now }
});
module.exports = mongoose.model('Consultation', consultationSchema);

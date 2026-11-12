const mongoose = require('mongoose');
const lawyerSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  barNumber: { type: String, required: true, unique: true },
  degree: { type: String, enum: ['ابتدائي', 'استئناف', 'نقض'], required: true },
  specializations: [{ type: String }],
  idCardImage: { type: String },
  barCardImage: { type: String },
  verificationStatus: { type: String, enum: ['pending', 'approved', 'rejected'], default: 'pending' },
  rejectionReason: { type: String },
  commissionRate: { type: Number, default: 15 },
  consultationRate: { type: Number, default: 250 },
  rating: { type: Number, default: 5.0 },
  totalConsultations: { type: Number, default: 0 }
});
module.exports = mongoose.model('Lawyer', lawyerSchema);

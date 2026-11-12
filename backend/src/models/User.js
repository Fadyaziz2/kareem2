const mongoose = require('mongoose');
const userSchema = new mongoose.Schema({
  fullName: { type: String, required: true },
  phone: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, enum: ['client', 'lawyer', 'super_admin', 'legal_director', 'financial_director', 'dispute_agent'], default: 'client' },
  walletBalance: { type: Number, default: 0 },
  city: { type: String, default: 'القاهرة' },
  isVerified: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now }
});
module.exports = mongoose.model('User', userSchema);

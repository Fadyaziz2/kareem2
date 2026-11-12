const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  type: { 
    type: String, 
    enum: [
      'escrow_deposit', 
      'escrow_release', 
      'escrow_refund', 
      'consultation_fee', 
      'contract_fee', 
      'wallet_topup', 
      'withdrawal', 
      'platform_commission'
    ], 
    required: true 
  },
  amount: { type: Number, required: true },
  status: { type: String, enum: ['pending', 'completed', 'failed'], default: 'completed' },
  description: { type: String, required: true },
  referenceId: { type: String },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Transaction', transactionSchema);


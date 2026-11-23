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
  currency: { type: String, default: 'EGP' },
  status: { type: String, enum: ['pending', 'completed', 'failed'], default: 'completed' },
  description: { type: String, required: true },
  referenceId: { type: String },

  // Paymob Integration Fields (باي موب)
  paymentGateway: { type: String, default: 'paymob' },
  paymobTransactionId: { type: String },
  paymobOrderId: { type: String },
  paymentMethod: { type: String, enum: ['card', 'mobile_wallet', 'fawry', 'manual', 'other'], default: 'card' },
  isLive: { type: Boolean, default: false },
  paymobResponse: { type: mongoose.Schema.Types.Mixed },

  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Transaction', transactionSchema);

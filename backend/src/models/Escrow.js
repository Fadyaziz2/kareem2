const mongoose = require('mongoose');

const milestoneSchema = new mongoose.Schema({
  title: { type: String, required: true },
  percentage: { type: Number, required: true },
  amount: { type: Number, required: true },
  terms: { type: String, required: true },
  status: { type: String, enum: ['pending_deposit', 'held_in_escrow', 'submitted', 'released', 'disputed'], default: 'held_in_escrow' },
  submissionNotes: { type: String },
  submissionFiles: [{ type: String }]
});

const escrowSchema = new mongoose.Schema({
  partyA: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  partyB: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  title: { type: String, required: true },
  description: { type: String },
  totalAmount: { type: Number, required: true },
  contractDocument: { type: String },
  linkedContractId: { type: mongoose.Schema.Types.ObjectId, ref: 'GeneratedContract' },
  milestones: [milestoneSchema],
  status: { type: String, enum: ['draft', 'active', 'completed', 'disputed', 'frozen'], default: 'active' },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Escrow', escrowSchema);

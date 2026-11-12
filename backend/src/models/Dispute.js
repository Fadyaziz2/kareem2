const mongoose = require('mongoose');
const disputeSchema = new mongoose.Schema({
  escrowId: { type: mongoose.Schema.Types.ObjectId, ref: 'Escrow', required: true },
  milestoneId: { type: mongoose.Schema.Types.ObjectId, required: true },
  raisedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  reason: { type: String, required: true },
  details: { type: String, required: true },
  evidenceFiles: [{ type: String }],
  priority: { type: String, enum: ['low', 'medium', 'high', 'urgent'], default: 'high' },
  status: { type: String, enum: ['open', 'under_investigation', 'resolved'], default: 'open' },
  arbitrationVerdict: {
    resolutionType: { type: String, enum: ['full_refund_partyA', 'full_release_partyB', 'custom_split'] },
    splitPartyA: { type: Number },
    splitPartyB: { type: Number },
    notes: { type: String },
    decidedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    decidedAt: { type: Date }
  },
  createdAt: { type: Date, default: Date.now }
});
module.exports = mongoose.model('Dispute', disputeSchema);

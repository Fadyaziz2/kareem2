class TransactionModel {
  final String id;
  final String type; // 'escrow_deposit' | 'escrow_release' | 'escrow_refund' | 'consultation_fee' | 'contract_fee' | 'wallet_topup' | 'withdrawal'
  final double amount;
  final String status;
  final String description;
  final String? referenceId;
  final DateTime? createdAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    this.status = 'completed',
    required this.description,
    this.referenceId,
    this.createdAt,
  });

  bool get isPositive =>
      type == 'wallet_topup' ||
      type == 'escrow_release' ||
      type == 'escrow_refund';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id'] ?? json['id'] ?? '',
      type: json['type'] ?? 'wallet_topup',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'completed',
      description: json['description'] ?? 'معاملة مالية',
      referenceId: json['referenceId']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}


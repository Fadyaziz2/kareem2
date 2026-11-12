class ContractModel {
  final String id;
  final String templateId;
  final String clientId;
  final String? clientName;
  final String? assignedLawyerId;
  final String? lawyerName;
  final String contractType; // 'instant' | 'lawyer_review'
  final String title;
  final Map<String, dynamic> filledVariables;
  final String renderedContent;
  final String status; // 'draft' | 'pending_review' | 'approved' | 'completed'
  final double price;
  final String paymentStatus;
  final String? lawyerNotes;
  final String? pdfUrl;
  final DateTime? createdAt;

  ContractModel({
    required this.id,
    required this.templateId,
    required this.clientId,
    this.clientName,
    this.assignedLawyerId,
    this.lawyerName,
    this.contractType = 'instant',
    required this.title,
    this.filledVariables = const {},
    required this.renderedContent,
    this.status = 'completed',
    required this.price,
    this.paymentStatus = 'paid',
    this.lawyerNotes,
    this.pdfUrl,
    this.createdAt,
  });

  bool get isInstant => contractType == 'instant';
  bool get isPendingReview => status == 'pending_review';

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    String cName = '';
    if (json['clientId'] is Map) {
      cName = json['clientId']['fullName'] ?? '';
    }

    String lName = '';
    if (json['assignedLawyerId'] is Map) {
      lName = json['assignedLawyerId']['fullName'] ?? '';
    }

    return ContractModel(
      id: json['_id'] ?? json['id'] ?? '',
      templateId: json['templateId'] is Map ? (json['templateId']['_id'] ?? '') : (json['templateId'] ?? ''),
      clientId: json['clientId'] is Map ? (json['clientId']['_id'] ?? '') : (json['clientId'] ?? ''),
      clientName: cName.isNotEmpty ? cName : null,
      assignedLawyerId: json['assignedLawyerId'] is Map ? (json['assignedLawyerId']['_id'] ?? '') : (json['assignedLawyerId']?.toString()),
      lawyerName: lName.isNotEmpty ? lName : null,
      contractType: json['contractType'] ?? 'instant',
      title: json['title'] ?? 'عقد قانوني موثق',
      filledVariables: json['filledVariables'] is Map ? Map<String, dynamic>.from(json['filledVariables']) : {},
      renderedContent: json['renderedContent'] ?? '',
      status: json['status'] ?? 'completed',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['paymentStatus'] ?? 'paid',
      lawyerNotes: json['lawyerNotes'],
      pdfUrl: json['pdfUrl'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}


class MilestoneModel {
  final String id;
  final String title;
  final double percentage;
  final double amount;
  final String terms;
  final String status; // 'pending_deposit' | 'held_in_escrow' | 'submitted' | 'released' | 'disputed'
  final String? submissionNotes;
  final List<String> submissionFiles;

  MilestoneModel({
    required this.id,
    required this.title,
    required this.percentage,
    required this.amount,
    required this.terms,
    this.status = 'held_in_escrow',
    this.submissionNotes,
    this.submissionFiles = const [],
  });

  bool get isReleased => status == 'released';
  bool get isSubmitted => status == 'submitted';
  bool get isDisputed => status == 'disputed';
  bool get isHeld => status == 'held_in_escrow';

  factory MilestoneModel.fromJson(Map<String, dynamic> json) {
    return MilestoneModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      terms: json['terms'] ?? '',
      status: json['status'] ?? 'held_in_escrow',
      submissionNotes: json['submissionNotes'],
      submissionFiles: (json['submissionFiles'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'percentage': percentage,
      'amount': amount,
      'terms': terms,
      'status': status,
      'submissionNotes': submissionNotes,
      'submissionFiles': submissionFiles,
    };
  }
}

class EscrowModel {
  final String id;
  final String partyAId;
  final String partyAName;
  final String partyAPhone;
  final String partyBId;
  final String partyBName;
  final String partyBPhone;
  final String title;
  final String description;
  final double totalAmount;
  final String? contractDocument;
  final String? linkedContractId;
  final List<MilestoneModel> milestones;
  final String status; // 'draft' | 'active' | 'completed' | 'disputed' | 'frozen'
  final DateTime? createdAt;

  EscrowModel({
    required this.id,
    required this.partyAId,
    required this.partyAName,
    required this.partyAPhone,
    required this.partyBId,
    required this.partyBName,
    required this.partyBPhone,
    required this.title,
    required this.description,
    required this.totalAmount,
    this.contractDocument,
    this.linkedContractId,
    this.milestones = const [],
    this.status = 'active',
    this.createdAt,
  });

  bool isPartyA(String currentUserId) => partyAId == currentUserId;
  bool isPartyB(String currentUserId) => partyBId == currentUserId;

  bool get isActive => status == 'active';
  bool get isDisputed => status == 'disputed';
  bool get isCompleted => status == 'completed';
  bool get isFrozen => status == 'frozen';

  factory EscrowModel.fromJson(Map<String, dynamic> json) {
    String aId = '';
    String aName = 'المشتري';
    String aPhone = '';
    if (json['partyA'] is Map) {
      final a = json['partyA'];
      aId = a['_id'] ?? a['id'] ?? '';
      aName = a['fullName'] ?? aName;
      aPhone = a['phone'] ?? '';
    } else if (json['partyA'] != null) {
      aId = json['partyA'].toString();
    }

    String bId = '';
    String bName = 'المنفذ';
    String bPhone = '';
    if (json['partyB'] is Map) {
      final b = json['partyB'];
      bId = b['_id'] ?? b['id'] ?? '';
      bName = b['fullName'] ?? bName;
      bPhone = b['phone'] ?? '';
    } else if (json['partyB'] != null) {
      bId = json['partyB'].toString();
    }

    final msList = (json['milestones'] as List?)
            ?.map((m) => MilestoneModel.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [];

    return EscrowModel(
      id: json['_id'] ?? json['id'] ?? '',
      partyAId: aId,
      partyAName: aName,
      partyAPhone: aPhone,
      partyBId: bId,
      partyBName: bName,
      partyBPhone: bPhone,
      title: json['title'] ?? 'عقد وساطة وضمان',
      description: json['description'] ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      contractDocument: json['contractDocument'],
      linkedContractId: json['linkedContractId'] is Map ? (json['linkedContractId']['_id']) : json['linkedContractId']?.toString(),
      milestones: msList,
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}


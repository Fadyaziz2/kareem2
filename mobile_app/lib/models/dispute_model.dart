class DisputeModel {
  final String id;
  final String escrowId;
  final String escrowTitle;
  final double escrowTotal;
  final String milestoneId;
  final String? milestoneTitle;
  final double milestoneAmount;
  final String raisedById;
  final String raisedByName;
  final String reason;
  final String details;
  final String priority;
  final String status; // 'open' | 'under_investigation' | 'resolved'
  final List<String> evidenceFiles;
  final String? resolutionType;
  final double? splitPartyA;
  final double? splitPartyB;
  final String? arbitratorNotes;
  final DateTime? createdAt;

  DisputeModel({
    required this.id,
    required this.escrowId,
    required this.escrowTitle,
    required this.escrowTotal,
    required this.milestoneId,
    this.milestoneTitle,
    required this.milestoneAmount,
    required this.raisedById,
    required this.raisedByName,
    required this.reason,
    required this.details,
    this.priority = 'urgent',
    this.status = 'open',
    this.evidenceFiles = const [],
    this.resolutionType,
    this.splitPartyA,
    this.splitPartyB,
    this.arbitratorNotes,
    this.createdAt,
  });

  bool get isResolved => status == 'resolved';

  factory DisputeModel.fromJson(Map<String, dynamic> json) {
    String escId = '';
    String escTitle = 'عقد وساطة';
    double escAmount = 0.0;
    String msTitle = '';
    double msAmount = 0.0;

    if (json['escrowId'] is Map) {
      final e = json['escrowId'];
      escId = e['_id'] ?? e['id'] ?? '';
      escTitle = e['title'] ?? escTitle;
      escAmount = (e['totalAmount'] as num?)?.toDouble() ?? 0.0;

      if (e['milestones'] is List) {
        final mId = json['milestoneId']?.toString();
        for (var m in e['milestones']) {
          if (m is Map && (m['_id'] == mId || m['id'] == mId)) {
            msTitle = m['title'] ?? '';
            msAmount = (m['amount'] as num?)?.toDouble() ?? 0.0;
            break;
          }
        }
      }
    } else if (json['escrowId'] != null) {
      escId = json['escrowId'].toString();
    }

    String rId = '';
    String rName = 'الشاكي';
    if (json['raisedBy'] is Map) {
      final r = json['raisedBy'];
      rId = r['_id'] ?? r['id'] ?? '';
      rName = r['fullName'] ?? rName;
    } else if (json['raisedBy'] != null) {
      rId = json['raisedBy'].toString();
    }

    String? resType;
    double? sA;
    double? sB;
    String? arbNotes;

    if (json['arbitrationVerdict'] is Map) {
      final v = json['arbitrationVerdict'];
      resType = v['resolutionType'];
      sA = (v['splitPartyA'] as num?)?.toDouble();
      sB = (v['splitPartyB'] as num?)?.toDouble();
      arbNotes = v['notes'];
    }

    return DisputeModel(
      id: json['_id'] ?? json['id'] ?? '',
      escrowId: escId,
      escrowTitle: escTitle,
      escrowTotal: escAmount,
      milestoneId: json['milestoneId']?.toString() ?? '',
      milestoneTitle: msTitle.isNotEmpty ? msTitle : null,
      milestoneAmount: msAmount,
      raisedById: rId,
      raisedByName: rName,
      reason: json['reason'] ?? '',
      details: json['details'] ?? '',
      priority: json['priority'] ?? 'urgent',
      status: json['status'] ?? 'open',
      evidenceFiles: (json['evidenceFiles'] as List?)?.map((e) => e.toString()).toList() ?? [],
      resolutionType: resType,
      splitPartyA: sA,
      splitPartyB: sB,
      arbitratorNotes: arbNotes,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}


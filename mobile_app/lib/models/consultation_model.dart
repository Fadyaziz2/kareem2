class ChatMessageModel {
  final String senderId;
  final String senderName;
  final String senderRole;
  final String text;
  final List<String> attachments;
  final DateTime timestamp;

  ChatMessageModel({
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    this.attachments = const [],
    required this.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    String sId = '';
    String sName = 'مستخدم';
    String sRole = 'client';

    if (json['sender'] is Map) {
      final s = json['sender'];
      sId = s['_id'] ?? s['id'] ?? '';
      sName = s['fullName'] ?? sName;
      sRole = s['role'] ?? sRole;
    } else if (json['sender'] != null) {
      sId = json['sender'].toString();
    }

    return ChatMessageModel(
      senderId: sId,
      senderName: sName,
      senderRole: sRole,
      text: json['text'] ?? '',
      attachments: (json['attachments'] as List?)?.map((e) => e.toString()).toList() ?? [],
      timestamp: json['timestamp'] != null ? (DateTime.tryParse(json['timestamp']) ?? DateTime.now()) : DateTime.now(),
    );
  }
}

class ConsultationModel {
  final String id;
  final String clientId;
  final String clientName;
  final String clientPhone;
  final String? lawyerId;
  final String? lawyerName;
  final String type; // 'written' | 'audio_call' | 'office_visit'
  final String subject;
  final String description;
  final List<String> attachments;
  final double price;
  final String status; // 'pending' | 'in_progress' | 'completed' | 'cancelled'
  final String? responseNotes;
  final List<ChatMessageModel> messages;
  final DateTime? createdAt;

  ConsultationModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    this.lawyerId,
    this.lawyerName,
    this.type = 'written',
    required this.subject,
    required this.description,
    this.attachments = const [],
    required this.price,
    this.status = 'pending',
    this.responseNotes,
    this.messages = const [],
    this.createdAt,
  });

  String get typeArabic {
    switch (type) {
      case 'written': return 'استشارة مكتوبة';
      case 'audio_call': return 'مكالمة هاتفية';
      case 'office_visit': return 'مقابلة بمكتب المحامي';
      default: return 'استشارة قانونية';
    }
  }

  String get statusArabic {
    switch (status) {
      case 'completed': return 'مكتملة ومغلقة';
      case 'in_progress': return 'قيد المتابعة';
      case 'pending': return 'بانتظار قبول المحامي';
      default: return 'ملغاة';
    }
  }

  factory ConsultationModel.fromJson(Map<String, dynamic> json) {
    String cId = '';
    String cName = 'عميل';
    String cPhone = '';
    if (json['clientId'] is Map) {
      final c = json['clientId'];
      cId = c['_id'] ?? c['id'] ?? '';
      cName = c['fullName'] ?? cName;
      cPhone = c['phone'] ?? '';
    } else if (json['clientId'] != null) {
      cId = json['clientId'].toString();
    }

    String? lId;
    String? lName;
    if (json['lawyerId'] is Map) {
      final l = json['lawyerId'];
      lId = l['_id'] ?? l['id'];
      lName = l['fullName'];
    } else if (json['lawyerId'] != null) {
      lId = json['lawyerId'].toString();
    }

    final msgs = (json['messages'] as List?)
            ?.map((m) => ChatMessageModel.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [];

    return ConsultationModel(
      id: json['_id'] ?? json['id'] ?? '',
      clientId: cId,
      clientName: cName,
      clientPhone: cPhone,
      lawyerId: lId,
      lawyerName: lName,
      type: json['type'] ?? 'written',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      attachments: (json['attachments'] as List?)?.map((e) => e.toString()).toList() ?? [],
      price: (json['price'] as num?)?.toDouble() ?? 250.0,
      status: json['status'] ?? 'pending',
      responseNotes: json['responseNotes'],
      messages: msgs,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}


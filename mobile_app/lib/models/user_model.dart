class UserModel {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String role; // 'client' | 'lawyer' | 'super_admin' | 'dispute_agent'
  final double walletBalance;
  final String city;
  final bool isVerified;
  final DateTime? createdAt;
  final Map<String, dynamic>? lawyerProfile;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.role,
    this.walletBalance = 0.0,
    this.city = 'القاهرة',
    this.isVerified = false,
    this.createdAt,
    this.lawyerProfile,
  });

  bool get isLawyer => role == 'lawyer';
  bool get isAdmin => role == 'super_admin' || role == 'dispute_agent' || role == 'legal_director';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'client',
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      city: json['city'] ?? 'القاهرة',
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      lawyerProfile: json['lawyerProfile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'role': role,
      'walletBalance': walletBalance,
      'city': city,
      'isVerified': isVerified,
      'createdAt': createdAt?.toIso8601String(),
      'lawyerProfile': lawyerProfile,
    };
  }
}


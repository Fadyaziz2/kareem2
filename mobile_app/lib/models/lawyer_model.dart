class LawyerModel {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String email;
  final String city;
  final String barNumber;
  final String degree; // 'ابتدائي' | 'استئناف' | 'نقض'
  final List<String> specializations;
  final String bio;
  final String? idCardImage;
  final String? barCardImage;
  final String verificationStatus; // 'pending' | 'approved' | 'rejected'
  final double commissionRate;
  final double consultationRate;
  final double rating;
  final int totalConsultations;

  LawyerModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.email,
    this.city = 'القاهرة',
    required this.barNumber,
    required this.degree,
    this.specializations = const [],
    this.bio = '',
    this.idCardImage,
    this.barCardImage,
    this.verificationStatus = 'approved',
    this.commissionRate = 15.0,
    this.consultationRate = 250.0,
    this.rating = 5.0,
    this.totalConsultations = 0,
  });

  bool get isApproved => verificationStatus == 'approved';

  factory LawyerModel.fromJson(Map<String, dynamic> json) {
    String uId = '';
    String fName = 'محامٍ معتمد';
    String ph = '';
    String em = '';
    String ct = 'القاهرة';

    if (json['userId'] is Map) {
      final u = json['userId'];
      uId = u['_id'] ?? u['id'] ?? '';
      fName = u['fullName'] ?? fName;
      ph = u['phone'] ?? '';
      em = u['email'] ?? '';
      ct = u['city'] ?? ct;
    } else if (json['userId'] != null) {
      uId = json['userId'].toString();
    }

    return LawyerModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: uId,
      fullName: fName,
      phone: ph,
      email: em,
      city: ct,
      barNumber: json['barNumber'] ?? '',
      degree: json['degree'] ?? 'ابتدائي',
      specializations: (json['specializations'] as List?)?.map((e) => e.toString()).toList() ?? [],
      bio: json['bio'] ?? 'محامٍ ومستشار قانوني مقيد بنقابة المحامين.',
      idCardImage: json['idCardImage'],
      barCardImage: json['barCardImage'],
      verificationStatus: json['verificationStatus'] ?? 'approved',
      commissionRate: (json['commissionRate'] as num?)?.toDouble() ?? 15.0,
      consultationRate: (json['consultationRate'] as num?)?.toDouble() ?? 250.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalConsultations: (json['totalConsultations'] as num?)?.toInt() ?? 0,
    );
  }
}


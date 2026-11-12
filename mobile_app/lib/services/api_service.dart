import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_constants.dart';
import '../models/user_model.dart';
import '../models/template_model.dart';
import '../models/contract_model.dart';
import '../models/lawyer_model.dart';
import '../models/consultation_model.dart';
import '../models/escrow_model.dart';
import '../models/dispute_model.dart';
import '../models/transaction_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  String? get token => _token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null && _token!.isNotEmpty) 'Authorization': 'Bearer $_token',
      };

  // ----------------------------------------------------
  // AUTH
  // ----------------------------------------------------
  Future<Map<String, dynamic>> login(String emailOrPhone, String password) async {
    final res = await http.post(
      Uri.parse(ApiConstants.login),
      headers: _headers,
      body: jsonEncode({'emailOrPhone': emailOrPhone.trim(), 'password': password}),
    );

    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode == 200) {
      if (data['token'] != null) {
        await setToken(data['token']);
      }
      return data;
    } else {
      throw Exception(data['error'] ?? 'فشل تسجيل الدخول');
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final res = await http.post(
      Uri.parse(ApiConstants.register),
      headers: _headers,
      body: jsonEncode(userData),
    );

    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode == 201) {
      if (data['token'] != null) {
        await setToken(data['token']);
      }
      return data;
    } else {
      throw Exception(data['error'] ?? 'فشل إنشاء الحساب');
    }
  }

  Future<UserModel> getMe() async {
    final res = await http.get(
      Uri.parse(ApiConstants.me),
      headers: _headers,
    );

    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode == 200 && data['user'] != null) {
      return UserModel.fromJson(data['user']);
    } else {
      throw Exception(data['error'] ?? 'تعذر جلب بيانات المستخدم');
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> updateData) async {
    final res = await http.put(
      Uri.parse(ApiConstants.profile),
      headers: _headers,
      body: jsonEncode(updateData),
    );

    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode == 200 && data['user'] != null) {
      return UserModel.fromJson(data['user']);
    } else {
      throw Exception(data['error'] ?? 'فشل تحديث البيانات');
    }
  }

  // ----------------------------------------------------
  // TEMPLATES & CONTRACTS
  // ----------------------------------------------------
  Future<List<TemplateModel>> getTemplates({String? category}) async {
    String url = ApiConstants.templates;
    if (category != null && category != 'all') {
      url += '?category=${Uri.encodeComponent(category)}';
    }

    final res = await http.get(Uri.parse(url), headers: _headers);
    if (res.statusCode == 200) {
      final List list = jsonDecode(utf8.decode(res.bodyBytes));
      return list.map((item) => TemplateModel.fromJson(item)).toList();
    } else {
      throw Exception('فشل جلب نماذج العقود');
    }
  }

  Future<List<ContractModel>> getMyContracts() async {
    final res = await http.get(Uri.parse(ApiConstants.myContracts), headers: _headers);
    if (res.statusCode == 200) {
      final List list = jsonDecode(utf8.decode(res.bodyBytes));
      return list.map((item) => ContractModel.fromJson(item)).toList();
    } else {
      throw Exception('فشل جلب قائمة عقودك');
    }
  }

  Future<ContractModel> generateContract({
    required String templateId,
    required String contractType, // 'instant' | 'lawyer_review'
    required Map<String, dynamic> filledVariables,
    String? assignedLawyerId,
  }) async {
    final res = await http.post(
      Uri.parse(ApiConstants.generateContract),
      headers: _headers,
      body: jsonEncode({
        'templateId': templateId,
        'contractType': contractType,
        'filledVariables': filledVariables,
        if (assignedLawyerId != null) 'assignedLawyerId': assignedLawyerId,
      }),
    );

    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode == 201) {
      return ContractModel.fromJson(data);
    } else {
      throw Exception(data['error'] ?? 'فشل توليد وتوثيق العقد');
    }
  }

  Future<ContractModel> reviewContract({
    required String contractId,
    required String status,
    String? lawyerNotes,
    String? updatedContent,
  }) async {
    final res = await http.patch(
      Uri.parse(ApiConstants.reviewContract(contractId)),
      headers: _headers,
      body: jsonEncode({
        'status': status,
        if (lawyerNotes != null) 'lawyerNotes': lawyerNotes,
        if (updatedContent != null) 'updatedContent': updatedContent,
      }),
    );

    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode == 200 && data['contract'] != null) {
      return ContractModel.fromJson(data['contract']);
    } else {
      throw Exception(data['error'] ?? 'فشل حفظ مراجعة العقد');
    }
  }

  // ----------------------------------------------------
  // LAWYERS
  // ----------------------------------------------------
  Future<List<LawyerModel>> getLawyers({String? specialization, String? degree, String? search}) async {
    String url = ApiConstants.lawyers;
    List<String> params = [];
    if (specialization != null && specialization != 'all') {
      params.add('specialization=${Uri.encodeComponent(specialization)}');
    }
    if (degree != null && degree != 'all') {
      params.add('degree=${Uri.encodeComponent(degree)}');
    }
    if (search != null && search.isNotEmpty) {
      params.add('search=${Uri.encodeComponent(search)}');
    }
    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }

    final res = await http.get(Uri.parse(url), headers: _headers);
    if (res.statusCode == 200) {
      final List list = jsonDecode(utf8.decode(res.bodyBytes));
      return list.map((item) => LawyerModel.fromJson(item)).toList();
    } else {
      throw Exception('فشل جلب دليل المحامين');
    }
  }

  Future<LawyerModel> getLawyerDetails(String id) async {
    final res = await http.get(Uri.parse(ApiConstants.lawyerDetails(id)), headers: _headers);
    if (res.statusCode == 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      return LawyerModel.fromJson(data);
    } else {
      throw Exception('فشل جلب ملف المحامي');
    }
  }

  // ----------------------------------------------------
  // CONSULTATIONS
  // ----------------------------------------------------
  Future<List<ConsultationModel>> getConsultations() async {
    final res = await http.get(Uri.parse(ApiConstants.consultations), headers: _headers);
    if (res.statusCode == 200) {
      final List list = jsonDecode(utf8.decode(res.bodyBytes));
      return list.map((item) => ConsultationModel.fromJson(item)).toList();
    } else {
      throw Exception('فشل جلب الاستشارات');
    }
  }

  Future<ConsultationModel> getConsultationDetails(String id) async {
    final res = await http.get(Uri.parse(ApiConstants.consultationDetails(id)), headers: _headers);
    if (res.statusCode == 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      return ConsultationModel.fromJson(data);
    } else {
      throw Exception('فشل جلب تفاصيل الاستشارة');
    }
  }

  Future<ConsultationModel> bookConsultation({
    required String? lawyerId,
    required String type, // 'written' | 'audio_call' | 'office_visit'
    required String subject,
    required String description,
    required double price,
    List<String> attachments = const [],
  }) async {
    final res = await http.post(
      Uri.parse(ApiConstants.consultations),
      headers: _headers,
      body: jsonEncode({
        if (lawyerId != null) 'lawyerId': lawyerId,
        'type': type,
        'subject': subject,
        'description': description,
        'price': price,
        'attachments': attachments,
      }),
    );

    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode == 201) {
      return ConsultationModel.fromJson(data);
    } else {
      throw Exception(data['error'] ?? 'فشل حجز الاستشارة');
    }
  }

  Future<ConsultationModel> sendChatMessage(String consultationId, String text) async {
    final res = await http.post(
      Uri.parse(ApiConstants.consultationMessages(consultationId)),
      headers: _headers,
      body: jsonEncode({'text': text}),
    );

    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode == 201) {
      return ConsultationModel.fromJson(data);
    } else {
      throw Exception(data['error'] ?? 'فشل إرسال الرسالة');
    }
  }

  Future<ConsultationModel> closeConsultation(String consultationId, String responseNotes) async {
    final res = await http.patch(
      Uri.parse(ApiConstants.consultationStatus(consultationId)),
      headers: _headers,
      body: jsonEncode({
        'status': 'completed',
        'responseNotes': responseNotes,
      }),
    );

    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode == 200) {
      return ConsultationModel.fromJson(data);
    } else {
      throw Exception(data['error'] ?? 'فشل إغلاق الاستشارة');
    }
  }

  // ----------------------------------------------------
  // ESCROW & MILESTONES
  // ----------------------------------------------------
  Future<List<EscrowModel>> getEscrows() async {
    final res = await http.get(Uri.parse(ApiConstants.escrow), headers: _headers);
    if (res.statusCode == 200) {
      final List list = jsonDecode(utf8.decode(res.bodyBytes));
      return list.map((item) => EscrowModel.fromJson(item)).toList();
    } else {
      throw Exception('فشل جلب عمليات الوساطة والضمان');
    }
  }

  Future<EscrowModel> getEscrowDetails(String id) async {
    final res = await http.get(Uri.parse(ApiConstants.escrowDetails(id)), headers: _headers);
    if (res.statusCode == 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      return EscrowModel.fromJson(data);
    } else {
      throw Exception('فشل جلب تفاصيل عملية الضمان');
    }
  }

  Future<EscrowModel> createEscrow(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(ApiConstants.escrow),
      headers: _headers,
      body: jsonEncode(payload),
    );

    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode == 201) {
      return EscrowModel.fromJson(data);
    } else {
      throw Exception(data['error'] ?? 'فشل إنشاء عملية الضمان');
    }
  }

  Future<EscrowModel> submitMilestone(String escrowId, String milestoneId, String notes) async {
    final res = await http.patch(
      Uri.parse(ApiConstants.submitMilestone(escrowId, milestoneId)),
      headers: _headers,
      body: jsonEncode({'submissionNotes': notes}),
    );

    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode == 200 && data['escrow'] != null) {
      return EscrowModel.fromJson(data['escrow']);
    } else {
      throw Exception(data['error'] ?? 'فشل تسليم مرحلة الإنجاز');
    }
  }

  Future<EscrowModel> releaseMilestone(String escrowId, String milestoneId) async {
    final res = await http.patch(
      Uri.parse(ApiConstants.releaseMilestone(escrowId, milestoneId)),
      headers: _headers,
    );

    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode == 200 && data['escrow'] != null) {
      return EscrowModel.fromJson(data['escrow']);
    } else {
      throw Exception(data['error'] ?? 'فشل تحرير الدفعة المالية');
    }
  }

  // ----------------------------------------------------
  // DISPUTES
  // ----------------------------------------------------
  Future<List<DisputeModel>> getDisputes() async {
    final res = await http.get(Uri.parse(ApiConstants.disputes), headers: _headers);
    if (res.statusCode == 200) {
      final List list = jsonDecode(utf8.decode(res.bodyBytes));
      return list.map((item) => DisputeModel.fromJson(item)).toList();
    } else {
      throw Exception('فشل جلب ملفات النزاع');
    }
  }

  Future<DisputeModel> getDisputeDetails(String id) async {
    final res = await http.get(Uri.parse(ApiConstants.disputeDetails(id)), headers: _headers);
    if (res.statusCode == 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      return DisputeModel.fromJson(data);
    } else {
      throw Exception('فشل جلب تفاصيل النزاع');
    }
  }

  Future<DisputeModel> raiseDispute({
    required String escrowId,
    required String milestoneId,
    required String reason,
    required String details,
    List<String> evidenceFiles = const [],
  }) async {
    final res = await http.post(
      Uri.parse(ApiConstants.disputes),
      headers: _headers,
      body: jsonEncode({
        'escrowId': escrowId,
        'milestoneId': milestoneId,
        'reason': reason,
        'details': details,
        'evidenceFiles': evidenceFiles,
      }),
    );

    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode == 201) {
      return DisputeModel.fromJson(data);
    } else {
      throw Exception(data['error'] ?? 'فشل فتح ملف النزاع');
    }
  }

  // ----------------------------------------------------
  // PAYMENTS & WALLET
  // ----------------------------------------------------
  Future<bool> mockCheckout({
    required String type, // 'contract' | 'consultation' | 'escrow' | 'topup'
    required double amount,
    String? referenceId,
    String? description,
  }) async {
    final res = await http.post(
      Uri.parse(ApiConstants.mockCheckout),
      headers: _headers,
      body: jsonEncode({
        'type': type,
        'amount': amount,
        'referenceId': referenceId,
        'description': description,
      }),
    );

    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode == 200 && data['success'] == true) {
      return true;
    } else {
      throw Exception(data['error'] ?? 'فشلت عملية الدفع الإلكتروني');
    }
  }

  Future<Map<String, dynamic>> getWalletData() async {
    final res = await http.get(Uri.parse(ApiConstants.walletTransactions), headers: _headers);
    if (res.statusCode == 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final List txList = data['transactions'] ?? [];
      return {
        'walletBalance': (data['walletBalance'] as num?)?.toDouble() ?? 0.0,
        'heldBalance': (data['heldBalance'] as num?)?.toDouble() ?? 0.0,
        'transactions': txList.map((t) => TransactionModel.fromJson(t)).toList(),
      };
    } else {
      throw Exception('فشل جلب بيانات المحفظة');
    }
  }

  Future<double> topupWallet(double amount) async {
    final res = await http.post(
      Uri.parse(ApiConstants.walletTopup),
      headers: _headers,
      body: jsonEncode({'amount': amount}),
    );

    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode == 200) {
      return (data['walletBalance'] as num?)?.toDouble() ?? 0.0;
    } else {
      throw Exception(data['error'] ?? 'فشل شحن المحفظة');
    }
  }

  Future<void> requestWithdrawal(double amount, String bankName, String iban, String accountHolder) async {
    final res = await http.post(
      Uri.parse(ApiConstants.walletWithdraw),
      headers: _headers,
      body: jsonEncode({
        'amount': amount,
        'bankName': bankName,
        'iban': iban,
        'accountHolder': accountHolder,
      }),
    );

    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode != 201) {
      throw Exception(data['error'] ?? 'فشل طلب سحب الأرباح');
    }
  }
}

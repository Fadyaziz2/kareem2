import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;

  void setToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // تسجيل الدخول
  Future<Map<String, dynamic>> login(String emailOrPhone, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: _headers,
      body: jsonEncode({
        'emailOrPhone': emailOrPhone,
        'password': password,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['token'] != null) {
        setToken(data['token']);
      }
      return data;
    } else {
      throw Exception(data['error'] ?? 'فشل تسجيل الدخول');
    }
  }

  // إنشاء حساب جديد
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: _headers,
      body: jsonEncode(userData),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      if (data['token'] != null) {
        setToken(data['token']);
      }
      return data;
    } else {
      throw Exception(data['error'] ?? 'فشل إنشاء الحساب');
    }
  }

  // جلب المحامين
  Future<List<dynamic>> getLawyers() async {
    final response = await http.get(
      Uri.parse(ApiConstants.lawyers),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('فشل جلب قائمة المحامين');
    }
  }

  // جلب نماذج العقود
  Future<List<dynamic>> getTemplates() async {
    final response = await http.get(
      Uri.parse(ApiConstants.templates),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('فشل جلب نماذج العقود');
    }
  }

  // جلب الاستشارات
  Future<List<dynamic>> getConsultations() async {
    final response = await http.get(
      Uri.parse(ApiConstants.consultations),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('فشل جلب الاستشارات');
    }
  }

  // جلب عمليات الضمان
  Future<List<dynamic>> getEscrowOperations() async {
    final response = await http.get(
      Uri.parse(ApiConstants.escrow),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('فشل جلب عمليات الضمان');
    }
  }

  // جلب النزاعات
  Future<List<dynamic>> getDisputes() async {
    final response = await http.get(
      Uri.parse(ApiConstants.disputes),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('فشل جلب قائمة النزاعات');
    }
  }
}


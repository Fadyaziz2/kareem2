class ApiConstants {
  /// Base URL للسيرفر والـ API
  static const String baseUrl = 'http://169.58.109.98:5003';
  static const String apiBaseUrl = '$baseUrl/api';

  // مسارات المصادقة (Auth)
  static const String login = '$apiBaseUrl/auth/login';
  static const String register = '$apiBaseUrl/auth/register';

  // مسارات المحامين (Lawyers)
  static const String lawyers = '$apiBaseUrl/lawyers';

  // مسارات نماذج العقود (Templates)
  static const String templates = '$apiBaseUrl/templates';

  // مسارات الاستشارات (Consultations)
  static const String consultations = '$apiBaseUrl/consultations';

  // مسارات حساب الضمان والوساطة (Escrow)
  static const String escrow = '$apiBaseUrl/escrow';

  // مسارات النزاعات (Disputes)
  static const String disputes = '$apiBaseUrl/disputes';

  // مسارات الإدارة (Admin)
  static const String adminStats = '$apiBaseUrl/admin/stats';
}


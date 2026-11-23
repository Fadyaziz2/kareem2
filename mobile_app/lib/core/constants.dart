export 'api_constants.dart';

class AppConstants {
  static const String baseUrl = 'https://oqoody.duckdns.org';
  static const String apiBaseUrl = '$baseUrl/api';

  // Feature flags for temporary hiding (اخفاء مؤقت بدون حذف)
  static const bool enableEscrow = false;
  static const bool enableWallet = false;
}

class ApiConstants {
  // Base server URL (Configured for live backend server)
  static const String baseUrl = 'https://oqoody.duckdns.org';
  static const String apiBaseUrl = '$baseUrl/api';

  // Auth endpoints
  static const String register = '$apiBaseUrl/auth/register';
  static const String login = '$apiBaseUrl/auth/login';
  static const String me = '$apiBaseUrl/auth/me';
  static const String profile = '$apiBaseUrl/auth/profile';

  // Templates & Contracts
  static const String templates = '$apiBaseUrl/templates';
  static const String myContracts = '$apiBaseUrl/contracts/my';
  static const String generateContract = '$apiBaseUrl/contracts/generate';
  static String contractDetails(String id) => '$apiBaseUrl/contracts/$id';
  static String reviewContract(String id) => '$apiBaseUrl/contracts/$id/review';

  // Lawyers
  static const String lawyers = '$apiBaseUrl/lawyers';
  static String lawyerDetails(String id) => '$apiBaseUrl/lawyers/$id';

  // Consultations
  static const String consultations = '$apiBaseUrl/consultations';
  static String consultationDetails(String id) => '$apiBaseUrl/consultations/$id';
  static String consultationMessages(String id) => '$apiBaseUrl/consultations/$id/messages';
  static String consultationStatus(String id) => '$apiBaseUrl/consultations/$id/status';

  // Escrow & Milestones
  static const String escrow = '$apiBaseUrl/escrow';
  static String escrowDetails(String id) => '$apiBaseUrl/escrow/$id';
  static String submitMilestone(String escrowId, String mId) => '$apiBaseUrl/escrow/$escrowId/milestones/$mId/submit';
  static String releaseMilestone(String escrowId, String mId) => '$apiBaseUrl/escrow/$escrowId/milestones/$mId/release';

  // Disputes
  static const String disputes = '$apiBaseUrl/disputes';
  static String disputeDetails(String id) => '$apiBaseUrl/disputes/$id';

  // Payments & Paymob (باي موب)
  static const String mockCheckout = '$apiBaseUrl/payments/mock-checkout';
  static const String paymobConfig = '$apiBaseUrl/payments/paymob/config';
  static const String paymobInitiate = '$apiBaseUrl/payments/paymob/initiate';
  static const String paymobProcess = '$apiBaseUrl/payments/paymob/process';
  static const String paymentTransactions = '$apiBaseUrl/payments/transactions';
  static const String walletTransactions = '$apiBaseUrl/wallet/transactions';
  static const String walletTopup = '$apiBaseUrl/wallet/topup';
  static const String walletWithdraw = '$apiBaseUrl/wallet/withdraw';
}

/// Paymob Payment Gateway Configuration for Oqoody (عقودي - باي موب)
///
/// يمكنك هنا تعديل وضع الدفع بين التجريبي (Test) والحي (Live)
/// وإضافة المفاتيح الخاصة بحسابك في Paymob
class PaymobConstants {
  // =========================================================================
  // 1. ENVIRONMENT TOGGLE (حدد هنا إذا كانت البيئة تجريبية أو حقيقية)
  // =========================================================================
  /// اجعلها true عندما تريد تشغيل الدفع الفعلي المباشر (Live Mode)
  /// واجعلها false عندما تريد تشغيل بيئة الاختبار (Test Mode)
  static const bool isLiveMode = false;

  // =========================================================================
  // 2. API KEYS (من لوحة تحكم Paymob -> Settings -> API Keys)
  // =========================================================================
  static const String apiKey =
      'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRJMU9USTJNaXdpYm1GdFpTSTZJbWx1YVhScFlXd2lmUS5GWGlzNXd3YjcwWldvc19Db1R0TFpTUkdPRGlRRzFETTduTnpPcnRONEs0VllUejNEbU1aUHFUdUNTNVRfRVFYTUF0TTZiYWZpWkZUMENkeHIxTHNlUQ==';
  // المفتاح السري يُدار بأمان داخل الباك إند فقط ولا يُكشف في كود العميل
  static const String secretKey = '';
  static const String publicKey = 'egy_pk_test_c1URlgIikWqBhemvLwrzCzwtbjaPqEkv';
  static const String hmacKey = 'EAD8080AD27DE7CCF649ABC25B991C6F';

  // =========================================================================
  // 3. INTEGRATION IDs (من لوحة تحكم Paymob -> Settings -> Payment Integrations)
  // =========================================================================
  static const int cardIntegrationId = 6063409; // معرّف بطاقات الائتمان (Online Card)
  static const int walletIntegrationId = 0; // معرّف المحافظ الإلكترونية (لم يتم تفعيله بعد)
  static const int iframeId = 1099047; // معرّف الإطار المضمن

  // العملة الافتراضية
  static const String currency = 'EGP';

  // =========================================================================
  // 4. OFFICIAL TEST CREDENTIALS (بيانات الاختبار الرسمية من الدكيومنتيشن)
  // =========================================================================
  static const String testCardNumber = '4111111111111111';
  static const String testCardHolder = 'Test Account';
  static const String testCardExpiryMonth = '01';
  static const String testCardExpiryYear = '39';
  static const String testCardExpiry = '01/39';
  static const String testCardCvv = '123';

  static const String testWalletNumber = '01010101010';
  static const String testWalletMpin = '123456';
  static const String testWalletOtp = '123456';
}

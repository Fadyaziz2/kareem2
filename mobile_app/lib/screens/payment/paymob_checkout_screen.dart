import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/paymob_constants.dart';
import '../../core/theme.dart';
import '../../models/contract_model.dart';
import '../../models/template_model.dart';
import '../../services/api_service.dart';
import 'payment_success_screen.dart';

class PaymobCheckoutScreen extends StatefulWidget {
  final TemplateModel template;
  final double amount;
  final String contractType; // 'instant' | 'lawyer_review'
  final Map<String, dynamic> filledVariables;
  final String? assignedLawyerId;

  const PaymobCheckoutScreen({
    super.key,
    required this.template,
    required this.amount,
    required this.contractType,
    required this.filledVariables,
    this.assignedLawyerId,
  });

  @override
  State<PaymobCheckoutScreen> createState() => _PaymobCheckoutScreenState();
}

class _PaymobCheckoutScreenState extends State<PaymobCheckoutScreen> {
  String _selectedMethod = 'card'; // 'card' | 'wallet'
  bool _isProcessing = false;
  String? _errorMessage;

  // Card Form Controllers
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  // Wallet Form Controller
  final _walletPhoneController = TextEditingController();

  final _cardFormKey = GlobalKey<FormState>();
  final _walletFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Default test cardholder
    _cardHolderController.text = 'عميل عقودي';
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _walletPhoneController.dispose();
    super.dispose();
  }

  // Pre-fill Test Card Credentials from Paymob Documentation
  void _fillTestCard() {
    setState(() {
      _cardNumberController.text = '4111 1111 1111 1111';
      _cardHolderController.text = PaymobConstants.testCardHolder;
      _expiryController.text = PaymobConstants.testCardExpiry;
      _cvvController.text = PaymobConstants.testCardCvv;
      _errorMessage = null;
    });
  }

  // Pre-fill Test Wallet Credentials from Paymob Documentation
  void _fillTestWallet() {
    setState(() {
      _walletPhoneController.text = PaymobConstants.testWalletNumber;
      _errorMessage = null;
    });
  }

  Future<void> _processPayment() async {
    final isCard = _selectedMethod == 'card';
    if (isCard) {
      if (!_cardFormKey.currentState!.validate()) return;
    } else {
      if (!_walletFormKey.currentState!.validate()) return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Step 1: Initiate Paymob Order & Payment Key on Backend
      final initData = await ApiService().initiatePaymobPayment(
        amount: widget.amount,
        title: 'عقد: ${widget.template.title}',
        type: 'contract',
        paymentMethod: _selectedMethod,
      );

      final paymentToken = initData['paymentToken'] as String;
      final orderId = initData['orderId'].toString();

      // Step 2: Prepare Payment Payload
      Map<String, String>? cardData;
      String? walletNumber;

      if (isCard) {
        final expiryParts = _expiryController.text.trim().split('/');
        final expMonth = expiryParts.isNotEmpty ? expiryParts[0].trim() : '01';
        final expYear = expiryParts.length > 1 ? expiryParts[1].trim() : '39';

        cardData = {
          'cardNumber': _cardNumberController.text.replaceAll(' ', ''),
          'cardholderName': _cardHolderController.text.trim(),
          'expiryMonth': expMonth,
          'expiryYear': expYear,
          'cvv': _cvvController.text.trim(),
        };
      } else {
        walletNumber = _walletPhoneController.text.trim();
      }

      // Step 3: Process Payment via Paymob & Generate Paid Contract
      final processResult = await ApiService().processPaymobPayment(
        paymentToken: paymentToken,
        orderId: orderId,
        paymentMethod: _selectedMethod,
        amount: widget.amount,
        cardData: cardData,
        walletNumber: walletNumber,
        contractData: {
          'templateId': widget.template.id,
          'contractType': widget.contractType,
          'filledVariables': widget.filledVariables,
          'assignedLawyerId': widget.assignedLawyerId,
        },
        description: 'شراء وتوثيق عقد: ${widget.template.title} عبر باي موب',
      );

      if (!mounted) return;

      final contractJson = processResult['contract'];
      ContractModel? contract;
      if (contractJson != null) {
        contract = ContractModel.fromJson(contractJson);
      }

      // Navigate to Payment Success Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            transactionId: processResult['paymobTransactionId']?.toString() ?? 'PMB-OK',
            paymobOrderId: processResult['paymobOrderId']?.toString() ?? orderId,
            amount: widget.amount,
            paymentMethod: _selectedMethod,
            isLive: processResult['isLive'] == true,
            contract: contract,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OqoodyTheme.primaryDark,
      appBar: AppBar(
        title: const Text('بوابة الدفع الإلكتروني (Paymob)', style: TextStyle(color: OqoodyTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: OqoodyTheme.primaryDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: OqoodyTheme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: OqoodyTheme.primaryEmerald),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('تفاصيل طلب شراء العقد', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 12)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: PaymobConstants.isLiveMode ? OqoodyTheme.successGreen.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: PaymobConstants.isLiveMode ? OqoodyTheme.successGreen : OqoodyTheme.accentGold,
                              ),
                            ),
                            child: const Text(
                              PaymobConstants.isLiveMode ? 'بوابة حية (Live)' : 'بيئة اختبار (Test Mode)',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: PaymobConstants.isLiveMode ? OqoodyTheme.successGreen : OqoodyTheme.accentGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.template.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.contractType == 'lawyer_review' ? 'صياغة ومراجعة محامٍ معتمد' : 'توليد وتوثيق فوري',
                            style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 13),
                          ),
                          Text(
                            '${widget.amount.toStringAsFixed(0)} ج.م',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Payment Method Selector (Tabs)
                const Text('اختر وسيلة الدفع عبر Paymob:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold)),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _buildMethodTab(
                        title: 'بطاقة بنكية',
                        subtitle: 'Visa / Mastercard / ميزة',
                        icon: Icons.credit_card,
                        methodKey: 'card',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMethodTab(
                        title: 'محفظة إلكترونية',
                        subtitle: 'فودافون كاش / أورنج / وي',
                        icon: Icons.account_balance_wallet_outlined,
                        methodKey: 'wallet',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Error Message if any
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: OqoodyTheme.alertRed.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: OqoodyTheme.alertRed),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: OqoodyTheme.alertRed, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_errorMessage!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                // Selected Form: Card vs Wallet
                if (_selectedMethod == 'card') _buildCardPaymentForm() else _buildWalletPaymentForm(),

                const SizedBox(height: 28),

                // Secure Pay Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OqoodyTheme.accentGold,
                      foregroundColor: OqoodyTheme.primaryDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                    onPressed: _isProcessing ? null : _processPayment,
                    icon: const Icon(Icons.lock, size: 18),
                    label: Text(
                      _isProcessing ? 'جاري معالجة الدفع عبر Paymob...' : 'إتمام الدفع الآمن (${widget.amount.toStringAsFixed(0)} ج.م)',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Security Note
                const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield, size: 14, color: OqoodyTheme.textMuted),
                      SizedBox(width: 6),
                      Text(
                        'دفع آمن 100% ومشفر بواسطة بوابة Paymob المعتمدة لدى البنك المركزي المصري',
                        style: TextStyle(fontSize: 10, color: OqoodyTheme.textMuted),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // Processing Loading Overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.65),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: OqoodyTheme.accentGold),
                    SizedBox(height: 16),
                    Text(
                      'جاري الاتصال الآمن مع بوابة باي موب...',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMethodTab({
    required String title,
    required String subtitle,
    required IconData icon,
    required String methodKey,
  }) {
    final isSelected = _selectedMethod == methodKey;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = methodKey;
          _errorMessage = null;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? OqoodyTheme.primaryEmerald.withOpacity(0.3) : OqoodyTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? OqoodyTheme.accentGold : OqoodyTheme.primaryEmerald,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? OqoodyTheme.accentGold : OqoodyTheme.textMuted, size: 26),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? OqoodyTheme.accentGold : Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: OqoodyTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  // Credit Card Form with Live Visual Card Preview
  Widget _buildCardPaymentForm() {
    return Form(
      key: _cardFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Credit Card Visual
          Container(
            width: double.infinity,
            height: 170,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F3822), Color(0xFF071C11), Color(0xFF020C07)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: OqoodyTheme.accentGold.withOpacity(0.6), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.nfc, color: OqoodyTheme.accentGold, size: 24),
                    const Text('PAYMOB', style: TextStyle(color: OqoodyTheme.accentGold, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 13)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: OqoodyTheme.accentGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('DEBIT / CREDIT', style: TextStyle(color: OqoodyTheme.accentGold, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Text(
                  _cardNumberController.text.isEmpty ? '••••  ••••  ••••  ••••' : _cardNumberController.text,
                  style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2.2, fontWeight: FontWeight.w600),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('حامل البطاقة', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 9)),
                        Text(
                          _cardHolderController.text.isEmpty ? 'TEST ACCOUNT' : _cardHolderController.text.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('تاريخ الانتهاء', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 9)),
                        Text(
                          _expiryController.text.isEmpty ? 'MM/YY' : _expiryController.text,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Test Mode Quick Autofill Button
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: OqoodyTheme.accentGold),
                foregroundColor: OqoodyTheme.accentGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: _fillTestCard,
              icon: const Icon(Icons.bolt, size: 16),
              label: const Text('تعبئة بطاقة الاختبار الرسمية (Test Card)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 16),

          // Card Number Field
          TextFormField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberInputFormatter(),
            ],
            style: const TextStyle(color: Colors.white, letterSpacing: 1.5),
            decoration: const InputDecoration(
              labelText: 'رقم البطاقة (16 رقم)',
              prefixIcon: Icon(Icons.credit_card, color: OqoodyTheme.accentGold),
              hintText: '4111 1111 1111 1111',
            ),
            onChanged: (_) => setState(() {}),
            validator: (val) {
              if (val == null || val.replaceAll(' ', '').length < 16) {
                return 'يرجى إدخال 16 رقماً للبطاقة';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          // Cardholder Name
          TextFormField(
            controller: _cardHolderController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'الاسم كما يظهر على البطاقة',
              prefixIcon: Icon(Icons.person, color: OqoodyTheme.accentGold),
              hintText: 'Test Account',
            ),
            onChanged: (_) => setState(() {}),
            validator: (val) => val == null || val.trim().isEmpty ? 'يرجى إدخال الاسم على البطاقة' : null,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              // Expiry Date (MM/YY)
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpiryDateInputFormatter(),
                  ],
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'الانتهاء (MM/YY)',
                    prefixIcon: Icon(Icons.date_range, color: OqoodyTheme.accentGold),
                    hintText: '01/39',
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (val) {
                    if (val == null || !val.contains('/') || val.length < 5) {
                      return 'الصيغة MM/YY';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              // CVV
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'رمز الأمان (CVV)',
                    prefixIcon: Icon(Icons.lock_outline, color: OqoodyTheme.accentGold),
                    hintText: '123',
                  ),
                  validator: (val) {
                    if (val == null || val.length < 3) {
                      return '3 أرقام';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Mobile Wallet Form (Vodafone, Orange, Etisalat, WE)
  Widget _buildWalletPaymentForm() {
    return Form(
      key: _walletFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: OqoodyTheme.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: OqoodyTheme.primaryEmerald),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المحافظ الإلكترونية المعتمدة في مصر:',
                  style: TextStyle(color: OqoodyTheme.accentGold, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _WalletBadge('فودافون كاش'),
                    _WalletBadge('أورنج كاش'),
                    _WalletBadge('اتصالات كاش'),
                    _WalletBadge('وي باي WE Pay'),
                    _WalletBadge('المحافظ البنكية (Smart Wallet)'),
                  ],
                ),
                SizedBox(height: 14),
                Divider(color: OqoodyTheme.primaryEmerald),
                SizedBox(height: 10),
                Text(
                  'سيصلك إشعار فوري من محفظتك برقم سري لتأكيد الخصم (OTP).',
                  style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Test Mode Quick Autofill Button
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: OqoodyTheme.accentGold),
                foregroundColor: OqoodyTheme.accentGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: _fillTestWallet,
              icon: const Icon(Icons.bolt, size: 16),
              label: const Text('تعبئة المحفظة التجريبية (01010101010)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _walletPhoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.2),
            decoration: const InputDecoration(
              labelText: 'رقم هاتف المحفظة الإلكترونية',
              hintText: '01010101010',
              prefixIcon: Icon(Icons.phone_android, color: OqoodyTheme.accentGold),
            ),
            validator: (val) {
              if (val == null || val.trim().length != 11) {
                return 'يرجى إدخال رقم هاتف محفظة صحيح مكون من 11 رقماً';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _WalletBadge extends StatelessWidget {
  final String label;
  const _WalletBadge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: OqoodyTheme.primaryDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: OqoodyTheme.accentGold.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// Card Number Formatter (4 4 4 4)
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(' ', '');
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// Expiry Date Formatter (MM/YY)
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll('/', '');
    if (text.length > 4) text = text.substring(0, 4);

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 2) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

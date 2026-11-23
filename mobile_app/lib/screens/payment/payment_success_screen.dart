import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/contract_model.dart';
import '../contracts/contract_pdf_viewer_screen.dart';
import '../home/main_wrapper_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String transactionId;
  final String paymobOrderId;
  final double amount;
  final String paymentMethod;
  final bool isLive;
  final ContractModel? contract;

  const PaymentSuccessScreen({
    super.key,
    required this.transactionId,
    required this.paymobOrderId,
    required this.amount,
    required this.paymentMethod,
    this.isLive = false,
    this.contract,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OqoodyTheme.primaryDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Gold/Emerald Success Badge
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: OqoodyTheme.successGreen.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: OqoodyTheme.accentGold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: OqoodyTheme.accentGold.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: OqoodyTheme.accentGold,
                    size: 54,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'تم الدفع وتوثيق العقد بنجاح!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLive ? OqoodyTheme.successGreen.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isLive ? OqoodyTheme.successGreen : OqoodyTheme.accentGold,
                        ),
                      ),
                      child: Text(
                        isLive ? 'بوابة باي موب الحية (Live)' : 'بيئة اختبار باي موب (Paymob Test)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isLive ? OqoodyTheme.successGreen : OqoodyTheme.accentGold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Digital Receipt Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: OqoodyTheme.cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: OqoodyTheme.primaryEmerald),
                  ),
                  child: Column(
                    children: [
                      _receiptRow('المبلغ المسدد', '${amount.toStringAsFixed(0)} ج.م', isGold: true),
                      const Divider(color: OqoodyTheme.primaryEmerald, height: 24),
                      _receiptRow('وسيلة الدفع', paymentMethod == 'wallet' ? 'محفظة إلكترونية' : 'بطاقة بنكية'),
                      const Divider(color: OqoodyTheme.primaryEmerald, height: 24),
                      _receiptRow('رقم المعاملة (Paymob)', transactionId),
                      const Divider(color: OqoodyTheme.primaryEmerald, height: 24),
                      _receiptRow('رقم أمر الشراء', paymobOrderId),
                      if (contract != null) ...[
                        const Divider(color: OqoodyTheme.primaryEmerald, height: 24),
                        _receiptRow('اسم العقد', contract!.title),
                        const Divider(color: OqoodyTheme.primaryEmerald, height: 24),
                        _receiptRow('حالة التوثيق', 'ساري وموثق قانونياً'),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Primary CTA: View Contract PDF
                if (contract != null)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OqoodyTheme.accentGold,
                        foregroundColor: OqoodyTheme.primaryDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ContractPdfViewerScreen(contract: contract!),
                          ),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf, size: 20),
                      label: const Text(
                        'عرض وتحميل العقد الآن (PDF)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // Secondary CTA: Back to Home
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: OqoodyTheme.accentGold),
                      foregroundColor: OqoodyTheme.accentGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MainWrapperScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text('العودة للرئيسية', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool isGold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 13),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: isGold ? OqoodyTheme.accentGold : Colors.white,
              fontWeight: isGold ? FontWeight.bold : FontWeight.w600,
              fontSize: isGold ? 16 : 13,
            ),
          ),
        ),
      ],
    );
  }
}

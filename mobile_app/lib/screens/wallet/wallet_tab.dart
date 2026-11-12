import 'package:flutter/material.dart';
import '../../core/theme.dart';

class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OqoodyTheme.primaryDark,
        title: const Text('المحفظة والعمليات المالية', style: TextStyle(color: OqoodyTheme.accentGold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: OqoodyTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: OqoodyTheme.primaryEmerald),
              ),
              child: Column(
                children: [
                  const Text('الرصيد المتاح للسحب أو الاستخدام', style: TextStyle(color: OqoodyTheme.textMuted)),
                  const SizedBox(height: 8),
                  const Text('12,450 ج.م', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('شحن المحفظة')),
                      const SizedBox(width: 14),
                      OutlinedButton.icon(
                        onPressed: () {}, 
                        icon: const Icon(Icons.arrow_upward, color: OqoodyTheme.accentGold), 
                        label: const Text('سحب أرباح', style: TextStyle(color: OqoodyTheme.textLight)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerRight,
              child: Text('سجل المعاملات الأخيرة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.security, color: OqoodyTheme.accentGold),
                    title: Text('حجز دفعة وساطة #402'),
                    subtitle: Text('10 نوفمبر 2026'),
                    trailing: Text('- 15,000 ج.م', style: TextStyle(color: OqoodyTheme.alertRed, fontWeight: FontWeight.bold)),
                  ),
                  Divider(color: OqoodyTheme.cardBg),
                  ListTile(
                    leading: Icon(Icons.arrow_downward, color: OqoodyTheme.successGreen),
                    title: Text('تحرير دفعة استشارة قانونية'),
                    subtitle: Text('08 نوفمبر 2026'),
                    trailing: Text('+ 350 ج.م', style: TextStyle(color: OqoodyTheme.successGreen, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

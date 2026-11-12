import 'package:flutter/material.dart';
import '../../core/theme.dart';

class EscrowTab extends StatelessWidget {
  const EscrowTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OqoodyTheme.primaryDark,
        title: const Text('الوساطة وحماية المعاملات (Escrow)', style: TextStyle(color: OqoodyTheme.accentGold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [OqoodyTheme.primaryDark, OqoodyTheme.primaryEmerald],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: OqoodyTheme.accentGold),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('إجمالي الأموال المحمية بالضمان', style: TextStyle(color: OqoodyTheme.textMuted)),
                  SizedBox(height: 8),
                  Text('50,000 ج.م', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold)),
                  SizedBox(height: 12),
                  Text('العملية الحالية: تطوير نظام تجاري إلكتروني', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('مراحل التنفيذ والدفعات (Milestones)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold)),
            const SizedBox(height: 12),
            _milestoneStep(1, 'الدفعة الأولى 30% (تم التحرير)', 'تسليم التصاميم وهيكل قواعد البيانات.', true, false),
            _milestoneStep(2, 'الدفعة الثانية 40% (تحت التنفيذ)', 'برمجة لوحة التحكم وتطبيقات الموبايل.', false, true),
            _milestoneStep(3, 'الدفعة النهائية 30% (محتجزة)', 'الفحص النهائي والنشر على المتاجر.', false, false),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: OqoodyTheme.successGreen),
                    child: const Text('تأكيد الاستلام والإفراج'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: OqoodyTheme.alertRed),
                    child: const Text('تصعيد وفتح نزاع'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _milestoneStep(int number, String title, String desc, bool isDone, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OqoodyTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? OqoodyTheme.accentGold : Colors.transparent),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isDone ? OqoodyTheme.successGreen : (isActive ? OqoodyTheme.accentGold : Colors.grey[700]),
            child: Text('$number', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? OqoodyTheme.accentGold : Colors.white)),
                Text(desc, style: const TextStyle(fontSize: 12, color: OqoodyTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

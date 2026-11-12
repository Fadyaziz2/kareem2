import 'package:flutter/material.dart';
import '../../core/theme.dart';

class LawyersTab extends StatelessWidget {
  const LawyersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OqoodyTheme.primaryDark,
        title: const Text('دليل المحامين المعتمدين', style: TextStyle(color: OqoodyTheme.accentGold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _lawyerCard('أ/ أحمد الشناوي', 'محامٍ بالنقض - عقود وشركات تجارية', '4.9 ★ (120 استشارة)', '300 ج.م'),
          _lawyerCard('أ/ مروة عبد العزيز', 'محامية استئناف - نزاعات مالية وعقارية', '4.8 ★ (85 استشارة)', '250 ج.م'),
          _lawyerCard('أ/ سامح القاضي', 'محامٍ بالنقض - قضايا عمل ومنازعات تجارية', '5.0 ★ (210 استشارة)', '400 ج.م'),
        ],
      ),
    );
  }

  Widget _lawyerCard(String name, String spec, String rating, String price) {
    return Card(
      color: OqoodyTheme.cardBg,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            const CircleAvatar(radius: 28, backgroundColor: OqoodyTheme.accentGold, child: Icon(Icons.person, color: OqoodyTheme.primaryDark, size: 30)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(spec, style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(rating, style: const TextStyle(color: OqoodyTheme.accentGold, fontSize: 12)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              child: const Text('طلب استشارة', style: TextStyle(fontSize: 12)),
            )
          ],
        ),
      ),
    );
  }
}

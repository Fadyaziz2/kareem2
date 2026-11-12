import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ContractsTab extends StatelessWidget {
  const ContractsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: OqoodyTheme.primaryDark,
          title: const Text('إدارة ونماذج العقود', style: TextStyle(color: OqoodyTheme.accentGold)),
          bottom: const TabBar(
            indicatorColor: OqoodyTheme.accentGold,
            labelColor: OqoodyTheme.accentGold,
            unselectedLabelColor: OqoodyTheme.textMuted,
            tabs: [
              Tab(text: 'النماذج الجاهزة'),
              Tab(text: 'طلب صياغة خاصة'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _templateCard(context, 'عقد إيجار وحدة سكنية', 'يشمل بنود الصيانة، التأمين، وفسخ العقد التلقائي.', '150 ج.م'),
                _templateCard(context, 'عقد بيع سيارة نهائي', 'موثق قانونياً مع إقرارات استلام وفحص شاملة.', '200 ج.م'),
                _templateCard(context, 'عقد شراكة وتأسيس شركة', 'توزيع الحصص، التخارج، والمسؤوليات الإدارية.', '350 ج.م'),
                _templateCard(context, 'اتفاقية عدم إفصاح (NDA)', 'حماية الأسرار التجارية والبرمجيات والمشاريع.', '100 ج.م'),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('طلب كتابة وصياغة عقد خاص بواسطة محامٍ معتمد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const TextField(
                    maxLines: 4,
                    decoration: InputDecoration(hintText: 'اكتب تفاصيل الصفقة، الشروط الخاصة، والضمانات المطلوبة...'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.attach_file),
                    label: const Text('إرفاق مسودات أو مستندات'),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('إرسال لتلقي عروض المحامين'),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _templateCard(BuildContext context, String title, String subtitle, String price) {
    return Card(
      color: OqoodyTheme.cardBg,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(price, style: const TextStyle(color: OqoodyTheme.accentGold, fontWeight: FontWeight.bold)),
            const Icon(Icons.arrow_forward_ios, size: 14, color: OqoodyTheme.textMuted),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OqoodyTheme.primaryDark,
        title: const Text('عقودي', style: TextStyle(color: OqoodyTheme.accentGold, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined, color: OqoodyTheme.accentGold)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: OqoodyTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: OqoodyTheme.primaryEmerald),
              ),
              child: const Row(
                children: [
                  CircleAvatar(radius: 26, backgroundColor: OqoodyTheme.accentGold, child: Icon(Icons.person, color: OqoodyTheme.primaryDark)),
                  SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('مرحباً بك 👋', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('منصتك لحماية حقوقك وتعاملاتك', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('الخدمات السريعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold)),
            const SizedBox(height: 14),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildActionCard(Icons.library_books, 'نماذج العقود'),
                _buildActionCard(Icons.draw, 'عقد مخصص'),
                _buildActionCard(Icons.handshake, 'وساطة آمنة'),
                _buildActionCard(Icons.support_agent, 'استشارة محامٍ'),
                _buildActionCard(Icons.gavel, 'غرفة النزاع'),
                _buildActionCard(Icons.account_balance, 'حساب الضمان'),
              ],
            ),
            const SizedBox(height: 24),
            const Text('عملياتي الجارية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: OqoodyTheme.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: const Border(right: BorderSide(color: OqoodyTheme.accentGold, width: 4)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('عقد توريد معدات برمجية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Chip(
                        label: Text('دفعة 1: محتجزة', style: TextStyle(fontSize: 11, color: Colors.white)),
                        backgroundColor: OqoodyTheme.primaryEmerald,
                      )
                    ],
                  ),
                  SizedBox(height: 6),
                  Text('المبلغ المحتجز في الضمان: 45,000 ج.م', style: TextStyle(color: OqoodyTheme.textMuted)),
                  SizedBox(height: 8),
                  LinearProgressIndicator(value: 0.33, color: OqoodyTheme.accentGold, backgroundColor: OqoodyTheme.bgDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: OqoodyTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OqoodyTheme.primaryEmerald.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: OqoodyTheme.accentGold, size: 28),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/lawyer_model.dart';
import '../consultations/book_consultation_screen.dart';

class LawyerProfileScreen extends StatelessWidget {
  final LawyerModel lawyer;

  const LawyerProfileScreen({super.key, required this.lawyer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف التعريفي للمحامي'),
        centerTitle: true,
        backgroundColor: OqoodyTheme.primaryDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: OqoodyTheme.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: OqoodyTheme.primaryEmerald),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: OqoodyTheme.accentGold.withOpacity(0.2),
                        child: const Icon(Icons.person, size: 52, color: OqoodyTheme.accentGold),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: OqoodyTheme.successGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified, size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    lawyer.fullName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: OqoodyTheme.primaryDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: OqoodyTheme.accentGold.withOpacity(0.5)),
                        ),
                        child: Text(
                          'محامٍ مقيد بجدول: ${lawyer.degree}',
                          style: const TextStyle(color: OqoodyTheme.accentGold, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: OqoodyTheme.primaryDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              lawyer.rating.toStringAsFixed(1),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: OqoodyTheme.primaryEmerald),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoColumn('رقم القيد بالنقابة', lawyer.barNumber.isNotEmpty ? lawyer.barNumber : '654321'),
                      _buildInfoColumn('المدينة', lawyer.city),
                      _buildInfoColumn('الاستشارات المنجزة', '${lawyer.totalConsultations}'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Fee Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [OqoodyTheme.cardBg, OqoodyTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: OqoodyTheme.accentGold.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('سعر الاستشارة القانونية:', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 13)),
                      SizedBox(height: 4),
                      Text('محادثة كتابية / هاتفية / مكتبية', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                  Text(
                    '${lawyer.consultationRate.toStringAsFixed(0)} ج.م',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Bio
            const Text(
              'نبذة تعريفية وخبرات المحامي:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: OqoodyTheme.cardBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                lawyer.bio.isNotEmpty ? lawyer.bio : 'محامٍ ومستشار قانوني متخصص في صياغة العقود ومراجعتها وفض النزاعات التجارية.',
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
              ),
            ),

            const SizedBox(height: 20),

            // Specializations
            const Text(
              'مجالات التخصص:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: lawyer.specializations.isNotEmpty
                  ? lawyer.specializations.map((spec) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: OqoodyTheme.primaryEmerald.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: OqoodyTheme.primaryEmerald),
                        ),
                        child: Text(
                          spec,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      );
                    }).toList()
                  : [
                      'عقود تجارية',
                      'شركات واستثمار',
                      'نزاعات مدنية',
                      'عقارات وتمويل',
                    ].map((s) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: OqoodyTheme.primaryEmerald.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: OqoodyTheme.primaryEmerald),
                          ),
                          child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 13)),
                        )).toList(),
            ),

            const SizedBox(height: 32),

            // CTA Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookConsultationScreen(lawyer: lawyer),
                    ),
                  );
                },
                icon: const Icon(Icons.forum_outlined),
                label: const Text('طلب استشارة قانونية الآن'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
      ],
    );
  }
}


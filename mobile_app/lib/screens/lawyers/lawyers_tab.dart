import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/lawyer_model.dart';
import '../../models/consultation_model.dart';
import '../../services/api_service.dart';
import 'lawyer_profile_screen.dart';
import '../consultations/book_consultation_screen.dart';
import '../consultations/consultation_chat_room_screen.dart';

class LawyersTab extends StatefulWidget {
  const LawyersTab({super.key});

  @override
  State<LawyersTab> createState() => _LawyersTabState();
}

class _LawyersTabState extends State<LawyersTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<LawyerModel> _lawyers = [];
  bool _isLoadingLawyers = false;
  String _selectedDegree = 'الكل';
  String _searchQuery = '';

  List<ConsultationModel> _consultations = [];
  bool _isLoadingConsultations = false;

  final List<String> _degrees = ['الكل', 'ابتدائي', 'استئناف', 'نقض'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLawyers();
    _loadConsultations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLawyers() async {
    setState(() => _isLoadingLawyers = true);
    try {
      final list = await ApiService().getLawyers(
        degree: _selectedDegree == 'الكل' ? null : _selectedDegree,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
      if (mounted) {
        setState(() {
          _lawyers = list;
          _isLoadingLawyers = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingLawyers = false);
    }
  }

  Future<void> _loadConsultations() async {
    setState(() => _isLoadingConsultations = true);
    try {
      final list = await ApiService().getConsultations();
      if (mounted) {
        setState(() {
          _consultations = list;
          _isLoadingConsultations = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingConsultations = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OqoodyTheme.primaryDark,
        title: const Text('المحامون والاستشارات', style: TextStyle(color: OqoodyTheme.accentGold, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: OqoodyTheme.accentGold,
          labelColor: OqoodyTheme.accentGold,
          unselectedLabelColor: OqoodyTheme.textMuted,
          tabs: const [
            Tab(text: 'دليل المحامين'),
            Tab(text: 'استشاراتي الجارية'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Lawyers Directory
          RefreshIndicator(
            onRefresh: _loadLawyers,
            color: OqoodyTheme.accentGold,
            child: Column(
              children: [
                // Search Input
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    onChanged: (val) {
                      _searchQuery = val;
                      _loadLawyers();
                    },
                    decoration: InputDecoration(
                      hintText: 'ابحث باسم المحامي أو التخصص...',
                      prefixIcon: const Icon(Icons.search, color: OqoodyTheme.accentGold),
                      filled: true,
                      fillColor: OqoodyTheme.cardBg,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Degree Filter Chips
                SizedBox(
                  height: 46,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _degrees.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final deg = _degrees[idx];
                      final isSelected = _selectedDegree == deg;
                      return ChoiceChip(
                        label: Text(deg == 'الكل' ? 'جميع الدرجات' : 'محامٍ $deg'),
                        selected: isSelected,
                        selectedColor: OqoodyTheme.accentGold,
                        backgroundColor: OqoodyTheme.cardBg,
                        labelStyle: TextStyle(
                          color: isSelected ? OqoodyTheme.primaryDark : OqoodyTheme.textLight,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedDegree = deg);
                            _loadLawyers();
                          }
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // Lawyers List
                Expanded(
                  child: _isLoadingLawyers
                      ? const Center(child: CircularProgressIndicator(color: OqoodyTheme.accentGold))
                      : _lawyers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.person_search_outlined, size: 64, color: OqoodyTheme.textMuted),
                                  const SizedBox(height: 12),
                                  const Text('لم يتم العثور على محامين متطابقين', style: TextStyle(color: OqoodyTheme.textMuted)),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: _loadLawyers,
                                    child: const Text('إعادة المحاولة'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _lawyers.length,
                              itemBuilder: (context, index) {
                                final lawyer = _lawyers[index];
                                return _buildLawyerCard(lawyer);
                              },
                            ),
                ),
              ],
            ),
          ),

          // TAB 2: My Consultations
          RefreshIndicator(
            onRefresh: _loadConsultations,
            color: OqoodyTheme.accentGold,
            child: _isLoadingConsultations
                ? const Center(child: CircularProgressIndicator(color: OqoodyTheme.accentGold))
                : _consultations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.forum_outlined, size: 64, color: OqoodyTheme.textMuted),
                            const SizedBox(height: 12),
                            const Text('لا توجد استشارات سابقة أو جارية', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 15)),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () => _tabController.animateTo(0),
                              icon: const Icon(Icons.add),
                              label: const Text('استشر محامياً الآن'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _consultations.length,
                        itemBuilder: (context, index) {
                          final c = _consultations[index];
                          return _buildConsultationCard(c);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLawyerCard(LawyerModel lawyer) {
    return Card(
      color: OqoodyTheme.cardBg,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: OqoodyTheme.primaryEmerald),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: OqoodyTheme.primaryDark,
                      child: Icon(Icons.person, color: OqoodyTheme.accentGold, size: 34),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Icon(Icons.verified, size: 16, color: OqoodyTheme.successGreen),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lawyer.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: OqoodyTheme.primaryDark,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'جدول ${lawyer.degree}',
                              style: const TextStyle(color: OqoodyTheme.accentGold, fontSize: 11),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 13),
                              const SizedBox(width: 3),
                              Text(lawyer.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              Text(' (${lawyer.totalConsultations})', style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lawyer.bio,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: OqoodyTheme.primaryEmerald, height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${lawyer.consultationRate.toStringAsFixed(0)} ج.م / استشارة',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold, fontSize: 14),
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LawyerProfileScreen(lawyer: lawyer),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: OqoodyTheme.primaryEmerald),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('الملف الشخصي', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookConsultationScreen(lawyer: lawyer),
                          ),
                        ).then((_) => _loadConsultations());
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: const Text('طلب استشارة', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultationCard(ConsultationModel c) {
    Color statusColor;
    switch (c.status) {
      case 'completed':
        statusColor = OqoodyTheme.successGreen;
        break;
      case 'in_progress':
        statusColor = OqoodyTheme.accentGold;
        break;
      default:
        statusColor = Colors.amber;
    }

    return Card(
      color: OqoodyTheme.cardBg,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: statusColor.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.15),
          child: Icon(Icons.forum, color: statusColor),
        ),
        title: Text(c.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(c.lawyerName != null ? 'المحامي: ${c.lawyerName}' : 'طلب استشارة مفتوح', style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(c.statusArabic, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Text(c.typeArabic, style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 11)),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: OqoodyTheme.textMuted),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConsultationChatRoomScreen(consultation: c),
            ),
          ).then((_) => _loadConsultations());
        },
      ),
    );
  }
}

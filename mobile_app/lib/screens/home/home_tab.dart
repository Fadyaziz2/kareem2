import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/escrow_model.dart';
import '../../models/consultation_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../contracts/contracts_tab.dart';
import '../escrow/create_escrow_screen.dart';
import '../escrow/escrow_room_details_screen.dart';
import '../lawyers/lawyers_tab.dart';
import '../consultations/consultation_chat_room_screen.dart';
import '../profile/profile_screen.dart';
import '../wallet/wallet_tab.dart';
import '../lawyers/lawyer_dashboard_tab.dart';

class HomeTab extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const HomeTab({super.key, this.onNavigateTab});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  EscrowModel? _activeEscrow;
  ConsultationModel? _activeConsultation;

  @override
  void initState() {
    super.initState();
    _loadLiveDashboard();
  }

  Future<void> _loadLiveDashboard() async {
    try {
      final escrows = await ApiService().getEscrows();
      final consultations = await ApiService().getConsultations();

      if (mounted) {
        setState(() {
          _activeEscrow = escrows.isNotEmpty ? escrows.first : null;
          _activeConsultation = consultations.isNotEmpty ? consultations.first : null;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: OqoodyTheme.primaryDark,
        title: const Text('عقودي - Oqoody', style: TextStyle(color: OqoodyTheme.accentGold, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
            icon: const Icon(Icons.account_circle, color: OqoodyTheme.accentGold, size: 28),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadLiveDashboard,
        color: OqoodyTheme.accentGold,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Welcome Hero Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [OqoodyTheme.primaryDark, OqoodyTheme.cardBg],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: OqoodyTheme.primaryEmerald),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: OqoodyTheme.accentGold,
                      child: Icon(Icons.person, color: OqoodyTheme.primaryDark, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مرحباً بك، ${user?.fullName ?? "مستخدم عقودي"} 👋',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.role == 'lawyer' ? 'أهلاً بك في منصتك القانونية كشريك معتمد' : 'حماية حقوقك المالية والقانونية بضمان رسمي',
                            style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions Grid
              const Text('الخدمات والحلول السريعة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold)),
              const SizedBox(height: 14),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.95,
                children: [
                  _buildActionCard(
                    icon: Icons.library_books,
                    title: 'نماذج العقود',
                    onTap: () {
                      if (widget.onNavigateTab != null) {
                        widget.onNavigateTab!(1);
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const Scaffold(body: ContractsTab())));
                      }
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.shield_outlined,
                    title: 'وساطة جديدة',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEscrowScreen())).then((_) => _loadLiveDashboard());
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.support_agent,
                    title: 'استشارة محامٍ',
                    onTap: () {
                      if (widget.onNavigateTab != null) {
                        widget.onNavigateTab!(3);
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const Scaffold(body: LawyersTab())));
                      }
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.account_balance_wallet,
                    title: 'محفظتي',
                    onTap: () {
                      if (widget.onNavigateTab != null) {
                        widget.onNavigateTab!(4);
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const Scaffold(body: WalletTab())));
                      }
                    },
                  ),
                  if (user?.role == 'lawyer')
                    _buildActionCard(
                      icon: Icons.dashboard_customize,
                      title: 'لوحة المحامي',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const Scaffold(body: LawyerDashboardTab())));
                      },
                    )
                  else
                    _buildActionCard(
                      icon: Icons.gavel,
                      title: 'غرفة التحكيم',
                      onTap: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(2);
                        }
                      },
                    ),
                  _buildActionCard(
                    icon: Icons.person_outline,
                    title: 'حسابي',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                    },
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // Active Escrow Deal Widget (from Live API)
              const Text('آخر عملية وساطة جارية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold)),
              const SizedBox(height: 10),

              if (_activeEscrow != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: OqoodyTheme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: const Border(right: BorderSide(color: OqoodyTheme.accentGold, width: 4)),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EscrowRoomDetailsScreen(escrow: _activeEscrow!)),
                      ).then((_) => _loadLiveDashboard());
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _activeEscrow!.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                              ),
                            ),
                            Chip(
                              label: Text(
                                _activeEscrow!.isDisputed ? 'نزاع مفتوح' : 'سارية بالضمان',
                                style: const TextStyle(fontSize: 10, color: Colors.white),
                              ),
                              backgroundColor: _activeEscrow!.isDisputed ? OqoodyTheme.alertRed : OqoodyTheme.primaryEmerald,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'المبلغ الإجمالي المحتجز: ${_activeEscrow!.totalAmount.toStringAsFixed(0)} ج.م',
                          style: const TextStyle(color: OqoodyTheme.accentGold, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'مراحل التنفيذ: ${_activeEscrow!.milestones.where((m) => m.isReleased).length} / ${_activeEscrow!.milestones.length} مكتملة',
                              style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 11),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_forward_ios, size: 12, color: OqoodyTheme.accentGold),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: OqoodyTheme.cardBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('لا توجد عمليات وساطة جارية حالياً', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 13)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEscrowScreen())).then((_) => _loadLiveDashboard());
                        },
                        child: const Text('ابدأ صفقة', style: TextStyle(color: OqoodyTheme.accentGold)),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Active Consultation Widget (from Live API)
              if (_activeConsultation != null) ...[
                const Text('آخر استشارة قانونية لك', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: OqoodyTheme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: OqoodyTheme.primaryEmerald),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ConsultationChatRoomScreen(consultation: _activeConsultation!)),
                      ).then((_) => _loadLiveDashboard());
                    },
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: OqoodyTheme.primaryEmerald,
                          child: Icon(Icons.forum, color: OqoodyTheme.accentGold, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _activeConsultation!.subject,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _activeConsultation!.lawyerName != null ? 'المحامي: ${_activeConsultation!.lawyerName}' : _activeConsultation!.typeArabic,
                                style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: OqoodyTheme.primaryDark,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _activeConsultation!.statusArabic,
                            style: const TextStyle(fontSize: 10, color: OqoodyTheme.accentGold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: OqoodyTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: OqoodyTheme.primaryEmerald),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: OqoodyTheme.accentGold, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

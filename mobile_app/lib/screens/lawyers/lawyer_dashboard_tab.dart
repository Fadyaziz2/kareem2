import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/consultation_model.dart';
import '../../models/contract_model.dart';
import '../consultations/consultation_chat_room_screen.dart';
import '../contracts/contract_pdf_viewer_screen.dart';

class LawyerDashboardTab extends StatefulWidget {
  const LawyerDashboardTab({super.key});

  @override
  State<LawyerDashboardTab> createState() => _LawyerDashboardTabState();
}

class _LawyerDashboardTabState extends State<LawyerDashboardTab> {
  bool _isLoading = true;
  List<ConsultationModel> _consultations = [];
  List<ContractModel> _reviewContracts = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final cList = await ApiService().getConsultations();
      final contractsList = await ApiService().getMyContracts();

      if (mounted) {
        setState(() {
          _consultations = cList;
          _reviewContracts = contractsList.where((c) => c.status == 'pending_review').toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final isApproved = user?.isVerified ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مكتبي القانوني (لوحة المحامي)'),
        backgroundColor: OqoodyTheme.primaryDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: OqoodyTheme.accentGold),
            onPressed: _loadDashboardData,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: OqoodyTheme.accentGold,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verification Status Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isApproved ? OqoodyTheme.successGreen.withOpacity(0.15) : OqoodyTheme.accentGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isApproved ? OqoodyTheme.successGreen.withOpacity(0.5) : OqoodyTheme.accentGold.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isApproved ? Icons.verified : Icons.hourglass_top,
                      color: isApproved ? OqoodyTheme.successGreen : OqoodyTheme.accentGold,
                      size: 32,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isApproved ? 'حسابك معتمد وموثق بنقابة المحامين' : 'طلب القيد قيد المراجعة النقابية',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isApproved ? OqoodyTheme.successGreen : OqoodyTheme.accentGold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isApproved
                              ? 'يمكنك استقبال الاستشارات وصياغة العقود وتحصيل أتعابك مباشرة.'
                              : 'يجري التحقق من بطاقة القيد بالنقابة. يمكنك تصفح المنصة حتى إتمام الاعتماد.',
                            style: const TextStyle(fontSize: 12, color: OqoodyTheme.textLight),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // KPI Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _statCard('الاستشارات الواردة', '${_consultations.length}', Icons.question_answer_outlined, OqoodyTheme.accentGold),
                  _statCard('طلبات مراجعة العقود', '${_reviewContracts.length}', Icons.assignment_outlined, OqoodyTheme.successGreen),
                  _statCard('رصيد أتعاب المحفظة', '${user?.walletBalance.toStringAsFixed(0) ?? 0} ج.م', Icons.account_balance_wallet_outlined, Colors.amber),
                  _statCard('نسبة عمولة المنصة', '15%', Icons.pie_chart_outline, Colors.lightBlueAccent),
                ],
              ),
              const SizedBox(height: 24),

              // Incoming Consultations Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الاستشارات القانونية الموجهة إليك', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold)),
                  Text('${_consultations.length} طلب', style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 10),

              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: OqoodyTheme.accentGold)))
              else if (_consultations.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: OqoodyTheme.cardBg, borderRadius: BorderRadius.circular(14)),
                  alignment: Alignment.center,
                  child: const Text('لا توجد استشارات جديدة موجهة إليك حالياً', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 13)),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _consultations.length,
                  itemBuilder: (ctx, i) {
                    final c = _consultations[i];
                    return Card(
                      color: OqoodyTheme.cardBg,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: OqoodyTheme.accentGold.withOpacity(0.2),
                          child: const Icon(Icons.chat_bubble_outline, color: OqoodyTheme.accentGold),
                        ),
                        title: Text(c.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('العميل: ${c.clientName} • ${c.typeArabic}', style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 11)),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ConsultationChatRoomScreen(consultation: c)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            textStyle: const TextStyle(fontSize: 11),
                          ),
                          child: const Text('الرد الآن'),
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),

              // Review Contracts Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('عقود تتطلب صياغة ومراجعة قانونية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold)),
                  Text('${_reviewContracts.length} عقود', style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 10),

              if (_reviewContracts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: OqoodyTheme.cardBg, borderRadius: BorderRadius.circular(14)),
                  alignment: Alignment.center,
                  child: const Text('لا توجد عقود معلقة بانتظار المراجعة القانونية', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 13)),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _reviewContracts.length,
                  itemBuilder: (ctx, i) {
                    final contract = _reviewContracts[i];
                    return Card(
                      color: OqoodyTheme.cardBg,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.description, color: OqoodyTheme.accentGold),
                        title: Text(contract.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('العميل: ${contract.clientName ?? 'عميل'} • أتعاب المراجعة: ${contract.price} ج.م', style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 11)),
                        trailing: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ContractPdfViewerScreen(contract: contract)),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: OqoodyTheme.accentGold),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          child: const Text('فحص واعتماد', style: TextStyle(color: OqoodyTheme.accentGold, fontSize: 11)),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: OqoodyTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OqoodyTheme.primaryEmerald),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: OqoodyTheme.textMuted)),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/escrow_model.dart';
import '../../models/dispute_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'create_escrow_screen.dart';
import 'escrow_room_details_screen.dart';
import '../disputes/dispute_details_screen.dart';

class EscrowTab extends StatefulWidget {
  const EscrowTab({super.key});

  @override
  State<EscrowTab> createState() => _EscrowTabState();
}

class _EscrowTabState extends State<EscrowTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<EscrowModel> _escrows = [];
  bool _isLoadingEscrows = false;

  List<DisputeModel> _disputes = [];
  bool _isLoadingDisputes = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEscrows();
    _loadDisputes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEscrows() async {
    setState(() => _isLoadingEscrows = true);
    try {
      final list = await ApiService().getEscrows();
      if (mounted) {
        setState(() {
          _escrows = list;
          _isLoadingEscrows = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingEscrows = false);
    }
  }

  Future<void> _loadDisputes() async {
    setState(() => _isLoadingDisputes = true);
    try {
      final list = await ApiService().getDisputes();
      if (mounted) {
        setState(() {
          _disputes = list;
          _isLoadingDisputes = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingDisputes = false);
    }
  }

  double get _totalHeldBalance {
    double total = 0.0;
    for (var e in _escrows) {
      if (e.status == 'active' || e.status == 'disputed') {
        for (var m in e.milestones) {
          if (!m.isReleased) total += m.amount;
        }
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OqoodyTheme.primaryDark,
        title: const Text('الوساطة وحماية المعاملات (Escrow)', style: TextStyle(color: OqoodyTheme.accentGold, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: OqoodyTheme.accentGold,
          labelColor: OqoodyTheme.accentGold,
          unselectedLabelColor: OqoodyTheme.textMuted,
          tabs: const [
            Tab(text: 'عمليات الضمان'),
            Tab(text: 'غرفة النزاعات والتحكيم'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: OqoodyTheme.accentGold,
        foregroundColor: OqoodyTheme.primaryDark,
        icon: const Icon(Icons.add_moderator),
        label: const Text('وساطة جديدة', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateEscrowScreen()),
          ).then((_) {
            _loadEscrows();
            _loadDisputes();
          });
        },
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Escrows
          RefreshIndicator(
            onRefresh: _loadEscrows,
            color: OqoodyTheme.accentGold,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Escrow Balance Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [OqoodyTheme.primaryDark, OqoodyTheme.primaryEmerald],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: OqoodyTheme.accentGold.withOpacity(0.6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('إجمالي الأموال المحمية بالضمان:', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 13)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: OqoodyTheme.cardBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${_escrows.length} عمليات',
                                style: const TextStyle(fontSize: 11, color: OqoodyTheme.accentGold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_totalHeldBalance.toStringAsFixed(0)} ج.م',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold),
                        ),
                        const SizedBox(height: 6),
                        const Text('حماية ثلاثية للأطراف: أموالك مجمدة حتى اكتمال شروط التسليم.', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text('قائمة عمليات الضمان الجارية والسابقة:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold)),
                  const SizedBox(height: 12),

                  if (_isLoadingEscrows)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: OqoodyTheme.accentGold)))
                  else if (_escrows.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            const Icon(Icons.shield_outlined, size: 60, color: OqoodyTheme.textMuted),
                            const SizedBox(height: 12),
                            const Text('لا توجد عمليات وساطة وضمان حالياً', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 15)),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const CreateEscrowScreen()),
                                ).then((_) => _loadEscrows());
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('ابدأ صفقة آمنة الآن'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._escrows.map((e) => _buildEscrowCard(e)),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),

          // TAB 2: Disputes
          RefreshIndicator(
            onRefresh: _loadDisputes,
            color: OqoodyTheme.accentGold,
            child: _isLoadingDisputes
                ? const Center(child: CircularProgressIndicator(color: OqoodyTheme.accentGold))
                : _disputes.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.gavel, size: 64, color: OqoodyTheme.textMuted),
                            SizedBox(height: 12),
                            Text('سجل النزاعات نظيف تماماً', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 16)),
                            SizedBox(height: 4),
                            Text('جميع صفقاتك وعقودك تمت بنجاح وبدون أي نزاعات.', style: TextStyle(color: Colors.white38, fontSize: 12)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _disputes.length,
                        itemBuilder: (context, index) {
                          final d = _disputes[index];
                          return _buildDisputeCard(d);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEscrowCard(EscrowModel escrow) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = auth.currentUser?.id ?? '';
    final isPartyA = escrow.isPartyA(currentUserId);

    Color statusColor;
    String statusText;

    if (escrow.isDisputed) {
      statusColor = OqoodyTheme.alertRed;
      statusText = 'نزاع مفتوح';
    } else if (escrow.isCompleted) {
      statusColor = OqoodyTheme.successGreen;
      statusText = 'مكتملة ومحررة';
    } else {
      statusColor = OqoodyTheme.accentGold;
      statusText = 'جارية ونشطة';
    }

    return Card(
      color: OqoodyTheme.cardBg,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withOpacity(0.4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EscrowRoomDetailsScreen(escrow: escrow)),
          ).then((_) => _loadEscrows());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      escrow.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                escrow.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: OqoodyTheme.primaryDark,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isPartyA ? 'أنت الطرف الأول (المشتري)' : 'أنت الطرف الثاني (المنفذ)',
                          style: const TextStyle(color: OqoodyTheme.accentGold, fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${escrow.milestones.length} مراحل', style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 11)),
                    ],
                  ),
                  Text(
                    '${escrow.totalAmount.toStringAsFixed(0)} ج.م',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisputeCard(DisputeModel dispute) {
    Color statusColor = dispute.isResolved ? OqoodyTheme.successGreen : OqoodyTheme.alertRed;
    String statusText = dispute.isResolved ? 'تم صدور الحكم' : 'قيد التحكيم';

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
          child: Icon(Icons.gavel, color: statusColor),
        ),
        title: Text(dispute.escrowTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('السبب: ${dispute.reason}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Text('المبلغ المجمد: ${dispute.milestoneAmount.toStringAsFixed(0)} ج.م', style: const TextStyle(color: OqoodyTheme.accentGold, fontSize: 11)),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: OqoodyTheme.textMuted),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DisputeDetailsScreen(dispute: dispute)),
          ).then((_) => _loadDisputes());
        },
      ),
    );
  }
}

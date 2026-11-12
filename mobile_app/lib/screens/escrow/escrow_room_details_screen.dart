import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/escrow_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../disputes/raise_dispute_screen.dart';

class EscrowRoomDetailsScreen extends StatefulWidget {
  final EscrowModel escrow;

  const EscrowRoomDetailsScreen({super.key, required this.escrow});

  @override
  State<EscrowRoomDetailsScreen> createState() => _EscrowRoomDetailsScreenState();
}

class _EscrowRoomDetailsScreenState extends State<EscrowRoomDetailsScreen> {
  late EscrowModel _escrow;

  @override
  void initState() {
    super.initState();
    _escrow = widget.escrow;
    _refreshEscrow();
  }

  Future<void> _refreshEscrow() async {
    try {
      final updated = await ApiService().getEscrowDetails(_escrow.id);
      if (mounted) {
        setState(() {
          _escrow = updated;
        });
      }
    } catch (_) {}
  }

  Future<void> _submitDeliverable(MilestoneModel milestone) async {
    final notesController = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OqoodyTheme.cardBg,
        title: Text('تسليم مخرج: ${milestone.title}', style: const TextStyle(color: OqoodyTheme.accentGold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('اكتب تفاصيل المخرج، روابط التحميل، أو إثبات التسليم:', style: TextStyle(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 10),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'رابط الملفات أو ملاحظات الإنجاز...'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: OqoodyTheme.textMuted))),
          ElevatedButton(
            onPressed: () async {
              if (notesController.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              try {
                final updated = await ApiService().submitMilestone(_escrow.id, milestone.id, notesController.text.trim());
                if (mounted) {
                  setState(() => _escrow = updated);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تقديم المخرج بنجاح وإشعار الطرف الأول'), backgroundColor: OqoodyTheme.successGreen),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('فشل التسليم: $e'), backgroundColor: OqoodyTheme.alertRed),
                  );
                }
              }
            },
            child: const Text('تأكيد التسليم'),
          ),
        ],
      ),
    );
  }

  Future<void> _releaseFunds(MilestoneModel milestone) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OqoodyTheme.cardBg,
        title: const Text('تأكيد تحرير وصرف الدفعة', style: TextStyle(color: OqoodyTheme.accentGold)),
        content: Text(
          'هل قمت بفحص مخرجات "${milestone.title}" وتؤكد تحرير مبلغ ${milestone.amount.toStringAsFixed(0)} ج.م للطرف الثاني؟\nهذا الإجراء نهائي ولا يمكن التراجع عنه.',
          style: const TextStyle(fontSize: 13, color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء', style: TextStyle(color: OqoodyTheme.textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: OqoodyTheme.successGreen),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('نعم، تحرير الدفعة فوراً'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final updated = await ApiService().releaseMilestone(_escrow.id, milestone.id);
      if (mounted) {
        setState(() => _escrow = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحرير الدفعة وتحويلها لمحفظة الطرف الثاني بنجاح!'), backgroundColor: OqoodyTheme.successGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحرير الدفعة: $e'), backgroundColor: OqoodyTheme.alertRed),
        );
      }
    }
  }

  double get _releasedPercentage {
    if (_escrow.milestones.isEmpty) return 0.0;
    double released = 0.0;
    for (var m in _escrow.milestones) {
      if (m.isReleased) released += m.percentage;
    }
    return released;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = auth.currentUser?.id ?? '';
    final isPartyA = _escrow.isPartyA(currentUserId);
    final isPartyB = _escrow.isPartyB(currentUserId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('غرفة الوساطة والضمان'),
        centerTitle: true,
        backgroundColor: OqoodyTheme.primaryDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: OqoodyTheme.accentGold),
            onPressed: _refreshEscrow,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deal Overview Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [OqoodyTheme.cardBg, OqoodyTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _escrow.isDisputed ? OqoodyTheme.alertRed : OqoodyTheme.accentGold,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _escrow.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _escrow.isDisputed
                              ? OqoodyTheme.alertRed.withOpacity(0.2)
                              : (_escrow.isCompleted ? OqoodyTheme.successGreen.withOpacity(0.2) : OqoodyTheme.accentGold.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _escrow.isDisputed
                                ? OqoodyTheme.alertRed
                                : (_escrow.isCompleted ? OqoodyTheme.successGreen : OqoodyTheme.accentGold),
                          ),
                        ),
                        child: Text(
                          _escrow.isDisputed ? 'نزاع مفتوح' : (_escrow.isCompleted ? 'مكتملة ومحررة' : 'سارية ونشطة'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _escrow.isDisputed
                                ? OqoodyTheme.alertRed
                                : (_escrow.isCompleted ? OqoodyTheme.successGreen : OqoodyTheme.accentGold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_escrow.description, style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('إجمالي مبلغ الضمان المحتجز:', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            '${_escrow.totalAmount.toStringAsFixed(0)} ج.م',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('نسبة الإنجاز المحررة:', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            '${_releasedPercentage.toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: OqoodyTheme.successGreen),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _releasedPercentage / 100.0,
                      minHeight: 8,
                      color: OqoodyTheme.successGreen,
                      backgroundColor: OqoodyTheme.bgDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Parties Section
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: OqoodyTheme.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: OqoodyTheme.primaryEmerald),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('الطرف الأول (المشتري):', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 11)),
                            if (isPartyA) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(color: OqoodyTheme.accentGold, borderRadius: BorderRadius.circular(4)),
                                child: const Text('أنت', style: TextStyle(color: OqoodyTheme.primaryDark, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(_escrow.partyAName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                        Text(_escrow.partyAPhone, style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(height: 36, width: 1, color: OqoodyTheme.primaryEmerald),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('الطرف الثاني (المنفذ):', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 11)),
                            if (isPartyB) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(color: OqoodyTheme.accentGold, borderRadius: BorderRadius.circular(4)),
                                child: const Text('أنت', style: TextStyle(color: OqoodyTheme.primaryDark, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(_escrow.partyBName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                        Text(_escrow.partyBPhone, style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Milestones Interactive Timeline
            const Text(
              'مراحل التنفيذ وموقف الدفعات:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold),
            ),
            const SizedBox(height: 12),

            ..._escrow.milestones.asMap().entries.map((entry) {
              final idx = entry.key;
              final m = entry.value;

              Color badgeColor;
              String badgeText;
              IconData statusIcon;

              switch (m.status) {
                case 'released':
                  badgeColor = OqoodyTheme.successGreen;
                  badgeText = 'تم الصرف';
                  statusIcon = Icons.check_circle;
                  break;
                case 'submitted':
                  badgeColor = Colors.cyan;
                  badgeText = 'تم التسليم';
                  statusIcon = Icons.upload_file;
                  break;
                case 'disputed':
                  badgeColor = OqoodyTheme.alertRed;
                  badgeText = 'نزاع مفتوح';
                  statusIcon = Icons.warning_amber;
                  break;
                case 'held_in_escrow':
                default:
                  badgeColor = OqoodyTheme.accentGold;
                  badgeText = 'محتجزة بالضمان';
                  statusIcon = Icons.lock_clock;
                  break;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OqoodyTheme.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: m.isDisputed
                        ? OqoodyTheme.alertRed
                        : (m.isReleased ? OqoodyTheme.successGreen.withOpacity(0.5) : OqoodyTheme.primaryEmerald),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: badgeColor.withOpacity(0.2),
                          child: Text('${idx + 1}', style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                              const SizedBox(height: 2),
                              Text('شروط الاستحقاق: ${m.terms}', style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${m.amount.toStringAsFixed(0)} ج.م',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold, fontSize: 15),
                            ),
                            Text('(${m.percentage.toStringAsFixed(0)}%)', style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),

                    if (m.submissionNotes != null && m.submissionNotes!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: OqoodyTheme.primaryDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.cyan.withOpacity(0.4)),
                        ),
                        child: Text(
                          'ملاحظات التسليم: ${m.submissionNotes!}',
                          style: const TextStyle(color: Colors.cyanAccent, fontSize: 12),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    const Divider(color: OqoodyTheme.primaryEmerald, height: 1),
                    const SizedBox(height: 10),

                    // Milestone Status & Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(statusIcon, color: badgeColor, size: 16),
                            const SizedBox(width: 6),
                            Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),

                        // Actions for Party B (Deliver) or Party A (Release / Dispute)
                        Row(
                          children: [
                            if (isPartyB && m.isHeld)
                              ElevatedButton.icon(
                                onPressed: () => _submitDeliverable(m),
                                icon: const Icon(Icons.upload, size: 14),
                                label: const Text('تسليم المخرج', style: TextStyle(fontSize: 11)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.cyan[700],
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                ),
                              ),
                            if (isPartyA && (m.isSubmitted || m.isHeld) && !m.isReleased) ...[
                              ElevatedButton(
                                onPressed: () => _releaseFunds(m),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: OqoodyTheme.successGreen,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                ),
                                child: const Text('تحرير الدفعة', style: TextStyle(fontSize: 11, color: Colors.white)),
                              ),
                              const SizedBox(width: 6),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RaiseDisputeScreen(escrow: _escrow, milestone: m),
                                    ),
                                  ).then((_) => _refreshEscrow());
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: OqoodyTheme.alertRed),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                ),
                                child: const Text('فتح نزاع', style: TextStyle(color: OqoodyTheme.alertRed, fontSize: 11)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

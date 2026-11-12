import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/dispute_model.dart';
import '../../services/api_service.dart';

class DisputeDetailsScreen extends StatefulWidget {
  final DisputeModel dispute;

  const DisputeDetailsScreen({super.key, required this.dispute});

  @override
  State<DisputeDetailsScreen> createState() => _DisputeDetailsScreenState();
}

class _DisputeDetailsScreenState extends State<DisputeDetailsScreen> {
  late DisputeModel _dispute;

  @override
  void initState() {
    super.initState();
    _dispute = widget.dispute;
    _refreshDispute();
  }

  Future<void> _refreshDispute() async {
    try {
      final updated = await ApiService().getDisputeDetails(_dispute.id);
      if (mounted) {
        setState(() {
          _dispute = updated;
        });
      }
    } catch (_) {}
  }

  String _getResolutionTitle(String? type) {
    switch (type) {
      case 'refund_party_a':
        return 'حكم التحكيم: رد 100% من المبلغ للطرف الأول (المشتري)';
      case 'release_party_b':
        return 'حكم التحكيم: تحرير 100% من المبلغ للطرف الثاني (المنفذ)';
      case 'split':
        return 'حكم التحكيم: تسوية ودية وقسمة عادلة بين الطرفين';
      default:
        return 'صدر حكم التحكيم النهائي';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isResolved = _dispute.isResolved;
    final dateFormat = DateFormat('dd MMMM yyyy - hh:mm a', 'ar');
    final formattedDate = _dispute.createdAt != null ? dateFormat.format(_dispute.createdAt!) : 'مؤخراً';

    return Scaffold(
      appBar: AppBar(
        title: const Text('ملف التحكيم وفض النزاع'),
        centerTitle: true,
        backgroundColor: OqoodyTheme.primaryDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: OqoodyTheme.accentGold),
            onPressed: _refreshDispute,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isResolved ? OqoodyTheme.successGreen.withOpacity(0.15) : OqoodyTheme.alertRed.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isResolved ? OqoodyTheme.successGreen : OqoodyTheme.alertRed,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isResolved ? Icons.gavel : Icons.hourglass_empty,
                    color: isResolved ? OqoodyTheme.successGreen : OqoodyTheme.alertRed,
                    size: 32,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isResolved ? 'تم البت في النزاع وصدور الحكم' : 'ملف النزاع قيد المداولة والتحكيم',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isResolved ? OqoodyTheme.successGreen : OqoodyTheme.alertRed,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('تاريخ فتح النزاع: $formattedDate', style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Arbitration Ruling Card (If Resolved)
            if (isResolved) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: OqoodyTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: OqoodyTheme.accentGold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: OqoodyTheme.accentGold.withOpacity(0.15),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.balance, color: OqoodyTheme.accentGold, size: 24),
                        SizedBox(width: 10),
                        Text('منطوق حكم المحكم المعتمد:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: OqoodyTheme.accentGold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _getResolutionTitle(_dispute.resolutionType),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    ),
                    if (_dispute.splitPartyA != null && _dispute.splitPartyB != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: OqoodyTheme.primaryDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text('حصة الطرف الأول: ${_dispute.splitPartyA}%', style: const TextStyle(color: OqoodyTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 12)),
                            Text('حصة الطرف الثاني: ${_dispute.splitPartyB}%', style: const TextStyle(color: OqoodyTheme.successGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                    if (_dispute.arbitratorNotes != null && _dispute.arbitratorNotes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('أسباب وحيثيات الحكم:', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        _dispute.arbitratorNotes!,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Dispute Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: OqoodyTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: OqoodyTheme.primaryEmerald),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('بيانات الصفقة والدفعة المتنازع عليها:', style: TextStyle(color: OqoodyTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildRow('عنوان الصفقة', _dispute.escrowTitle),
                  _buildRow('الدفعة المتنازع عليها', _dispute.milestoneTitle ?? 'الدفعة المعنية'),
                  _buildRow('المبلغ المجمد بالضمان', '${_dispute.milestoneAmount.toStringAsFixed(0)} ج.م'),
                  _buildRow('الطرف الشاكي', _dispute.raisedByName),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Reason & Details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: OqoodyTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: OqoodyTheme.primaryEmerald),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('موضوع وسبب النزاع:', style: TextStyle(color: OqoodyTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(_dispute.reason, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 12),
                  const Text('وقائع الخلاف المشروحة:', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(_dispute.details, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
        ],
      ),
    );
  }
}

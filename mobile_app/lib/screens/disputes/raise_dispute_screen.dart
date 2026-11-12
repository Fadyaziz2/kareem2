import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/escrow_model.dart';
import '../../services/api_service.dart';
import 'dispute_details_screen.dart';

class RaiseDisputeScreen extends StatefulWidget {
  final EscrowModel escrow;
  final MilestoneModel milestone;

  const RaiseDisputeScreen({super.key, required this.escrow, required this.milestone});

  @override
  State<RaiseDisputeScreen> createState() => _RaiseDisputeScreenState();
}

class _RaiseDisputeScreenState extends State<RaiseDisputeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _detailsController = TextEditingController();
  final _evidenceController = TextEditingController();

  String _selectedReason = 'عدم مطابقة المخرجات للمواصفات المتفق عليها';
  bool _isSubmitting = false;
  String? _errorMessage;

  final List<String> _reasons = [
    'عدم مطابقة المخرجات للمواصفات المتفق عليها',
    'تأخر التسليم عن الموعد المحدد دون إذن مسبق',
    'رفض استكمال الأعمال المتفق عليها في العقد',
    'مطالبة بمبالغ إضافية غير منصوص عليها بالعقد',
    'أسباب أخرى تخالف بنود التعاقد',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  Future<void> _handleRaiseDispute() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final evidenceList = _evidenceController.text.trim().isNotEmpty
          ? [_evidenceController.text.trim()]
          : <String>[];

      final dispute = await ApiService().raiseDispute(
        escrowId: widget.escrow.id,
        milestoneId: widget.milestone.id,
        reason: _selectedReason,
        details: _detailsController.text.trim(),
        evidenceFiles: evidenceList,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم فتح ملف النزاع وتجميد الدفعة فوراً وإحالتها للمحكم القانوني'),
          backgroundColor: OqoodyTheme.alertRed,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DisputeDetailsScreen(dispute: dispute),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فتح نزاع وتحكيم رسمي'),
        centerTitle: true,
        backgroundColor: OqoodyTheme.primaryDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OqoodyTheme.alertRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: OqoodyTheme.alertRed.withOpacity(0.6)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: OqoodyTheme.alertRed, size: 36),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('تجميد فوري للدفعة وحماية الحقوق', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(
                            'عند فتح النزاع، سيتم تجميد مبلغ (${widget.milestone.amount.toStringAsFixed(0)} ج.م) فوراً وإسناد الملف لمحكم معتمد من منصة عقودي للبت فيه بموجب بنود العقد.',
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: OqoodyTheme.alertRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: OqoodyTheme.alertRed),
                  ),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.white, fontSize: 13)),
                ),

              // Milestone Summary Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: OqoodyTheme.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: OqoodyTheme.primaryEmerald),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('الدفعة محل النزاع:', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(widget.milestone.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: OqoodyTheme.accentGold)),
                    const SizedBox(height: 4),
                    Text('القيمة المالية: ${widget.milestone.amount.toStringAsFixed(0)} ج.م (${widget.milestone.percentage.toStringAsFixed(0)}%)', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Reason dropdown
              const Text('سبب النزاع الرئيسي: *', style: TextStyle(fontWeight: FontWeight.bold, color: OqoodyTheme.textLight)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedReason,
                dropdownColor: OqoodyTheme.cardBg,
                isExpanded: true,
                items: _reasons.map((r) {
                  return DropdownMenuItem<String>(
                    value: r,
                    child: Text(r, style: const TextStyle(color: Colors.white, fontSize: 13)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedReason = val);
                },
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
              ),

              const SizedBox(height: 18),

              // Details
              const Text('شرح مفصل لوقائع النزاع وموضع الخلاف: *', style: TextStyle(fontWeight: FontWeight.bold, color: OqoodyTheme.textLight)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _detailsController,
                maxLines: 5,
                validator: (val) => val == null || val.trim().length < 10 ? 'يرجى كتابة شرح واضح للنزاع لا يقل عن 10 أحرف' : null,
                decoration: const InputDecoration(
                  hintText: 'اذكر بالتفصيل ما تم الاتفاق عليه، وما قام الطرف الآخر بمخالفته، والتواريخ والمراسلات...',
                ),
              ),

              const SizedBox(height: 18),

              // Evidence links
              const Text('روابط المستندات والأدلة (اختياري):', style: TextStyle(fontWeight: FontWeight.bold, color: OqoodyTheme.textLight)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _evidenceController,
                decoration: const InputDecoration(
                  hintText: 'رابط ملفات Google Drive، Dropbox، أو صور المراسلات...',
                ),
              ),

              const SizedBox(height: 28),

              // CTA
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _handleRaiseDispute,
                  icon: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.gavel),
                  label: Text(_isSubmitting ? 'جاري رفع النزاع...' : 'تأكيد تجميد الأموال وإحالة للتحكيم'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OqoodyTheme.alertRed,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}


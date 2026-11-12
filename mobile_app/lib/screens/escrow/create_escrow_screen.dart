import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/contract_model.dart';
import '../../services/api_service.dart';
import 'escrow_room_details_screen.dart';

class CreateEscrowScreen extends StatefulWidget {
  final ContractModel? preselectedContract;

  const CreateEscrowScreen({super.key, this.preselectedContract});

  @override
  State<CreateEscrowScreen> createState() => _CreateEscrowScreenState();
}

class _MilestoneInput {
  final TextEditingController titleController;
  final TextEditingController percentController;
  final TextEditingController termsController;

  _MilestoneInput({
    required String title,
    required String percent,
    required String terms,
  })  : titleController = TextEditingController(text: title),
        percentController = TextEditingController(text: percent),
        termsController = TextEditingController(text: terms);

  void dispose() {
    titleController.dispose();
    percentController.dispose();
    termsController.dispose();
  }
}

class _CreateEscrowScreenState extends State<CreateEscrowScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _partyBIdentifierController = TextEditingController();

  final List<_MilestoneInput> _milestoneInputs = [];

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedContract != null) {
      _titleController.text = 'وساطة: ${widget.preselectedContract!.title}';
      _descriptionController.text = 'بناءً على العقد الموثق رقم ${widget.preselectedContract!.id}';
      _totalAmountController.text = widget.preselectedContract!.price.toStringAsFixed(0);
    }

    // Default 2 milestones (50% / 50%)
    _milestoneInputs.add(
      _MilestoneInput(
        title: 'الدفعة الأولى: بدء التنفيذ وتسليم النماذج الأولية',
        percent: '50',
        terms: 'تسليم المسودات الأولى وموافقة الطرف الأول كتابياً.',
      ),
    );
    _milestoneInputs.add(
      _MilestoneInput(
        title: 'الدفعة النهائية: التسليم والفحص النهائي',
        percent: '50',
        terms: 'تسليم المنتج أو الخدمة كاملة بدون أي ملاحظات.',
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _totalAmountController.dispose();
    _partyBIdentifierController.dispose();
    for (var m in _milestoneInputs) {
      m.dispose();
    }
    super.dispose();
  }

  void _addMilestone() {
    setState(() {
      _milestoneInputs.add(
        _MilestoneInput(
          title: 'مرحلة إضافية #${_milestoneInputs.length + 1}',
          percent: '0',
          terms: 'شروط استحقاق الدفعة...',
        ),
      );
    });
  }

  void _removeMilestone(int index) {
    if (_milestoneInputs.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب أن تحتوي العملية على مرحلة واحدة على الأقل')),
      );
      return;
    }
    setState(() {
      final removed = _milestoneInputs.removeAt(index);
      removed.dispose();
    });
  }

  double get _totalPercentage {
    double total = 0.0;
    for (var m in _milestoneInputs) {
      total += double.tryParse(m.percentController.text) ?? 0.0;
    }
    return total;
  }

  Future<void> _handleCreateEscrow() async {
    if (!_formKey.currentState!.validate()) return;

    if ((_totalPercentage - 100.0).abs() > 0.01) {
      setState(() {
        _errorMessage = 'مجموع نسب المراحل يجب أن يساوي 100% تماماً (المجموع الحالي: $_totalPercentage%)';
      });
      return;
    }

    final totalAmount = double.tryParse(_totalAmountController.text) ?? 0.0;
    if (totalAmount <= 0) {
      setState(() => _errorMessage = 'يرجى إدخال مبلغ صحيح أكبر من صفر');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // 1. Mock Checkout to deposit escrow funds
      await ApiService().mockCheckout(
        type: 'escrow',
        amount: totalAmount,
        description: 'إيداع وحجز مبلغ الضمان لصفقة: ${_titleController.text.trim()}',
      );

      // 2. Build milestones payload
      final milestones = _milestoneInputs.map((m) {
        final pct = double.tryParse(m.percentController.text) ?? 0.0;
        final amount = (totalAmount * pct) / 100.0;
        return {
          'title': m.titleController.text.trim(),
          'percentage': pct,
          'amount': amount,
          'terms': m.termsController.text.trim(),
        };
      }).toList();

      final payload = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'totalAmount': totalAmount,
        'partyBIdentifier': _partyBIdentifierController.text.trim(),
        'milestones': milestones,
        if (widget.preselectedContract != null) 'linkedContractId': widget.preselectedContract!.id,
      };

      final createdEscrow = await ApiService().createEscrow(payload);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء عملية الوساطة وحجز المبلغ في حساب الضمان بنجاح!'),
          backgroundColor: OqoodyTheme.successGreen,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EscrowRoomDetailsScreen(escrow: createdEscrow),
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
        title: const Text('إنشاء عملية وساطة آمنة (Escrow)'),
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
              // Escrow Guarantee Header Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [OqoodyTheme.cardBg, OqoodyTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: OqoodyTheme.accentGold.withOpacity(0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: OqoodyTheme.accentGold, size: 36),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('حماية الضمان المالي 100%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: OqoodyTheme.accentGold)),
                          SizedBox(height: 4),
                          Text('يتم تجميد المبلغ في حساب منصة عقودي، ولا يتم تحرير أي دفعة إلا بموافقتك بعد فحص التسليم.', style: TextStyle(fontSize: 12, color: Colors.white70)),
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
                    color: OqoodyTheme.alertRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: OqoodyTheme.alertRed.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: OqoodyTheme.alertRed, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.white, fontSize: 13))),
                    ],
                  ),
                ),

              // Deal Title
              const Text('عنوان الصفقة أو الخدمة: *', style: TextStyle(fontWeight: FontWeight.bold, color: OqoodyTheme.textLight)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى إدخال عنوان الصفقة' : null,
                decoration: const InputDecoration(hintText: 'مثال: تصميم وبرمجة تطبيق جوال'),
              ),

              const SizedBox(height: 16),

              // Description
              const Text('وصف نطاق العمل والاتفاق: *', style: TextStyle(fontWeight: FontWeight.bold, color: OqoodyTheme.textLight)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى إدخال تفاصيل ونطاق العمل' : null,
                decoration: const InputDecoration(hintText: 'اكتب الشروط والالتزامات والمخرجات المتفق عليها...'),
              ),

              const SizedBox(height: 16),

              // Party B identifier & Total Amount Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('هاتف أو بريد الطرف الثاني: *', style: TextStyle(fontWeight: FontWeight.bold, color: OqoodyTheme.textLight, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _partyBIdentifierController,
                          validator: (val) => val == null || val.trim().isEmpty ? 'مطلوب لدعوة الطرف الآخر' : null,
                          decoration: const InputDecoration(hintText: '010XXXXXXXX'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('إجمالي القيمة (ج.م): *', style: TextStyle(fontWeight: FontWeight.bold, color: OqoodyTheme.textLight, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _totalAmountController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          validator: (val) => val == null || double.tryParse(val) == null ? 'أدخل مبلغاً صحيحاً' : null,
                          decoration: const InputDecoration(hintText: 'مثال: 20000'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Milestones Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'مراحل التنفيذ والدفعات (Milestones):',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold),
                  ),
                  TextButton.icon(
                    onPressed: _addMilestone,
                    icon: const Icon(Icons.add, size: 18, color: OqoodyTheme.accentGold),
                    label: const Text('إضافة مرحلة', style: TextStyle(color: OqoodyTheme.accentGold, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ..._milestoneInputs.asMap().entries.map((entry) {
                final idx = entry.key;
                final m = entry.value;
                final total = double.tryParse(_totalAmountController.text) ?? 0.0;
                final pct = double.tryParse(m.percentController.text) ?? 0.0;
                final calcAmount = (total * pct) / 100.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: OqoodyTheme.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: OqoodyTheme.primaryEmerald),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('مرحلة #${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold)),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: OqoodyTheme.alertRed, size: 20),
                            onPressed: () => _removeMilestone(idx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: m.titleController,
                        validator: (v) => v == null || v.isEmpty ? 'اسم المرحلة مطلوب' : null,
                        decoration: const InputDecoration(
                          hintText: 'عنوان المخرج أو الدفعة',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: m.percentController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              validator: (v) => v == null || double.tryParse(v) == null ? 'أدخل النسبة' : null,
                              decoration: const InputDecoration(
                                hintText: 'النسبة %',
                                suffixText: '%',
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: OqoodyTheme.primaryDark,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'المبلغ: ${calcAmount.toStringAsFixed(0)} ج.م',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: m.termsController,
                        decoration: const InputDecoration(
                          hintText: 'شروط ومعايير قبول هذه الدفعة...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Total percentage tracker
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_totalPercentage - 100.0).abs() < 0.01
                      ? OqoodyTheme.successGreen.withOpacity(0.15)
                      : Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (_totalPercentage - 100.0).abs() < 0.01
                        ? OqoodyTheme.successGreen
                        : Colors.amber,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('إجمالي نسب الدفعات:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(
                      '$_totalPercentage% / 100%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: (_totalPercentage - 100.0).abs() < 0.01 ? OqoodyTheme.successGreen : Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Final CTA
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _handleCreateEscrow,
                  icon: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: OqoodyTheme.primaryDark))
                      : const Icon(Icons.lock_outline),
                  label: Text(_isSubmitting ? 'جاري حجز الضمان...' : 'إيداع وتفعيل الضمان المالي'),
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

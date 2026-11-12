import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/template_model.dart';
import '../../services/api_service.dart';
import 'contract_pdf_viewer_screen.dart';

class ContractFormScreen extends StatefulWidget {
  final TemplateModel template;

  const ContractFormScreen({super.key, required this.template});

  @override
  State<ContractFormScreen> createState() => _ContractFormScreenState();
}

class _ContractFormScreenState extends State<ContractFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _selectValues = {};

  String _contractType = 'instant'; // 'instant' or 'lawyer_review'
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    for (var variable in widget.template.variables) {
      if (variable.type == 'select') {
        _selectValues[variable.name] = variable.defaultValue.isNotEmpty && variable.options.contains(variable.defaultValue)
            ? variable.defaultValue
            : (variable.options.isNotEmpty ? variable.options.first : '');
      } else {
        _controllers[variable.name] = TextEditingController(text: variable.defaultValue);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double get _currentPrice {
    return _contractType == 'instant'
        ? widget.template.autoGeneratePrice
        : widget.template.lawyerReviewPrice;
  }

  Future<void> _submitContract() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final filledVariables = <String, dynamic>{};
      for (var variable in widget.template.variables) {
        if (variable.type == 'select') {
          filledVariables[variable.name] = _selectValues[variable.name] ?? '';
        } else {
          filledVariables[variable.name] = _controllers[variable.name]?.text.trim() ?? '';
        }
      }

      // Step 1: Simulated Secure Mock Payment
      await ApiService().mockCheckout(
        type: 'contract',
        amount: _currentPrice,
        referenceId: widget.template.id,
        description: 'رسوم توثيق: ${widget.template.title} ($_contractType)',
      );

      // Step 2: Generate Contract via Backend
      final generatedContract = await ApiService().generateContract(
        templateId: widget.template.id,
        contractType: _contractType,
        filledVariables: filledVariables,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم توثيق وتوليد العقد بنجاح!'),
          backgroundColor: OqoodyTheme.successGreen,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ContractPdfViewerScreen(contract: generatedContract),
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
        title: Text(widget.template.title),
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
              // Template Summary Card
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
                    Row(
                      children: [
                        const Icon(Icons.verified_user, color: OqoodyTheme.accentGold, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.template.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.template.description,
                      style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: OqoodyTheme.primaryDark,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.template.category,
                        style: const TextStyle(fontSize: 11, color: OqoodyTheme.accentGold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Mode Selection: Instant vs Lawyer Review
              const Text(
                'اختر طريقة التوثيق والصياغة:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeOption(
                      title: 'توليد فوري ذكي',
                      subtitle: 'عقد قانوني آلي فوري',
                      price: '${widget.template.autoGeneratePrice.toStringAsFixed(0)} ج.م',
                      typeKey: 'instant',
                      icon: Icons.bolt,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeOption(
                      title: 'مراجعة محامٍ معتمد',
                      subtitle: 'فحص مخصص ومصادقة',
                      price: '${widget.template.lawyerReviewPrice.toStringAsFixed(0)} ج.م',
                      typeKey: 'lawyer_review',
                      icon: Icons.gavel,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Dynamic Variables Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'بيانات وأطراف العقد:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold),
                  ),
                  Text(
                    '${widget.template.variables.length} حقول مطلوبة',
                    style: const TextStyle(fontSize: 12, color: OqoodyTheme.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 12),

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
                      Expanded(
                        child: Text(_errorMessage!, style: const TextStyle(color: Colors.white, fontSize: 13)),
                      ),
                    ],
                  ),
                ),

              ...widget.template.variables.map((variable) => _buildVariableInput(variable)),

              const SizedBox(height: 24),

              // Price Summary & Payment CTA
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OqoodyTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: OqoodyTheme.accentGold.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('إجمالي الرسوم (شامل الضريبة):', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '${_currentPrice.toStringAsFixed(0)} ج.م',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitContract,
                      icon: _isSubmitting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: OqoodyTheme.primaryDark))
                          : const Icon(Icons.check_circle_outline),
                      label: Text(_isSubmitting ? 'جاري التوثيق...' : 'دفع وإصدار العقد'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required String title,
    required String subtitle,
    required String price,
    required String typeKey,
    required IconData icon,
  }) {
    final isSelected = _contractType == typeKey;
    return GestureDetector(
      onTap: () => setState(() => _contractType = typeKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? OqoodyTheme.primaryEmerald.withOpacity(0.4) : OqoodyTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? OqoodyTheme.accentGold : OqoodyTheme.primaryEmerald,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: isSelected ? OqoodyTheme.accentGold : OqoodyTheme.textMuted, size: 24),
                if (isSelected)
                  const Icon(Icons.check_circle, color: OqoodyTheme.accentGold, size: 18),
              ],
            ),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : OqoodyTheme.textLight, fontSize: 14)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: OqoodyTheme.textMuted)),
            const SizedBox(height: 8),
            Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold)),
          ],
        ),
      ),
    );
  }

  Widget _buildVariableInput(TemplateVariableModel variable) {
    if (variable.type == 'select') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${variable.label}${variable.required ? ' *' : ''}',
              style: const TextStyle(fontSize: 13, color: OqoodyTheme.textLight, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectValues[variable.name],
              dropdownColor: OqoodyTheme.cardBg,
              items: variable.options.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(opt, style: const TextStyle(color: Colors.white, fontSize: 14)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectValues[variable.name] = val);
              },
              validator: variable.required ? (val) => val == null || val.isEmpty ? 'هذا الحقل مطلوب' : null : null,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    final controller = _controllers[variable.name];
    final isDate = variable.type == 'date';
    final isNumber = variable.type == 'number';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${variable.label}${variable.required ? ' *' : ''}',
            style: const TextStyle(fontSize: 13, color: OqoodyTheme.textLight, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            readOnly: isDate,
            onTap: isDate
                ? () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: OqoodyTheme.accentGold,
                              onPrimary: OqoodyTheme.primaryDark,
                              surface: OqoodyTheme.cardBg,
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null && controller != null) {
                      controller.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                    }
                  }
                : null,
            validator: variable.required
                ? (val) => val == null || val.trim().isEmpty ? 'هذا الحقل مطلوب' : null
                : null,
            decoration: InputDecoration(
              hintText: 'أدخل ${variable.label}',
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              suffixIcon: isDate ? const Icon(Icons.calendar_month, color: OqoodyTheme.accentGold, size: 20) : null,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/lawyer_model.dart';
import '../../services/api_service.dart';
import 'consultation_chat_room_screen.dart';

class BookConsultationScreen extends StatefulWidget {
  final LawyerModel? lawyer;

  const BookConsultationScreen({super.key, this.lawyer});

  @override
  State<BookConsultationScreen> createState() => _BookConsultationScreenState();
}

class _BookConsultationScreenState extends State<BookConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'written'; // 'written' | 'audio_call' | 'office_visit'
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  double get _basePrice => widget.lawyer?.consultationRate ?? 200.0;

  double get _totalPrice {
    switch (_selectedType) {
      case 'audio_call':
        return _basePrice + 50.0;
      case 'office_visit':
        return _basePrice + 150.0;
      case 'written':
      default:
        return _basePrice;
    }
  }

  Future<void> _handleBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // 1. Process simulated instant payment
      await ApiService().mockCheckout(
        type: 'consultation',
        amount: _totalPrice,
        referenceId: widget.lawyer?.id,
        description: 'حجز استشارة: ${_subjectController.text.trim()}',
      );

      // 2. Book consultation via API
      final consultation = await ApiService().bookConsultation(
        lawyerId: widget.lawyer?.id,
        type: _selectedType,
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        price: _totalPrice,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حجز الاستشارة بنجاح، المحامي بانتظار رسالتك.'),
          backgroundColor: OqoodyTheme.successGreen,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ConsultationChatRoomScreen(consultation: consultation),
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
        title: const Text('طلب استشارة قانونية'),
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
              // Assigned Lawyer banner if present
              if (widget.lawyer != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: OqoodyTheme.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: OqoodyTheme.primaryEmerald),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: OqoodyTheme.accentGold,
                        child: Icon(Icons.person, color: OqoodyTheme.primaryDark),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.lawyer!.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 2),
                            Text('درجة التقاضي: ${widget.lawyer!.degree}', style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text(
                        '${widget.lawyer!.rating} ★',
                        style: const TextStyle(color: OqoodyTheme.accentGold, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

              // Consultation Type Selection
              const Text(
                'نوع الاستشارة المطلوبة:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeCard(
                      typeKey: 'written',
                      title: 'استشارة مكتوبة',
                      subtitle: 'محادثة وتوثيق نصي',
                      icon: Icons.chat,
                      price: '${_basePrice.toStringAsFixed(0)} ج.م',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTypeCard(
                      typeKey: 'audio_call',
                      title: 'مكالمة صوتية',
                      subtitle: 'جلسة هاتفية 30 دقيقة',
                      icon: Icons.phone_in_talk,
                      price: '${(_basePrice + 50).toStringAsFixed(0)} ج.م',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTypeCard(
                      typeKey: 'office_visit',
                      title: 'زيارة مكتبية',
                      subtitle: 'مقابلة شخصية بالمكتب',
                      icon: Icons.apartment,
                      price: '${(_basePrice + 150).toStringAsFixed(0)} ج.م',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

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

              // Subject Input
              const Text(
                'عنوان الموضوع / النزاع: *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: OqoodyTheme.textLight),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subjectController,
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى كتابة عنوان مختصر للموضوع' : null,
                decoration: const InputDecoration(
                  hintText: 'مثال: بند فسخ في عقد إيجار تجاري',
                ),
              ),

              const SizedBox(height: 18),

              // Description Input
              const Text(
                'شرح وتفاصيل المسألة القانونية: *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: OqoodyTheme.textLight),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                validator: (val) => val == null || val.trim().length < 10 ? 'يرجى كتابة تفاصيل واضحة لا تقل عن 10 أحرف' : null,
                decoration: const InputDecoration(
                  hintText: 'اشرح وقائع الحالة بالتفصيل، التواريخ، والالتزامات المترتبة على الأطراف...',
                ),
              ),

              const SizedBox(height: 28),

              // Price & CTA
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
                        const Text('رسوم الاستشارة الإجمالية:', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '${_totalPrice.toStringAsFixed(0)} ج.م',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _handleBooking,
                      icon: _isSubmitting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: OqoodyTheme.primaryDark))
                          : const Icon(Icons.check),
                      label: Text(_isSubmitting ? 'جاري التأكيد...' : 'تأكيد الحجز والدفع'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required String typeKey,
    required String title,
    required String subtitle,
    required IconData icon,
    required String price,
  }) {
    final isSelected = _selectedType == typeKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = typeKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? OqoodyTheme.primaryEmerald.withOpacity(0.4) : OqoodyTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? OqoodyTheme.accentGold : OqoodyTheme.primaryEmerald,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? OqoodyTheme.accentGold : OqoodyTheme.textMuted, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isSelected ? Colors.white : OqoodyTheme.textLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold),
            ),
          ],
        ),
      ),
    );
  }
}

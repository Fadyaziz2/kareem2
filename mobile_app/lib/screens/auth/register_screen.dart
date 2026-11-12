import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../home/main_wrapper_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cityController = TextEditingController(text: 'القاهرة');

  // Lawyer specific fields
  final _barNumberController = TextEditingController();
  final _specializationController = TextEditingController(text: 'عقود تجارية، تحكيم، شركات');
  final _consultationRateController = TextEditingController(text: '300');
  final _bioController = TextEditingController(text: 'محامٍ ومستشار قانوني مقيد بالنقابة.');

  String _selectedRole = 'client'; // 'client' or 'lawyer'
  String _selectedDegree = 'ابتدائي'; // 'ابتدائي', 'استئناف', 'نقض'
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cityController.dispose();
    _barNumberController.dispose();
    _specializationController.dispose();
    _consultationRateController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final payload = {
        'fullName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'role': _selectedRole,
        'city': _cityController.text.trim(),
        if (_selectedRole == 'lawyer') ...{
          'barNumber': _barNumberController.text.trim(),
          'degree': _selectedDegree,
          'specializations': _specializationController.text.split('،').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
          'consultationRate': double.tryParse(_consultationRateController.text) ?? 250.0,
          'bio': _bioController.text.trim(),
        }
      };

      await auth.register(payload);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainWrapperScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLawyer = _selectedRole == 'lawyer';

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
        centerTitle: true,
        backgroundColor: OqoodyTheme.primaryDark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Role Selection Tabs
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: OqoodyTheme.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: OqoodyTheme.primaryEmerald),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedRole = 'client'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !isLawyer ? OqoodyTheme.accentGold : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '👤 عميل / شركة',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: !isLawyer ? OqoodyTheme.primaryDark : OqoodyTheme.textLight,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedRole = 'lawyer'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isLawyer ? OqoodyTheme.accentGold : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '⚖️ محامٍ معتمد',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isLawyer ? OqoodyTheme.primaryDark : OqoodyTheme.textLight,
                              ),
                            ),
                          ),
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
                      border: Border.all(color: OqoodyTheme.alertRed.withOpacity(0.4)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: OqoodyTheme.alertRed, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Common Fields
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: OqoodyTheme.accentGold),
                    hintText: isLawyer ? 'الاسم الثلاثي كما بالبطاقة والنقابة' : 'الاسم الكامل أو اسم المنشأة',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال الاسم' : null,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone_iphone, color: OqoodyTheme.accentGold),
                    hintText: 'رقم الهاتف (مثال: 01012345678)',
                  ),
                  validator: (v) => v == null || v.length < 10 ? 'يرجى إدخال رقم هاتف صحيح' : null,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined, color: OqoodyTheme.accentGold),
                    hintText: 'البريد الإلكتروني',
                  ),
                  validator: (v) => v == null || !v.contains('@') ? 'يرجى إدخال بريد إلكتروني صالح' : null,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline, color: OqoodyTheme.accentGold),
                    hintText: 'كلمة المرور (6 أحرف على الأقل)',
                  ),
                  validator: (v) => v == null || v.length < 6 ? 'كلمة المرور يجب أن لا تقل عن 6 أحرف' : null,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on_outlined, color: OqoodyTheme.accentGold),
                    hintText: 'المحافظة / المدينة',
                  ),
                ),

                // Dynamic Lawyer Fields
                if (isLawyer) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'بيانات القيد والاعتماد النقابي:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold),
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _barNumberController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.badge_outlined, color: OqoodyTheme.accentGold),
                      hintText: 'رقم القيد بجدول المحامين (مثال: EGY-BAR-19948)',
                    ),
                    validator: (v) => isLawyer && (v == null || v.isEmpty) ? 'رقم القيد مطلوب للمحامين' : null,
                  ),
                  const SizedBox(height: 14),

                  // Litigation Degree Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: OqoodyTheme.cardBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDegree,
                        isExpanded: true,
                        dropdownColor: OqoodyTheme.cardBg,
                        icon: const Icon(Icons.arrow_drop_down, color: OqoodyTheme.accentGold),
                        items: const [
                          DropdownMenuItem(value: 'ابتدائي', child: Text('محامٍ مقيد أمام المحاكم الابتدائية')),
                          DropdownMenuItem(value: 'استئناف', child: Text('محامٍ مقيد أمام محاكم الاستئناف العالي')),
                          DropdownMenuItem(value: 'نقض', child: Text('محامٍ مقيد أمام محكمة النقض والدستورية')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedDegree = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _specializationController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.gavel, color: OqoodyTheme.accentGold),
                      hintText: 'التخصصات (مفصولة بفاصلة)',
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _consultationRateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.attach_money, color: OqoodyTheme.accentGold),
                      hintText: 'سعر الاستشارة الافتراضي (ج.م)',
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _bioController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.description_outlined, color: OqoodyTheme.accentGold),
                      hintText: 'نبذة عن الخبرات والشهادات القانونية',
                    ),
                  ),
                ],

                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: OqoodyTheme.primaryDark),
                        )
                      : Text(isLawyer ? 'تقديم طلب الانضمام كمحامٍ' : 'تأكيد التسجيل وإنشاء الحساب'),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('لديك حساب بالفعل؟ تسجيل الدخول', style: TextStyle(color: OqoodyTheme.accentGold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

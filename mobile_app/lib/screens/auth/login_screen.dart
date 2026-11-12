import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../home/main_wrapper_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController(text: '01000000001');
  final _passwordController = TextEditingController(text: 'Admin@123456');
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_phoneController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'يرجى إدخال الهاتف/البريد وكلمة المرور');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.login(_phoneController.text.trim(), _passwordController.text);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainWrapperScreen()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _fillDemo(String emailOrPhone, String pass) {
    setState(() {
      _phoneController.text = emailOrPhone;
      _passwordController.text = pass;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 90,
                  height: 90,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: OqoodyTheme.cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: OqoodyTheme.accentGold.withOpacity(0.4)),
                  ),
                  child: SvgPicture.asset('assets/icons/oqoody_logo.svg', fit: BoxFit.contain),
                ),
                const SizedBox(height: 14),
                const Text(
                  'عقودي - Oqoody',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold),
                ),
                const Text('بوابتك القانونية الآمنة لتوثيق العقود والوساطة', style: TextStyle(color: OqoodyTheme.textMuted)),
                const SizedBox(height: 32),

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

                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone_iphone, color: OqoodyTheme.accentGold),
                    hintText: 'الهاتف أو البريد الإلكتروني',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline, color: OqoodyTheme.accentGold),
                    hintText: 'كلمة المرور',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: OqoodyTheme.primaryDark),
                          )
                        : const Text('تسجيل الدخول'),
                  ),
                ),
                const SizedBox(height: 16),

                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: OqoodyTheme.accentGold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('حساب جديد؟ إنشاء حساب عميل أو محامٍ', style: TextStyle(color: OqoodyTheme.accentGold, fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 32),
                const Text('حسابات تجريبية سريعة بنقرة واحدة:', style: TextStyle(fontSize: 12, color: OqoodyTheme.textMuted)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ActionChip(
                      label: const Text('👑 أدمن عام'),
                      backgroundColor: OqoodyTheme.cardBg,
                      side: const BorderSide(color: OqoodyTheme.accentGold),
                      onPressed: () => _fillDemo('admin@oqoody.com', 'Admin@123456'),
                    ),
                    ActionChip(
                      label: const Text('⚖️ محامٍ معتمد'),
                      backgroundColor: OqoodyTheme.cardBg,
                      side: const BorderSide(color: OqoodyTheme.primaryEmerald),
                      onPressed: () => _fillDemo('01233334444', 'Oqoody@2026'),
                    ),
                    ActionChip(
                      label: const Text('👤 عميل وساطة'),
                      backgroundColor: OqoodyTheme.cardBg,
                      side: const BorderSide(color: OqoodyTheme.cardBg),
                      onPressed: () => _fillDemo('01011112222', 'Oqoody@2026'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

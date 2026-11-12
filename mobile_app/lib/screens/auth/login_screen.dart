import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme.dart';
import '../home/main_wrapper_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

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
                const SizedBox(height: 36),
                SvgPicture.asset('assets/icons/oqoody_logo.svg', width: 90, height: 90),
                const SizedBox(height: 14),
                const Text(
                  'عقودي - Oqoody',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold),
                ),
                const Text('بوابتك القانونية الآمنة لتوثيق العقود والوساطة', style: TextStyle(color: OqoodyTheme.textMuted)),
                const SizedBox(height: 44),
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
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainWrapperScreen()),
                      );
                    },
                    child: const Text('تسجيل الدخول'),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.fingerprint, color: OqoodyTheme.accentGold),
                  label: const Text('الدخول السريع (Biometrics)', style: TextStyle(color: OqoodyTheme.textLight)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: OqoodyTheme.cardBg),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

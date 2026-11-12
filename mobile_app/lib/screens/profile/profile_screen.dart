import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import '../lawyers/lawyer_dashboard_tab.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _showEditProfileDialog() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    if (user == null) return;

    final nameController = TextEditingController(text: user.fullName);
    final phoneController = TextEditingController(text: user.phone);
    final cityController = TextEditingController(text: user.city);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OqoodyTheme.cardBg,
        title: const Text('تعديل البيانات الشخصية', style: TextStyle(color: OqoodyTheme.accentGold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'المدينة / المحافظة'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: OqoodyTheme.textMuted))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiService().updateProfile({
                  'fullName': nameController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'city': cityController.text.trim(),
                });
                await auth.refreshUser();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تحديث البيانات بنجاح'), backgroundColor: OqoodyTheme.successGreen),
                  );
                  setState(() {});
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('فشل التحديث: $e'), backgroundColor: OqoodyTheme.alertRed),
                  );
                }
              }
            },
            child: const Text('حفظ التعديلات'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OqoodyTheme.cardBg,
        title: const Text('تسجيل الخروج', style: TextStyle(color: OqoodyTheme.alertRed)),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء', style: TextStyle(color: OqoodyTheme.textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: OqoodyTheme.alertRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('خروج'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الحساب الشخصي'),
        centerTitle: true,
        backgroundColor: OqoodyTheme.primaryDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: OqoodyTheme.accentGold),
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Avatar & Name Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: OqoodyTheme.cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: OqoodyTheme.primaryEmerald),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: OqoodyTheme.accentGold.withOpacity(0.2),
                    child: const Icon(Icons.person, size: 48, color: OqoodyTheme.accentGold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? 'المستخدم',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: OqoodyTheme.primaryDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: OqoodyTheme.accentGold.withOpacity(0.5)),
                    ),
                    child: Text(
                      user?.role == 'lawyer'
                          ? 'محامٍ معتمد'
                          : (user?.role == 'super_admin' ? 'مدير المنصة' : 'عميل معتمد'),
                      style: const TextStyle(color: OqoodyTheme.accentGold, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Profile info details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: OqoodyTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: OqoodyTheme.primaryEmerald),
              ),
              child: Column(
                children: [
                  _buildProfileTile(Icons.phone, 'رقم الهاتف', user?.phone ?? '-'),
                  const Divider(color: OqoodyTheme.primaryEmerald),
                  _buildProfileTile(Icons.location_city, 'المدينة', user?.city ?? '-'),
                  const Divider(color: OqoodyTheme.primaryEmerald),
                  _buildProfileTile(Icons.account_balance_wallet, 'رصيد المحفظة', '${(user?.walletBalance ?? 0.0).toStringAsFixed(0)} ج.م'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Lawyer Dashboard Shortcut if Lawyer
            if (user?.role == 'lawyer')
              ListTile(
                tileColor: OqoodyTheme.cardBg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: OqoodyTheme.accentGold)),
                leading: const Icon(Icons.dashboard_customize, color: OqoodyTheme.accentGold),
                title: const Text('لوحة تحكم وإدارة المحامي', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('مراجعة العقود والرد على الاستشارات', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 11)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: OqoodyTheme.accentGold),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const Scaffold(body: LawyerDashboardTab())));
                },
              ),

            const SizedBox(height: 12),

            // Security & Privacy Tile
            ListTile(
              tileColor: OqoodyTheme.cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              leading: const Icon(Icons.privacy_tip_outlined, color: OqoodyTheme.textLight),
              title: const Text('الشروط والأحكام وسياسة الخصوصية'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: OqoodyTheme.textMuted),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'عقودي - Oqoody',
                  applicationVersion: '1.0.0 (Production)',
                  children: const [
                    Text('منصة عقودي للحلول القانونية وحماية المعاملات المالية (Escrow).\nجميع الحقوق محفوظة © 2026.'),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('تسجيل الخروج من الحساب', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: OqoodyTheme.alertRed,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: OqoodyTheme.accentGold, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
        ],
      ),
    );
  }
}


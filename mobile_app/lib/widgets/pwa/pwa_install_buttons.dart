import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../main.dart';
import 'pwa_detector.dart';

/// PWA Install Banner mounted globally at MaterialApp.builder
class PwaInstallBanner extends StatefulWidget {
  const PwaInstallBanner({super.key});

  @override
  State<PwaInstallBanner> createState() => _PwaInstallBannerState();
}

class _PwaInstallBannerState extends State<PwaInstallBanner> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _checkVisibility();
  }

  void _checkVisibility() {
    // 1. If running on native Android / iOS or non-web platform -> STRICTLY HIDE
    if (!kIsWeb) {
      _isVisible = false;
      return;
    }

    // 2. Check if running inside regular browser tab (NOT standalone / fullscreen / minimal-ui / iOS standalone)
    final browserMode = isPwaBrowserModeOnly();
    if (!browserMode) {
      _isVisible = false;
      return;
    }

    // 3. Check if user already dismissed it during this browsing session
    final dismissed = isPwaBannerDismissed();
    if (dismissed) {
      _isVisible = false;
      return;
    }

    setState(() {
      _isVisible = true;
    });

    // 4. Initialize beforeinstallprompt listener for Android Chrome
    initBeforeInstallPrompt();

    // 5. Auto-hide immediately upon 'appinstalled' event without page reload
    listenToAppInstalled(() {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  void _dismiss() {
    dismissPwaBanner();
    if (mounted) {
      setState(() {
        _isVisible = false;
      });
    }
  }

  BuildContext? get _dialogContext {
    return OqoodyApp.navigatorKey.currentContext ?? context;
  }

  Future<void> _handleAndroidInstall() async {
    // 1. Check if running under insecure HTTP (Chrome blocks PWA and shows "This app cannot be installed" on HTTP)
    if (!isSecureWebContext()) {
      _showInsecureHttpWarning();
      return;
    }

    // 2. Trigger native 1-tap install prompt
    final accepted = await promptNativeInstall();
    if (accepted) {
      if (mounted) {
        setState(() => _isVisible = false);
      }
      return;
    }

    // 3. If prompt is still preparing or user dismissed the prompt dialog
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: OqoodyTheme.accentGold, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'يمكنك أيضاً تثبيت التطبيق بنقرة واحدة من قائمة خيارات المتصفح (⋮) -> تثبيت التطبيق.',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: OqoodyTheme.cardBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: OqoodyTheme.accentGold, width: 1),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showInsecureHttpWarning() {
    final ctx = _dialogContext;
    if (ctx == null) return;

    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: OqoodyTheme.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: OqoodyTheme.accentGold, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: OqoodyTheme.accentGold, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'تفعيل الأمان (HTTPS) مطلوب للتثبيت',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'متصفح Google Chrome على هواتف الأندرويد يشترط تشغيل الموقع عبر بروتوكول الأمان المشفر (HTTPS) لتفعيل التثبيت المباشر بنقرة واحدة (One-Tap Install).\n\nالموقع حالياً يعمل عبر HTTP غير المشفر، ولذلك يمنع كروم تثبيته ويظهر تنبيه "This app cannot be installed".\n\nيرجى الدخول عبر رابط https:// أو تفعيل شهادة SSL (مثل Let\'s Encrypt / Certbot) على السيرفر.',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: OqoodyTheme.accentGold,
              foregroundColor: OqoodyTheme.primaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('حسناً، فهمت', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showIosGuide() {
    final ctx = _dialogContext;
    if (ctx == null) return;

    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: OqoodyTheme.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: OqoodyTheme.accentGold, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.apple, color: OqoodyTheme.accentGold, size: 24),
            SizedBox(width: 8),
            Text('تثبيت تطبيق عقودي للآيفون', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStep('1', 'افتح هذا الرابط داخل متصفح Safari.'),
            const SizedBox(height: 12),
            _buildStep('2', 'انقر على زر المشاركة (Share) بأيقونة المربع والسهم في الشريط السفلي.'),
            const SizedBox(height: 12),
            _buildStep('3', 'مرر لأسفل واختر «إضافة إلى الصفحة الرئيسية» (Add to Home Screen).'),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: OqoodyTheme.accentGold,
              foregroundColor: OqoodyTheme.primaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('تم، سأقوم بالتثبيت', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: OqoodyTheme.accentGold,
          child: Text(number, style: const TextStyle(color: OqoodyTheme.primaryDark, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // STRICT REQUIREMENT: If not in regular browser mode, or running as Native App, or dismissed, return NOTHING!
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: OqoodyTheme.cardBg,
        border: Border(
          bottom: BorderSide(
            color: OqoodyTheme.accentGold.withOpacity(0.4),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SafeArea(
        top: true,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 620;

            if (isNarrow) {
              // Compact mobile layout
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars, color: OqoodyTheme.accentGold, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'تطبيق عقودي الذكي (PWA)',
                          style: TextStyle(
                            color: OqoodyTheme.accentGold,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Dismiss button
                      InkWell(
                        onTap: _dismiss,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.close, size: 14, color: Colors.white70),
                              SizedBox(width: 4),
                              Text('إخفاء', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 32,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: OqoodyTheme.accentGold,
                              foregroundColor: OqoodyTheme.primaryDark,
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _handleAndroidInstall,
                            icon: const Icon(Icons.phone_android, size: 14),
                            label: const Text('تثبيت للأندرويد', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 32,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: OqoodyTheme.accentGold),
                              foregroundColor: OqoodyTheme.accentGold,
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _showIosGuide,
                            icon: const Icon(Icons.apple, size: 14),
                            label: const Text('تثبيت للآيفون', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            // Desktop / Tablet wide layout
            return Row(
              children: [
                const Icon(Icons.stars, color: OqoodyTheme.accentGold, size: 22),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'تطبيق عقودي الذكي (PWA)',
                      style: TextStyle(
                        color: OqoodyTheme.accentGold,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ثبّت التطبيق للوصول المباشر السريع بدون متصفح وتلقي الإشعارات الفورية',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  height: 32,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OqoodyTheme.accentGold,
                      foregroundColor: OqoodyTheme.primaryDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _handleAndroidInstall,
                    icon: const Icon(Icons.phone_android, size: 15),
                    label: const Text('تثبيت للأندرويد', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 32,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: OqoodyTheme.accentGold),
                      foregroundColor: OqoodyTheme.accentGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _showIosGuide,
                    icon: const Icon(Icons.apple, size: 15),
                    label: const Text('تثبيت للآيفون', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                // Dismiss button
                InkWell(
                  onTap: _dismiss,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close, size: 14, color: Colors.white70),
                        SizedBox(width: 4),
                        Text('إخفاء', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Backwards compatibility aliases
typedef PwaInstallGlobalBanner = PwaInstallBanner;

class PwaInstallButtons extends StatelessWidget {
  final bool isBanner;
  const PwaInstallButtons({super.key, this.isBanner = false});

  @override
  Widget build(BuildContext context) {
    return const PwaInstallBanner();
  }
}

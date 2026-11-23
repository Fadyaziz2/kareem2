import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'widgets/pwa/pwa_install_buttons.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OqoodyApp());
}

class OqoodyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const OqoodyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'عقودي - Oqoody',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar', 'EG'),
        supportedLocales: const [
          Locale('ar', 'EG'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: OqoodyTheme.themeData,
        builder: (context, child) {
          // Native mobile apps (Android/iOS) -> Return unaltered child navigator with zero wrappers
          if (!kIsWeb) {
            return child ?? const SizedBox.shrink();
          }

          // Web browser -> Global root injection of PwaInstallBanner above the Navigator
          return Material(
            color: OqoodyTheme.bgDark,
            child: Column(
              children: [
                const PwaInstallBanner(),
                Expanded(
                  child: child ?? const SizedBox.shrink(),
                ),
              ],
            ),
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}

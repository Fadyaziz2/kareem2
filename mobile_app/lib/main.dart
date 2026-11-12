import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const OqoodyApp());
}

class OqoodyApp extends StatelessWidget {
  const OqoodyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const LoginScreen(),
    );
  }
}

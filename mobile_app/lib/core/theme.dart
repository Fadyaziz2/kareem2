import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OqoodyTheme {
  static const Color primaryDark = Color(0xFF0D2818);
  static const Color primaryEmerald = Color(0xFF1B4D3E);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color bgDark = Color(0xFF081810);
  static const Color cardBg = Color(0xFF133827);
  static const Color textLight = Color(0xFFF4F6F5);
  static const Color textMuted = Color(0xFFA0B2A6);
  static const Color successGreen = Color(0xFF2ECC71);
  static const Color alertRed = Color(0xFFE74C3C);

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryEmerald,
      scaffoldBackgroundColor: bgDark,
      textTheme: GoogleFonts.cairoTextTheme().apply(
        bodyColor: textLight,
        displayColor: textLight,
      ),
      colorScheme: const ColorScheme.dark(
        primary: accentGold,
        secondary: primaryEmerald,
        surface: cardBg,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: primaryDark,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentGold, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textMuted),
      ),
    );
  }
}

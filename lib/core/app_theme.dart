import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoyolaTheme {
  LoyolaTheme._();

  static const Color gold = Color(0xFFD4AF37);
  static const Color deepGold = Color(0xFFB98A2E);
  static const Color lightBackground = Color(0xFFF9F8F4);

  static ThemeData theme = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: gold,
      secondary: gold,
      surface: lightBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    scaffoldBackgroundColor: lightBackground,
    textTheme: GoogleFonts.poppinsTextTheme(),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: lightBackground,
      foregroundColor: Colors.black,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: gold,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: gold.withOpacity(0.2),
    ),
  );

  static BoxDecoration gradientBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white, Color(0xFFF2E6C5)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }
}

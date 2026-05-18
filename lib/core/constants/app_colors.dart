import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF002D80);
  static const Color primaryDark = Color(0xFF00517C);
  static const Color primaryDarker = Color(0xFF003750);
  static const Color primaryLight = Color(0xFFEAF8FC);
  static const Color primaryLighter = Color(0xFFD5F1FA);
  static const Color bottomNavBg = Color(0xFFDDF5FC);

  static const Color textDark = Color(0xFF30343B);
  static const Color textMuted = Color(0xFF9AA5B0);
  static const Color textSecondary = Color(0xFF7D94A5);
  static const Color textNavy = Color(0xFF083F73);

  static const Color green = Color(0xFF20A766);
  static const Color greenLight = Color(0xFFE8F9EE);
  static const Color red = Color(0xFFFF3B30);
  static const Color gold = Color(0xFFFFD700);

  static const Color surface = Color(0xFFF3F7FA);
  static const Color cardBg = Colors.white;
  static const Color divider = Color(0xFFE8EDF2);
  static const Color border = Color(0xFFEAF2F7);
  static const Color searchBg = Color(0xFFF3FBFF);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, primary, primaryDarker],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient primaryGradient135 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient rewardCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryLighter],
  );
}

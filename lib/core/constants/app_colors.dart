import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryCoral = Color(0xFFFF9F7A);
  static const Color primaryCoralDark = Color(0xFFFF7F50);
  static const Color primaryCoralLight = Color(0xFFFFCDB2);

  static const Color primaryBlue = primaryCoral;
  static const Color primaryBlueDark = primaryCoralDark;
  static const Color primaryBlueLight = primaryCoralLight;

  static const Color primary = primaryCoral;
  static const Color primaryLight = primaryCoralLight;
  static const Color primaryDark = primaryCoralDark;

  static const Color accent = Color(0xFFFFB89A);
  static const Color accentAlt = Color(0xFFFFF0EB);

  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textMuted = Color(0xFFAEAEB2);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F7);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF000000);
  static const Color onSurfaceVariant = Color(0xFF8E8E93);

  static const Color success = Color(0xFF4CD964);
  static const Color toggleOn = Color(0xFF4CD964);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color coin = Color(0xFFFFD93D);

  static const Color trueBlack = Color(0xFF000000);
  static const Color darkBackground = Color(0xFF1C1C1E);
  static const Color darkSurface = Color(0xFF2C2C2E);
  static const Color darkCard = Color(0xFF3A3A3C);
  static const Color darkNavBar = Color(0xFF2C2C2E);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryCoralLight, primaryCoral],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFCDB2), primaryCoral],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF0EB), Color(0xFFFFE4D6)],
  );

  static const List<Color> categoryPalette = [
    primaryCoral,
    Color(0xFF4CD964),
    Color(0xFF5AC8FA),
    Color(0xFFA855F7),
    Color(0xFFFF9500),
    Color(0xFF5856D6),
    Color(0xFFFF2D55),
    Color(0xFF8E8E93),
  ];

  static const List<Color> roomColors = [
    primaryCoral,
    Color(0xFF5AC8FA),
    Color(0xFF5856D6),
    Color(0xFF34C759),
    Color(0xFFFF9500),
  ];
}

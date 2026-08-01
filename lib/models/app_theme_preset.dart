import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../widgets/app_ui.dart';

class AppThemePreset {
  final String id;
  final Color primary;
  final Color primaryLight;
  final Color background;
  final Color surface;
  final Color darkBackground;
  final Color darkSurface;
  final LinearGradient headerGradient;
  final LinearGradient balanceGradient;

  const AppThemePreset({
    required this.id,
    required this.primary,
    required this.primaryLight,
    required this.background,
    required this.surface,
    required this.darkBackground,
    required this.darkSurface,
    required this.headerGradient,
    required this.balanceGradient,
  });

  ThemeData lightTheme() => _buildTheme(
        brightness: Brightness.light,
        scaffold: background,
        surfaceColor: surface,
        onSurface: AppColors.onSurface,
      );

  ThemeData darkTheme() => _buildTheme(
        brightness: Brightness.dark,
        scaffold: darkBackground,
        surfaceColor: darkSurface,
        onSurface: const Color(0xFFF1F5F9),
      );

  ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffold,
    required Color surfaceColor,
    required Color onSurface,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primaryLight,
              secondary: primary,
              tertiary: AppColors.accent,
              surface: surfaceColor,
              onSurface: onSurface,
              onPrimary: AppColors.onPrimary,
            )
          : ColorScheme.light(
              primary: primary,
              secondary: primaryLight,
              tertiary: AppColors.accent,
              surface: surfaceColor,
              onPrimary: AppColors.onPrimary,
              onSurface: onSurface,
            ),
      textTheme: AppTypography.textTheme(brightness),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.titleLarge(color: onSurface),
        iconTheme: IconThemeData(color: onSurface),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDark ? primaryLight : primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? darkSurface : AppColors.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? primaryLight : primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: primary.withValues(alpha: 0.15)),
      ),
    );
  }
}

class AppThemePresets {
  AppThemePresets._();

  static const AppThemePreset defaultPreset = AppThemePreset(
    id: 'theme_default',
    primary: AppColors.primaryBlue,
    primaryLight: AppColors.primaryBlueLight,
    background: AppColors.background,
    surface: AppColors.surface,
    darkBackground: AppColors.darkBackground,
    darkSurface: AppColors.darkCard,
    headerGradient: AppColors.headerGradient,
    balanceGradient: AppColors.heroGradient,
  );

  static const AppThemePreset ocean = AppThemePreset(
    id: 'theme_ocean',
    primary: Color(0xFF0EA5E9),
    primaryLight: Color(0xFF7DD3FC),
    background: Color(0xFFF0F9FF),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF0C1929),
    darkSurface: Color(0xFF1E3A5F),
    headerGradient: LinearGradient(colors: [Color(0xFF7DD3FC), Color(0xFF0EA5E9)]),
    balanceGradient: LinearGradient(colors: [Color(0xFF7DD3FC), Color(0xFF0284C7)]),
  );

  static const AppThemePreset forest = AppThemePreset(
    id: 'theme_forest',
    primary: Color(0xFF22C55E),
    primaryLight: Color(0xFF86EFAC),
    background: Color(0xFFF0FDF4),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF0F2A1A),
    darkSurface: Color(0xFF1A3D28),
    headerGradient: LinearGradient(colors: [Color(0xFF86EFAC), Color(0xFF22C55E)]),
    balanceGradient: LinearGradient(colors: [Color(0xFF86EFAC), Color(0xFF16A34A)]),
  );

  static const AppThemePreset sunset = AppThemePreset(
    id: 'theme_sunset',
    primary: Color(0xFFFF8C42),
    primaryLight: Color(0xFFFFD093),
    background: Color(0xFFFFF9F0),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF2A1F0F),
    darkSurface: Color(0xFF3D2E18),
    headerGradient: LinearGradient(colors: [Color(0xFFFFD093), Color(0xFFFF8C42)]),
    balanceGradient: LinearGradient(colors: [Color(0xFFFFB347), Color(0xFFFF8C42)]),
  );

  static const AppThemePreset lavender = AppThemePreset(
    id: 'theme_lavender',
    primary: Color(0xFFA855F7),
    primaryLight: Color(0xFFD8B4FE),
    background: Color(0xFFFAF5FF),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF1E1033),
    darkSurface: Color(0xFF2E1A47),
    headerGradient: LinearGradient(colors: [Color(0xFFD8B4FE), Color(0xFFA855F7)]),
    balanceGradient: LinearGradient(colors: [Color(0xFFA855F7), Color(0xFF9333EA)]),
  );

  static const Map<String, AppThemePreset> byId = {
    'theme_default': defaultPreset,
    'theme_ocean': ocean,
    'theme_forest': forest,
    'theme_sunset': sunset,
    'theme_lavender': lavender,
  };

  static AppThemePreset get(String? id) => byId[id] ?? defaultPreset;
}

class AppBackground {
  final String id;
  final LinearGradient gradient;

  const AppBackground({required this.id, required this.gradient});

  static const AppBackground defaultBg = AppBackground(
    id: 'bg_default',
    gradient: AppColors.accentGradient,
  );

  static const AppBackground clouds = AppBackground(
    id: 'bg_clouds',
    gradient: LinearGradient(colors: [Color(0xFFDBEAFE), Color(0xFFE0E7FF), Color(0xFFBFDBFE)]),
  );

  static const AppBackground stars = AppBackground(
    id: 'bg_stars',
    gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF312E81), Color(0xFF6366F1)]),
  );

  static const AppBackground rainbow = AppBackground(
    id: 'bg_rainbow',
    gradient: LinearGradient(colors: [Color(0xFFDBEAFE), Color(0xFFFDE68A), Color(0xFFBBF7D0), Color(0xFFE9D5FF)]),
  );

  static const AppBackground aurora = AppBackground(
    id: 'bg_aurora',
    gradient: LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6), Color(0xFFEC4899)]),
  );

  static const Map<String, AppBackground> byId = {
    'bg_default': defaultBg,
    'bg_clouds': clouds,
    'bg_stars': stars,
    'bg_rainbow': rainbow,
    'bg_aurora': aurora,
  };

  static AppBackground get(String? id) => byId[id] ?? defaultBg;
}

class CardStyle {
  final String id;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final Color accentColor;
  final bool glassEffect;

  const CardStyle({
    required this.id,
    this.borderRadius = 20,
    this.borderWidth = 0,
    this.borderColor = Colors.transparent,
    this.accentColor = AppColors.primary,
    this.glassEffect = false,
  });

  static const CardStyle defaultStyle = CardStyle(id: 'skin_default');

  static const CardStyle soft = CardStyle(
    id: 'skin_soft',
    borderRadius: 28,
    accentColor: AppColors.primaryBlueLight,
  );

  static const CardStyle glass = CardStyle(
    id: 'skin_glass',
    borderRadius: 24,
    glassEffect: true,
    accentColor: AppColors.primaryBlue,
  );

  static const CardStyle bold = CardStyle(
    id: 'skin_bold',
    borderRadius: 16,
    borderWidth: 2,
    borderColor: AppColors.primaryBlue,
    accentColor: AppColors.primaryBlueDark,
  );

  static const Map<String, CardStyle> byId = {
    'skin_default': defaultStyle,
    'skin_soft': soft,
    'skin_glass': glass,
    'skin_bold': bold,
  };

  static CardStyle get(String? id) => byId[id] ?? defaultStyle;
}

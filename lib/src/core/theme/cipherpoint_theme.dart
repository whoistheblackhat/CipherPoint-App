// CipherPoint Design System - Exact match to website
// Colors from website: --bg-900: #0B1120, --primary: #5bb3ff, --teal: #6de0d0, etc.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CPColors {
  // Background
  static const bg950 = Color(0xFF050A13);
  static const bg900 = Color(0xFF0B1120);  // Main background
  static const bg800 = Color(0xFF111827);
  static const bg700 = Color(0xFF1A2332);

  // Panels & Cards
  static const panel = Color(0xFF0F172A);
  static const panelSoft = Color(0xFF16253D);
  static const card = Color(0xFF0F172A);

  // Borders
  static const line = Color(0x1F94A3B8);     // rgba(148, 163, 184, 0.12)
  static const lineStrong = Color(0x3394A3B8); // rgba(148, 163, 184, 0.20)

  // Text
  static const text = Color(0xFFEDF4FF);
  static const muted = Color(0xFFB9C5D9);

  // Brand
  static const primary = Color(0xFF5BB3FF);
  static const primaryStrong = Color(0xFF3D8EFF);
  static const teal = Color(0xFF6DE0D0);
  static const amber = Color(0xFFF3C37A);
  static const gold = Color(0xFFF6D37D);
  static const success = Color(0xFF6CE3A6);
  static const danger = Color(0xFFFF756F);
  static const purple = Color(0xFFB7A5FF);

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [primary, teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class CPTextStyles {
  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 44, fontWeight: FontWeight.w800, letterSpacing: -0.04,
    height: 1.12, color: CPColors.text,
  );
  static TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -0.04,
    height: 1.12, color: CPColors.text,
  );
  static TextStyle get displaySmall => GoogleFonts.inter(
    fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.04,
    height: 1.12, color: CPColors.text,
  );

  static TextStyle get headlineLarge => GoogleFonts.inter(
    fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.02,
    height: 1.25, color: CPColors.text,
  );
  static TextStyle get headlineMedium => GoogleFonts.inter(
    fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.02,
    height: 1.3, color: CPColors.text,
  );
  static TextStyle get headlineSmall => GoogleFonts.inter(
    fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.01,
    height: 1.35, color: CPColors.text,
  );

  static TextStyle get titleLarge => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0,
    height: 1.4, color: CPColors.text,
  );
  static TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0,
    height: 1.4, color: CPColors.text,
  );
  static TextStyle get titleSmall => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.02,
    height: 1.4, color: CPColors.text,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0,
    height: 1.6, color: CPColors.text,
  );
  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0,
    height: 1.6, color: CPColors.text,
  );
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0,
    height: 1.5, color: CPColors.muted,
  );

  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.02,
    height: 1.4, color: CPColors.text,
  );
  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.05,
    height: 1.4, color: CPColors.text,
  );
  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.08,
    height: 1.4, color: CPColors.muted,
  );

  static TextStyle get eyebrow => GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.09,
    height: 1.4, color: CPColors.teal,
  );

  static TextStyle muted(TextStyle base) => base.copyWith(color: CPColors.muted);
}

class CPSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
}

class CPRadius {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const pill = 999.0;
}

class CPShadows {
  static const card = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 20,
    offset: Offset(0, 4),
  );
  static const modal = BoxShadow(
    color: Color(0x4D000000),
    blurRadius: 40,
    offset: Offset(0, 10),
  );
}

ThemeData createCipherPointTheme() {
  final base = ThemeData.dark();
  return base.copyWith(
    useMaterial3: true,
    scaffoldBackgroundColor: CPColors.bg900,
    canvasColor: CPColors.bg900,
    cardColor: CPColors.card,
    dividerColor: CPColors.line,
    primaryColor: CPColors.primary,
    colorScheme: const ColorScheme.dark(
      primary: CPColors.primary,
      secondary: CPColors.teal,
      surface: CPColors.panel,
      background: CPColors.bg900,
      error: CPColors.danger,
      onPrimary: Color(0xFF07111D),
      onSecondary: Color(0xFF07111D),
      onSurface: CPColors.text,
      onBackground: CPColors.text,
      onError: CPColors.text,
      outline: CPColors.line,
      outlineVariant: CPColors.lineStrong,
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge: CPTextStyles.displayLarge,
      displayMedium: CPTextStyles.displayMedium,
      displaySmall: CPTextStyles.displaySmall,
      headlineLarge: CPTextStyles.headlineLarge,
      headlineMedium: CPTextStyles.headlineMedium,
      headlineSmall: CPTextStyles.headlineSmall,
      titleLarge: CPTextStyles.titleLarge,
      titleMedium: CPTextStyles.titleMedium,
      titleSmall: CPTextStyles.titleSmall,
      bodyLarge: CPTextStyles.bodyLarge,
      bodyMedium: CPTextStyles.bodyMedium,
      bodySmall: CPTextStyles.bodySmall,
      labelLarge: CPTextStyles.labelLarge,
      labelMedium: CPTextStyles.labelMedium,
      labelSmall: CPTextStyles.labelSmall,
    ).apply(bodyColor: CPColors.text, displayColor: CPColors.text),
    appBarTheme: AppBarTheme(
      backgroundColor: CPColors.bg900.withOpacity(0.95),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: CPColors.line,
      centerTitle: false,
      titleTextStyle: CPTextStyles.headlineSmall,
      iconTheme: const IconThemeData(color: CPColors.text, size: 24),
      actionsIconTheme: const IconThemeData(color: CPColors.text, size: 24),
    ),
    cardTheme: CardThemeData(
      color: CPColors.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CPRadius.lg),
        side: const BorderSide(color: CPColors.line),
      ),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: CPColors.text,
        disabledBackgroundColor: CPColors.bg800,
        disabledForegroundColor: CPColors.muted.withOpacity(0.5),
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CPRadius.md),
          side: const BorderSide(color: CPColors.line),
        ),
        textStyle: CPTextStyles.labelLarge,
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return CPColors.primary.withOpacity(0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return CPColors.primary.withOpacity(0.05);
          }
          return null;
        }),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: CPColors.primary,
        foregroundColor: const Color(0xFF07111D),
        disabledBackgroundColor: CPColors.bg800,
        disabledForegroundColor: CPColors.muted.withOpacity(0.5),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CPRadius.md),
        ),
        textStyle: CPTextStyles.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: CPColors.text,
        disabledForegroundColor: CPColors.muted.withOpacity(0.5),
        side: const BorderSide(color: CPColors.lineStrong),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CPRadius.md),
        ),
        textStyle: CPTextStyles.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: CPColors.primary,
        disabledForegroundColor: CPColors.muted.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CPRadius.sm),
        ),
        textStyle: CPTextStyles.labelMedium,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0D1B2A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CPRadius.md),
        borderSide: const BorderSide(color: CPColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CPRadius.md),
        borderSide: const BorderSide(color: CPColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CPRadius.md),
        borderSide: const BorderSide(color: CPColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CPRadius.md),
        borderSide: const BorderSide(color: CPColors.danger),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CPRadius.md),
        borderSide: const BorderSide(color: CPColors.line),
      ),
      labelStyle: CPTextStyles.bodyMedium.copyWith(color: CPColors.muted),
      hintStyle: CPTextStyles.bodyMedium.copyWith(color: CPColors.muted.withOpacity(0.5)),
      floatingLabelStyle: CPTextStyles.labelSmall.copyWith(color: CPColors.primary),
      errorStyle: CPTextStyles.bodySmall.copyWith(color: CPColors.danger),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: CPColors.panel,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CPRadius.xl),
        side: const BorderSide(color: CPColors.line),
      ),
      titleTextStyle: CPTextStyles.headlineMedium,
      contentTextStyle: CPTextStyles.bodyMedium,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: CPColors.panel,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(CPRadius.xl)),
        side: const BorderSide(color: CPColors.line),
      ),
      modalBackgroundColor: CPColors.panel,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: CPColors.bg900,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: CPColors.primary.withOpacity(0.12),
      labelTextStyle: WidgetStateProperty.all(CPTextStyles.labelSmall),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: CPColors.primary, size: 24);
        }
        return const IconThemeData(color: CPColors.muted, size: 24);
      }),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: CPColors.primary,
      unselectedLabelColor: CPColors.muted,
      indicatorColor: CPColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: CPTextStyles.labelMedium,
      unselectedLabelStyle: CPTextStyles.labelMedium,
      dividerColor: Colors.transparent,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: CPColors.bg800,
      disabledColor: CPColors.bg800,
      selectedColor: CPColors.primary.withOpacity(0.16),
      secondarySelectedColor: CPColors.primary.withOpacity(0.16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      labelStyle: CPTextStyles.labelMedium,
      secondaryLabelStyle: CPTextStyles.labelMedium.copyWith(color: CPColors.primary),
      side: const BorderSide(color: CPColors.line),
      selectedSide: const BorderSide(color: CPColors.primary, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CPRadius.pill)),
    ),
    dividerTheme: DividerThemeData(
      color: CPColors.line,
      thickness: 1,
      space: 1,
    ),
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: CPColors.primary.withOpacity(0.08),
      iconColor: CPColors.text,
      textColor: CPColors.text,
      titleTextStyle: CPTextStyles.titleMedium,
      subtitleTextStyle: CPTextStyles.bodySmall,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CPRadius.md)),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: CPColors.bg800,
        borderRadius: BorderRadius.circular(CPRadius.sm),
        border: Border.all(color: CPColors.line),
      ),
      textStyle: CPTextStyles.bodySmall,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: CPColors.bg800,
      contentTextStyle: CPTextStyles.bodyMedium,
      actionTextColor: CPColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CPRadius.md),
        side: const BorderSide(color: CPColors.line),
      ),
      elevation: 0,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: CPColors.primary,
      linearTrackColor: CPColors.bg800,
      circularTrackColor: CPColors.bg800,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return CPColors.success;
        return CPColors.muted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return CPColors.success.withOpacity(0.3);
        return CPColors.bg800;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return WidgetStateProperty.all(CPColors.success);
        return WidgetStateProperty.all(CPColors.line);
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return CPColors.primary;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(const Color(0xFF07111D)),
      side: const BorderSide(color: CPColors.line, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CPRadius.xs)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return CPColors.primary;
        return CPColors.muted;
      }),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: CPColors.primary,
      foregroundColor: const Color(0xFF07111D),
      elevation: 2,
      focusElevation: 4,
      hoverElevation: 4,
      highlightElevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CPRadius.lg)),
    ),
  );
}
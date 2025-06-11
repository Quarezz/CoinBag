// lib/theme.dart
//
// Minimal-expressive Material 3 design system for Flutter.
// --------------------------------------------------------
// • Uses brand palette from AppColors.
// • Light & dark ColorSchemes are seed-generated for tonal
//   consistency, then adjusted to your key colours.
// • Commonly-touched components are themed; everything else
//   inherits from ColorScheme so maintenance stays simple.
//
// How to use:
//   MaterialApp(
//     theme: AppTheme.light(),
//     darkTheme: AppTheme.dark(),
//     themeMode: ThemeMode.system,
//     home: MyHome(),
//   );
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Brand palette
/// ========================================================
class AppColors {
  AppColors._(); // no instances

  // --- Primary ---------------------------------------------------
  static const Color primary100 = Color(0xFFE0ECFE);
  static const Color primary200 = Color(0xFFC1D8FD);
  static const Color primary300 = Color(0xFFA2C1FB);
  static const Color primary400 = Color(0xFF8AACF8);
  static const Color primary500 = Color(0xFF648DF4);
  static const Color primary600 = Color(0xFF496CD1);
  static const Color primary700 = Color(0xFF324EAF);
  static const Color primary800 = Color(0xFF1F358D);
  static const Color primary900 = Color(0xFF132375);

  // --- Success (secondary) --------------------------------------
  static const Color success100 = Color(0xFFECFBD3);
  static const Color success200 = Color(0xFFD4F8A8);
  static const Color success300 = Color(0xFFB1EA79);
  static const Color success400 = Color(0xFF8DD655);
  static const Color success500 = Color(0xFF5DBC25);
  static const Color success600 = Color(0xFF44A11B);
  static const Color success700 = Color(0xFF2F8712);
  static const Color success800 = Color(0xFF1E6D0B);
  static const Color success900 = Color(0xFF115A07);

  // --- Info (tertiary) ------------------------------------------
  static const Color info100 = Color(0xFFE7EDFE);
  static const Color info200 = Color(0xFFD0DBFE);
  static const Color info300 = Color(0xFFB8C8FD);
  static const Color info400 = Color(0xFFA6B8FB);
  static const Color info500 = Color(0xFF899EF9);
  static const Color info600 = Color(0xFF6477D6);
  static const Color info700 = Color(0xFF4555B3);
  static const Color info800 = Color(0xFF2B3890);
  static const Color info900 = Color(0xFF1A2477);

  // --- Warning ---------------------------------------------------
  static const Color warning100 = Color(0xFFFEF9CE);
  static const Color warning200 = Color(0xFFFEF29D);
  static const Color warning300 = Color(0xFFFEE96C);
  static const Color warning400 = Color(0xFFFDDF48);
  static const Color warning500 = Color(0xFFFCD00C);
  static const Color warning600 = Color(0xFFD8AE08);
  static const Color warning700 = Color(0xFFB58E06);
  static const Color warning800 = Color(0xFF926F03);
  static const Color warning900 = Color(0xFF785A02);

  // --- Danger / Error -------------------------------------------
  static const Color danger100 = Color(0xFFFFEBD3);
  static const Color danger200 = Color(0xFFFFD2A9);
  static const Color danger300 = Color(0xFFFFB47E);
  static const Color danger400 = Color(0xFFFF965D);
  static const Color danger500 = Color(0xFFFF6528);
  static const Color danger600 = Color(0xFFDB461D);
  static const Color danger700 = Color(0xFFB72C14);
  static const Color danger800 = Color(0xFF93170C);
  static const Color danger900 = Color(0xFF7A0807);
}

/// Central theme builder
/// ========================================================
class AppTheme {
  static const _seed = AppColors.primary500; // keep tonal tie-in

  /// Light theme
  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary500,
          onPrimary: Colors.white,
          secondary: AppColors.success500,
          error: AppColors.danger500,
          tertiary: AppColors.info500,
        );

    return _base(scheme);
  }

  /// Dark theme
  static ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.primary400,
          onPrimary: Colors.black,
          secondary: AppColors.success400,
          error: AppColors.danger400,
          tertiary: AppColors.info400,
        );

    return _base(scheme);
  }

  /// Shared definitions
  static ThemeData _base(ColorScheme scheme) {
    // Base app-bar (re-used below for system overlay tweaks)
    final baseAppBarTheme = AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: scheme.primary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,

      // Typography - latest Material 3 defaults with custom colors for headlines
      typography: Typography.material2021().copyWith(
        black: Typography.material2021().black.copyWith(
          headlineLarge: TextStyle(color: scheme.primary),
          headlineMedium: TextStyle(color: scheme.primary),
          headlineSmall: TextStyle(color: scheme.primary),
        ),
        white: Typography.material2021().white.copyWith(
          headlineLarge: TextStyle(color: scheme.primary),
          headlineMedium: TextStyle(color: scheme.primary),
          headlineSmall: TextStyle(color: scheme.primary),
        ),
      ),
      fontFamily: 'Fixel',

      // Surfaces
      scaffoldBackgroundColor: scheme.background,
      cardTheme: const CardThemeData(
        margin: EdgeInsets.all(8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withOpacity(.2),
        space: 0.5,
        thickness: 0.5,
      ),

      // App bar (with system status-bar blending)
      appBarTheme: baseAppBarTheme.copyWith(
        systemOverlayStyle: scheme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      // Buttons ----------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          foregroundColor: scheme.primary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: scheme.outline),
          foregroundColor: scheme.primary,
        ),
      ),

      // FAB - zero elevation, pill-ish rect
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        elevation: 0,
      ),

      // Chips
      chipTheme: ChipThemeData(
        color: MaterialStatePropertyAll(scheme.surfaceVariant),
        selectedColor: scheme.primaryContainer,
        disabledColor: scheme.onSurface.withOpacity(.12),
        secondarySelectedColor: scheme.primaryContainer,
        labelStyle: TextStyle(color: scheme.onSurface),
        secondaryLabelStyle: TextStyle(color: scheme.onPrimaryContainer),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: const StadiumBorder(),
      ),

      // Icon buttons
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(48),
          padding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          backgroundColor: Colors.transparent,
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceVariant,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),

      // Navigation bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // Snackbars
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Tab-bar with pill indicator
      tabBarTheme: TabBarThemeData(
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
        indicator: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        labelColor: scheme.onPrimaryContainer,
        unselectedLabelColor: scheme.onSurfaceVariant,
      ),

      // Bottom sheet
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        elevation: 0,
      ),

      // Segmented button (Material 3)
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith<Color?>(
            (s) => s.contains(MaterialState.selected)
                ? scheme.onPrimary
                : scheme.onSurfaceVariant,
          ),
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (s) => s.contains(MaterialState.selected)
                ? scheme.primary
                : scheme.surfaceVariant,
          ),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),

      // Toggles (switch & checkbox)
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStatePropertyAll(scheme.primary),
        trackColor: MaterialStatePropertyAll(scheme.primary.withOpacity(.5)),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStatePropertyAll(scheme.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}

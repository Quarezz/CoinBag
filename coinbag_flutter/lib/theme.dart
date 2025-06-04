import 'package:flutter/material.dart';

/// Light theme for CoinBag using a vibrant expressive color scheme.
final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.light,
  seedColor: Color(0xFF6750A4),
);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _lightColorScheme,
  appBarTheme: AppBarTheme(
    backgroundColor: _lightColorScheme.primary,
    foregroundColor: _lightColorScheme.onPrimary,
  ),
  scaffoldBackgroundColor: _lightColorScheme.background,
);

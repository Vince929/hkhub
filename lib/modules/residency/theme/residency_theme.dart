import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tool_accents.dart';

/// Residency's own palette and theme overlay.
///
/// Only colours live here. Radius, spacing, semantic levels and the card
/// recipe are inherited from [AppTheme], so every tool keeps one surface
/// language while each tool keeps its own accent.
///
/// The accent is sourced from [ToolAccents] so the module sits in the same
/// lightness band as every other tool (see `docs/UI风格规范.md` §3). The value
/// is unchanged, so this is a pure de-duplication.
abstract final class ResidencyTheme {
  static const plum = ToolAccents.violet;
  static const gold = Color(0xFFB07A1E);
  static const background = Color(0xFFF5F4FA);
  static const ink = Color(0xFF242140);
  static const muted = Color(0xFF6B6785);
  static const line = Color(0xFFE7E5F2);
  static const container = Color(0xFFEDEBFA);
  static const field = Color(0xFFF2F1F9);

  // Mid-tone hero card palette, shared by the progress card and the share card
  // so the two never drift. Tune here to adjust both at once.
  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8175D0), Color(0xFF5D4FAB)],
  );
  static const cardSubtle = Color(0xFFD9D3F2);
  static const cardHighlight = Color(0xFFF7DC9A);
  static const cardBar = Color(0xFFF0C97A);

  /// Overlays the residency colours onto the global theme.
  static ThemeData apply(ThemeData base) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none,
    );
    return base.copyWith(
      extensions: AppTheme.tdesignExtensions(base, plum, ink, background),
      colorScheme: base.colorScheme.copyWith(
        primary: plum, secondary: gold,
        primaryContainer: container,
        onPrimaryContainer: ink,
        surface: Colors.white, onSurface: ink,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: background, foregroundColor: ink,
        titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: field,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        border: border, enabledBorder: border, disabledBorder: border,
        focusedBorder: border.copyWith(borderSide: const BorderSide(color: plum, width: 1.5)),
        errorBorder: border.copyWith(borderSide: BorderSide(color: base.colorScheme.error)),
        focusedErrorBorder: border.copyWith(borderSide: BorderSide(color: base.colorScheme.error, width: 1.5)),
        hintStyle: const TextStyle(color: muted, fontSize: 14),
        helperStyle: const TextStyle(color: muted, fontSize: 12, height: 1.5),
        errorMaxLines: 3,
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        backgroundColor: plum, foregroundColor: Colors.white,
        minimumSize: const Size(48, 56), elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      )),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
        foregroundColor: plum, minimumSize: const Size(48, 52),
        side: const BorderSide(color: line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      )),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: plum)),
      dividerTheme: const DividerThemeData(color: line, space: 1),
    );
  }
}

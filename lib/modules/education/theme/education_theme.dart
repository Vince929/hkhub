import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tool_accents.dart';

/// Education's own palette and theme overlay.
///
/// Only colours live here. Radius, spacing, semantic levels and the card
/// recipe are inherited from [AppTheme], so every tool keeps one surface
/// language while each tool keeps its own accent.
///
/// The two accents are sourced from [ToolAccents] so the module sits in the
/// same lightness band as every other tool (see `docs/UI风格规范.md` §3).
abstract final class EducationTheme {
  static const blue = ToolAccents.indigo;
  static const teal = ToolAccents.jade;
  static const background = Color(0xFFF4F7FC);
  static const ink = Color(0xFF15324D);
  static const muted = Color(0xFF65788C);
  static const line = Color(0xFFE5ECF5);
  static const field = Color(0xFFF3F6FB);
  static const notice = Color(0xFFEAF0FF);

  /// Overlays the education colours onto the global theme.
  static ThemeData apply(ThemeData base) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none,
    );
    return base.copyWith(
      extensions: AppTheme.tdesignExtensions(base, blue, ink, background),
      colorScheme: base.colorScheme.copyWith(
        primary: blue, secondary: teal,
        primaryContainer: notice,
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
        border: border, enabledBorder: border,
        disabledBorder: border,
        focusedBorder: border.copyWith(borderSide: const BorderSide(color: blue, width: 1.5)),
        errorBorder: border.copyWith(borderSide: BorderSide(color: base.colorScheme.error)),
        focusedErrorBorder: border.copyWith(borderSide: BorderSide(color: base.colorScheme.error, width: 1.5)),
        hintStyle: const TextStyle(color: muted, fontSize: 14),
        helperStyle: const TextStyle(color: muted, fontSize: 12, height: 1.5),
        errorMaxLines: 3,
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        backgroundColor: blue, foregroundColor: Colors.white,
        minimumSize: const Size(48, 56), elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      )),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
        foregroundColor: blue, minimumSize: const Size(48, 52),
        side: const BorderSide(color: line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      )),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: blue)),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: const BorderSide(color: muted, width: 1.3),
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        iconColor: blue, collapsedIconColor: muted,
        textColor: ink, collapsedTextColor: ink,
        shape: Border(), collapsedShape: Border(),
      ),
      dividerTheme: const DividerThemeData(color: line, space: 1),
    );
  }
}

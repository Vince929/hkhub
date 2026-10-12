import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const harborBlue = Color(0xFF164B71);
  static const ferryGreen = Color(0xFF147D74);
  static const signalAmber = Color(0xFFBA771B);
  static const mist = Color(0xFFF3F7FA);
  static const ink = Color(0xFF183247);

  // Education has a focused visual system without changing other tools.
  static const studyBlue = Color(0xFF326BEB);
  static const studyTeal = Color(0xFF12897F);
  static const studyBackground = Color(0xFFF4F7FC);
  static const studyInk = Color(0xFF15324D);
  static const studyMuted = Color(0xFF65788C);
  static const studyLine = Color(0xFFE5ECF5);

  static ThemeData education(ThemeData base) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none,
    );
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: studyBlue, secondary: studyTeal,
        primaryContainer: const Color(0xFFEAF0FF),
        onPrimaryContainer: studyInk,
        surface: Colors.white, onSurface: studyInk,
      ),
      scaffoldBackgroundColor: studyBackground,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: studyBackground, foregroundColor: studyInk,
        titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: studyInk),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: const Color(0xFFF3F6FB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        border: border, enabledBorder: border,
        disabledBorder: border,
        focusedBorder: border.copyWith(borderSide: const BorderSide(color: studyBlue, width: 1.5)),
        errorBorder: border.copyWith(borderSide: BorderSide(color: base.colorScheme.error)),
        focusedErrorBorder: border.copyWith(borderSide: BorderSide(color: base.colorScheme.error, width: 1.5)),
        hintStyle: const TextStyle(color: studyMuted, fontSize: 14),
        helperStyle: const TextStyle(color: studyMuted, fontSize: 12, height: 1.5),
        errorMaxLines: 3,
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        backgroundColor: studyBlue, foregroundColor: Colors.white,
        minimumSize: const Size(48, 56), elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      )),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
        foregroundColor: studyBlue, minimumSize: const Size(48, 52),
        side: const BorderSide(color: studyLine),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      )),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: studyBlue)),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: const BorderSide(color: studyMuted, width: 1.3),
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        iconColor: studyBlue, collapsedIconColor: studyMuted,
        textColor: studyInk, collapsedTextColor: studyInk,
        shape: Border(), collapsedShape: Border(),
      ),
      dividerTheme: const DividerThemeData(color: studyLine, space: 1),
    );
  }

  static ThemeData get light {
    final colors = ColorScheme.fromSeed(
      seedColor: harborBlue,
      primary: harborBlue,
      secondary: ferryGreen,
      surface: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: mist,
      appBarTheme: const AppBarTheme(
        backgroundColor: mist,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFDFE8EE), space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

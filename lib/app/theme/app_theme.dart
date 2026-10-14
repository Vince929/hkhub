import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// Global theme: the baseline every tool inherits.
///
/// Module palettes and module theme overlays live next to their module, in
/// `lib/modules/<module>/theme/`. Only truly shared things stay here:
/// the base palette, the card/surface recipe, semantic levels and the
/// Material + TDesign baseline.
///
/// Colour follows a three-tier model (see `docs/UI风格规范.md`):
///  1. structure / brand (deep) — the constants below;
///  2. categorical (mid band) — `ToolAccents`;
///  3. semantic status — the `level*` constants and [signalAmber].
/// Never mix the tiers: actions use tier 1, categorisation uses tier 2, status
/// uses tier 3.
abstract final class AppTheme {
  /// Deep harbour blue: the structural anchor (arrival accents, deep surfaces).
  static const harborBlue = Color(0xFF164B71);

  /// Ferry green-teal: the brand primary — actions, links and app chrome
  /// (青色为主).
  static const ferryGreen = Color(0xFF147D74);

  /// Amber for warnings, delays and status emphasis.
  static const signalAmber = Color(0xFFBA771B);
  static const mist = Color(0xFFF3F7FA);
  static const ink = Color(0xFF183247);

  // Shared card recipe every tool builds on, so surfaces stay consistent.
  static const surfaceLine = Color(0xFFE4ECF4);
  static const cardRadius = 24.0;

  // Shared semantic levels for status chips.
  static const levelLow = Color(0xFF2F9E68);
  static const levelMedium = Color(0xFFC07A16);
  static const levelHigh = Color(0xFFC0392F);
  static const levelNeutral = Color(0xFF65788C);

  static BoxDecoration cardSurface({Color color = Colors.white, Color? line}) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(cardRadius),
    border: Border.all(color: line ?? surfaceLine),
  );

  static BoxDecoration tinted(Color accent, {double radius = 18, double alpha = 0.06}) =>
      BoxDecoration(color: accent.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(radius));

  static TDThemeData _tdesign(Color primary, Color text, Color background) =>
      TDThemeData.defaultData().copyWithTDThemeData(
        'hkhub-${primary.toARGB32()}',
        colorMap: {
          'brandColor7': primary,
          'brandNormalColor': primary,
          'brandHoverColor': Color.lerp(primary, Colors.white, 0.12)!,
          'brandClickColor': Color.lerp(primary, Colors.black, 0.12)!,
          'brandLightColor': Color.lerp(primary, Colors.white, 0.93)!,
          'brandFocusColor': Color.lerp(primary, Colors.white, 0.85)!,
          'brandDisabledColor': Color.lerp(primary, Colors.white, 0.65)!,
          'textColorBrand': primary,
          'textColorLink': primary,
          'textColorPrimary': text,
          'bgColorPage': background,
        },
        radiusMap: {'radiusDefault': 12, 'radiusLarge': 16, 'radiusExtraLarge': 24},
      );

  /// Replaces the TDesign extension so a module can re-brand its controls
  /// without touching any other global token.
  static Iterable<ThemeExtension<dynamic>> tdesignExtensions(
      ThemeData base, Color primary, Color text, Color background) => [
    ...base.extensions.values.where((extension) => extension is! TDThemeData),
    _tdesign(primary, text, background),
  ];

  static ThemeData get light {
    final colors = ColorScheme.fromSeed(
      seedColor: ferryGreen,
      primary: ferryGreen,
      secondary: harborBlue,
      surface: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      extensions: [_tdesign(ferryGreen, ink, mist)],
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

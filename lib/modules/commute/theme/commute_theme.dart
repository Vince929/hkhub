import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';

/// Commute-only surface colours.
///
/// The commute accent now follows the brand primary (ferry green-teal), so the
/// flagship tool reads as one with the rest of the app as the palette moves to
/// 青色为主 (see `docs/UI风格规范.md`). Radius, semantic levels and the card
/// recipe still stay in `AppTheme`.
abstract final class CommuteTheme {
  /// Module accent = the brand primary.
  static const accent = AppTheme.ferryGreen;

  /// Directional partner for the arrival (entry) queue block: the deep harbour
  /// blue, kept so arrival and departure never read as the same thing.
  static const accentDeep = AppTheme.harborBlue;

  /// Soft teal tints for the hero card, matched to [accent].
  static const tintTop = Color(0xFFD2E9E5);
  static const tintBottom = Color(0xFFEBF5F3);
  static const tintLine = Color(0xFFC0DCD7);
}

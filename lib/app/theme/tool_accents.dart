import 'package:flutter/material.dart';

/// The single source of truth for **categorical** colour in HK Hub.
///
/// HK Hub uses a three-tier colour model (see `docs/UI风格规范.md`):
///
///  1. **Structure / brand** (deep) — `AppTheme.harborBlue`,
///     `AppTheme.ferryGreen`. Reserved for chrome, headers and primary actions.
///  2. **Categorical** (mid, this file) — the palette below. Used to *encode*
///     tool groups on the home grid, chart series and tags.
///  3. **Semantic** — `AppTheme.levelLow/Medium/High/Neutral`, `signalAmber`.
///     Status only, never branding or categorisation.
///
///
/// The six categorical accents share one lightness band (HSL lightness ≈ 46%)
/// so any two of them can sit side by side without one looking heavier than the
/// other. Never introduce a categorical colour outside this list.
abstract final class ToolAccents {
  /// Cross-border commute — the harbour / sailing green-teal.
  static const jade = Color(0xFF3BB0A6);

  /// Residency and identity — the established plum, kept verbatim.
  static const violet = Color(0xFF5A4E9E);

  /// Education and school applications.
  static const indigo = Color(0xFF3B62B0);

  /// Business, licences and data exports.
  static const amber = Color(0xFFB06C3B);

  /// Alerts and risk (categorical; distinct from `AppTheme.signalAmber`).
  static const rose = Color(0xFFB03B62);

  /// Growth, progress and positive emphasis.
  static const olive = Color(0xFF7E9E3B);

  /// The complete categorical palette.
  ///
  /// Order is stable and participates in the fallback hash: **append new colours
  /// at the end only**, never reorder, otherwise existing fallback colours shift.
  static const List<Color> palette = [jade, violet, indigo, amber, rose, olive];

  /// Explicit assignments for the groups we ship today.
  ///
  /// A group missing here falls back to a stable hash, so a brand new
  /// server-side group still receives a fixed colour with zero code change.
  static const Map<String, Color> _byGroup = {
    'new_hongkongers': jade,
  };

  /// Explicit assignments for individual tools, when a per-tool colour is
  /// needed (rare — prefer group-level encoding).
  static const Map<String, Color> _byFeature = {
    'commute': jade,
    'residency': violet,
    'education': indigo,
    'business': amber,
  };

  /// Accent for a home-grid **group**. Colour encodes the group, not the tool,
  /// so growing the catalogue never exhausts the palette.
  static Color forGroup(String groupId) =>
      _byGroup[groupId] ?? palette[_stableHash(groupId) % palette.length];

  /// Accent for a single tool, for the rare case a colour must follow the tool
  /// rather than its group.
  static Color forFeature(String featureId) =>
      _byFeature[featureId] ?? palette[_stableHash(featureId) % palette.length];

  /// FNV-1a style hash so a given id always maps to the same colour across
  /// launches, platforms and Dart versions. `String.hashCode` gives no such
  /// guarantee, so it must not be used here.
  static int _stableHash(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash = (hash ^ unit) * 0x01000193 & 0x7fffffff;
    }
    return hash;
  }
}

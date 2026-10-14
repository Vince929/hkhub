import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../data/residency_calculator.dart';
import '../theme/residency_theme.dart';
import 'residency_strings.dart';

/// Renewal reminder: multi-level App-only prompt plus a static checklist that
/// varies by the recorded visa type. No push, no server call (D10, D17).
class ResidencyRenewalSection extends StatelessWidget {
  const ResidencyRenewalSection({
    super.key,
    required this.status,
    required this.visaType,
    required this.strings,
  });

  final RenewalStatus status;
  final String? visaType;
  final ResidencyStrings strings;

  static const _urgent = Color(0xFFB23E37);

  Color get _accent => switch (status.level) {
    RenewalLevel.urgent => _urgent,
    RenewalLevel.soon => AppTheme.signalAmber,
    RenewalLevel.upcoming => ResidencyTheme.plum,
    RenewalLevel.none => ResidencyTheme.muted,
  };

  String get _levelKey => switch (status.level) {
    RenewalLevel.urgent => 'urgent',
    RenewalLevel.soon => 'soon',
    RenewalLevel.upcoming => 'upcoming',
    RenewalLevel.none => 'none',
  };

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ResidencyTheme.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Icon(Icons.badge_outlined, size: 20, color: ResidencyTheme.plum),
          const SizedBox(width: 9),
          Expanded(child: Text(strings.renewalTitle, style: const TextStyle(
            fontSize: 17, fontWeight: FontWeight.w700, color: ResidencyTheme.ink))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(strings.renewalLevelName(_levelKey), style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: accent)),
          ),
        ]),
        const SizedBox(height: 10),
        Text(
          status.daysRemaining >= 0
              ? strings.renewalDaysLeft(status.daysRemaining)
              : strings.renewalExpired,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: accent),
        ),
        const SizedBox(height: 6),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 8),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            shape: const Border(), collapsedShape: const Border(),
            initiallyExpanded: status.level != RenewalLevel.none,
            title: Text(strings.renewalChecklistTitle, style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: ResidencyTheme.ink)),
            children: [
              for (final item in strings.renewalChecklist(visaType))
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 16, color: ResidencyTheme.plum),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item, style: const TextStyle(
                      fontSize: 13, height: 1.5, color: ResidencyTheme.ink))),
                  ]),
                ),
              const SizedBox(height: 4),
              Text(strings.renewalNotice, style: const TextStyle(
                fontSize: 11.5, height: 1.5, color: ResidencyTheme.muted)),
            ],
          ),
        ),
      ]),
    );
  }
}

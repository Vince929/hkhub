import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../data/commute_models.dart';
import 'commute_strings.dart';

/// Colour assists the label but never carries the meaning on its own.
Color statusColor(QueueStatus status) => switch (status) {
  QueueStatus.normal => AppTheme.ferryGreen,
  QueueStatus.busy => AppTheme.signalAmber,
  QueueStatus.veryBusy => const Color(0xFFC0392B),
  _ => const Color(0xFF65788C),
};

class CommuteSectionCard extends StatelessWidget {
  const CommuteSectionCard({super.key, required this.title, this.trailing, required this.child});

  final String title;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EAF1)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700, color: AppTheme.ink,
          ))),
          if (trailing != null) trailing!,
        ]),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}

class CommuteStatusChip extends StatelessWidget {
  const CommuteStatusChip({super.key, required this.label, required this.status, this.prominent = false});

  final String label;
  final QueueStatus status;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: prominent ? 12 : 10, vertical: prominent ? 6 : 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: prominent ? 15 : 13,
        ),
      ),
    );
  }
}

/// One audience's Hong Kong inbound queue status, with the state explained in words.
class CommuteQueueRow extends StatelessWidget {
  const CommuteQueueRow({
    super.key,
    required this.strings,
    required this.audience,
    required this.label,
    required this.state,
    this.prominent = false,
  });

  final CommuteStrings strings;
  final CommuteAudience audience;
  final String label;
  final QueueState state;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final detail = strings.statusDetail(state.status, audience);
    final parts = [
      if (detail != null) detail,
      strings.freshnessLabel(state.freshness),
      strings.fetchedAt(state.observedAt),
    ];
    return Semantics(
      label: '$label ${strings.statusLabel(state.status)}',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(label, style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF65788C),
            ))),
            const SizedBox(width: 8),
            CommuteStatusChip(
              label: strings.statusLabel(state.status),
              status: state.status,
              prominent: prominent,
            ),
          ]),
          const SizedBox(height: 6),
          Text(parts.join(' · '), style: const TextStyle(fontSize: 12, color: Color(0xFF65788C))),
          if (state.status == QueueStatus.maintenance)
            _note(strings.systemMaintenanceNote),
          if (state.status == QueueStatus.nonService)
            _note(strings.nonServiceNote),
        ]),
      ),
    );
  }

  Widget _note(String text) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF65788C))),
  );
}

/// Audience choice is remembered on device. Selecting is only offered between the two
/// official groups; the app never infers a traveller's status from language or location.
class CommuteAudienceSwitch extends StatelessWidget {
  const CommuteAudienceSwitch({
    super.key,
    required this.strings,
    required this.selected,
    required this.onSelected,
  });

  final CommuteStrings strings;
  final CommuteAudience? selected;
  final ValueChanged<CommuteAudience> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(strings.audienceLabel, style: const TextStyle(
        fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF65788C),
      )),
      const SizedBox(height: 8),
      SegmentedButton<CommuteAudience>(
        segments: [
          ButtonSegment(
            value: CommuteAudience.resident,
            label: Text(strings.audienceResident),
          ),
          ButtonSegment(
            value: CommuteAudience.visitor,
            label: Text(strings.audienceVisitor),
          ),
        ],
        selected: selected == null ? const <CommuteAudience>{} : <CommuteAudience>{selected!},
        emptySelectionAllowed: true,
        showSelectedIcon: false,
        onSelectionChanged: (values) {
          if (values.isNotEmpty) onSelected(values.first);
        },
      ),
      if (selected == null) Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(strings.audienceUnselected, style: const TextStyle(
          fontSize: 12, color: Color(0xFF65788C),
        )),
      ),
    ]);
  }
}

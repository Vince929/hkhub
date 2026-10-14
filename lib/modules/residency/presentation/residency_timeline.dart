import 'package:flutter/material.dart';

import '../data/residency_calculator.dart';
import '../data/residency_models.dart';
import '../theme/residency_theme.dart';
import 'residency_strings.dart';

/// Shows the journey as a rolling window: the most recent achieved nodes plus
/// the single next node, never all 84 at once.
class ResidencyTimeline extends StatelessWidget {
  const ResidencyTimeline({
    super.key,
    required this.window,
    required this.strings,
    this.recentLimit = 6,
  });

  final MilestoneWindow window;
  final ResidencyStrings strings;
  final int recentLimit;

  @override
  Widget build(BuildContext context) {
    final recent = window.recent(recentLimit);
    final next = window.next;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ResidencyTheme.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Icon(Icons.timeline_rounded, size: 20, color: ResidencyTheme.plum),
          const SizedBox(width: 9),
          Expanded(child: Text(strings.timelineTitle, style: const TextStyle(
            fontSize: 17, fontWeight: FontWeight.w700, color: ResidencyTheme.ink))),
        ]),
        Text(strings.timelineHint, style: const TextStyle(fontSize: 12, color: ResidencyTheme.muted)),
        const SizedBox(height: 14),
        Text(strings.timelineCount(window.achievedCount, window.total),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ResidencyTheme.plum)),
        const SizedBox(height: 12),
        for (final node in recent) _node(context, node, done: true),
        if (next != null) ...[
          const SizedBox(height: 6),
          Text(strings.nextMilestone.toUpperCase(), style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: ResidencyTheme.gold)),
          const SizedBox(height: 8),
          _node(context, next, done: false),
        ] else ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.emoji_events_rounded, size: 18, color: ResidencyTheme.gold),
            const SizedBox(width: 8),
            Expanded(child: Text(strings.allMilestonesDone, style: const TextStyle(
              fontSize: 13, height: 1.5, color: ResidencyTheme.ink))),
          ]),
        ],
      ]),
    );
  }

  Widget _node(BuildContext context, Milestone node, {required bool done}) {
    final isYear = node.kind == MilestoneKind.year;
    final accent = isYear ? ResidencyTheme.gold : ResidencyTheme.plum;
    final label = isYear ? strings.yearLabel(node.index) : strings.monthLabel(node.index);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          width: 34, height: 34, alignment: Alignment.center,
          decoration: BoxDecoration(
            color: done ? accent.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: done ? null : Border.all(color: accent.withValues(alpha: 0.5)),
          ),
          child: Icon(
            done ? Icons.check_rounded : (isYear ? Icons.star_outline_rounded : Icons.circle_outlined),
            size: 17, color: accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(
            fontSize: 14, fontWeight: isYear ? FontWeight.w700 : FontWeight.w600,
            color: done ? ResidencyTheme.ink : ResidencyTheme.muted)),
          const SizedBox(height: 2),
          Text(_iso(node.date), style: const TextStyle(fontSize: 11.5, color: ResidencyTheme.muted)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: (done ? accent : ResidencyTheme.muted).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(done ? strings.milestoneDone : strings.milestonePending,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: done ? accent : ResidencyTheme.muted)),
        ),
      ]),
    );
  }

  static String _iso(DateTime date) => '${date.year.toString().padLeft(4, '0')}'
      '-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

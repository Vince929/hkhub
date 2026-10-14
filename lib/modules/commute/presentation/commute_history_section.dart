import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/hk_sail_mark.dart';
import '../data/commute_models.dart';
import '../data/commute_providers.dart';
import '../theme/commute_theme.dart';
import 'commute_strings.dart';
import 'commute_widgets.dart';

class CommuteHistorySection extends ConsumerWidget {
  const CommuteHistorySection({super.key, required this.code});
  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = CommuteStrings(Localizations.localeOf(context));
    return CommuteSection(title: copy.historyTitle, subtitle: copy.historyNotice,
      icon: Icons.insights_rounded,
      child: Column(children: [
        for (final direction in directions)
          ref.watch(historyProvider((code, queueAudience, direction))).when(
            data: (history) => _HistoryContent(history: history, direction: direction),
            error: (_, _) => CommuteFailure(retry: () => ref.invalidate(
              historyProvider((code, queueAudience, direction)))),
            loading: () => const HkSailLoader(),
          ),
      ]));
  }
}

class _HistoryContent extends StatelessWidget {
  const _HistoryContent({required this.history, required this.direction});
  final HistoryData history;
  final String direction;

  @override
  Widget build(BuildContext context) {
    final copy = CommuteStrings(Localizations.localeOf(context));
    final comparison = history.inCurrentSlot ? history.comparison : null;
    final weekly = comparison?.wholeWeek == true
        ? copy.weekly(comparison!.position, history.current.code) : '';
    return Container(padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardSurface(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text('${history.slotStart}–${history.slotEnd} · ${copy.directionName(direction)}',
            style: const TextStyle(color: CommuteTheme.accent, fontSize: 17, fontWeight: FontWeight.w700))),
          if (history.inCurrentSlot) QueueLevelChip(queue: history.current, now: history.serverTime),
        ]),
        Padding(padding: const EdgeInsets.only(top: 14),
          child: Text(copy.coverage(history.validCount), style: const TextStyle(
            color: AppTheme.ink, fontSize: 16, fontWeight: FontWeight.w700))),
        if (!history.inCurrentSlot) Padding(padding: const EdgeInsets.only(top: 8),
          child: Text(copy.refreshHistory))
        else if (history.validCount > 0 && comparison == null) Padding(
          padding: const EdgeInsets.only(top: 8), child: Text(copy.noCurrentSlot))
        else if (comparison != null) Padding(padding: const EdgeInsets.only(top: 8),
          child: Text(copy.comparison(comparison))),
        if (weekly.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 10),
          child: Text(weekly, style: const TextStyle(color: AppTheme.ferryGreen, fontWeight: FontWeight.w700))),
        const SizedBox(height: 16),
        for (final day in history.days) _DayRow(day: day),
      ]));
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day});
  final HistoryDay day;

  @override
  Widget build(BuildContext context) {
    final copy = CommuteStrings(Localizations.localeOf(context));
    final queue = day.queue;
    final color = queueColor(queue);
    return Padding(padding: const EdgeInsets.symmetric(vertical: 9), child: Row(children: [
      Expanded(child: Text(day.date)),
      if (queue.reason == 'available') ...[
        for (var level = 0; level < 3; level++) Padding(
          padding: const EdgeInsets.only(right: 4),
          child: ExcludeSemantics(child: Container(width: 8, height: 18,
            decoration: BoxDecoration(color: level <= queue.code! ? color : AppTheme.mist,
              borderRadius: BorderRadius.circular(3)))),
        ),
        const SizedBox(width: 10),
      ],
      Flexible(child: Text(copy.queueLabel(queue), style: TextStyle(color: color, fontWeight: FontWeight.w600))),
    ]));
  }
}

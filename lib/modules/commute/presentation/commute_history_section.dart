import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../data/commute_models.dart';
import '../data/commute_providers.dart';
import 'commute_strings.dart';
import 'commute_widgets.dart';

class CommuteHistorySection extends ConsumerWidget {
  const CommuteHistorySection({super.key, required this.code});
  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = CommuteStrings(Localizations.localeOf(context));
    final audience = ref.watch(commutePreferencesProvider).audience;
    return CommuteSection(title: copy.historyTitle, subtitle: copy.historyNotice,
      child: audience == null ? Text(copy.chooseForHistory) : ref.watch(historyProvider((code, audience))).when(
        data: (history) => _HistoryContent(history: history, audience: audience),
        error: (_, _) => CommuteFailure(retry: () => ref.invalidate(historyProvider((code, audience)))),
        loading: () => const Center(child: CircularProgressIndicator()),
      ));
  }
}

class _HistoryContent extends StatelessWidget {
  const _HistoryContent({required this.history, required this.audience});
  final HistoryData history;
  final String audience;

  @override
  Widget build(BuildContext context) {
    final copy = CommuteStrings(Localizations.localeOf(context));
    final comparison = history.inCurrentSlot ? history.comparison : null;
    final weekly = comparison?.wholeWeek == true
        ? copy.weekly(comparison!.position, history.current.code) : '';
    return Container(padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('${history.slotStart}–${history.slotEnd} · ${copy.audience(audience)}',
          style: const TextStyle(color: AppTheme.harborBlue, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (history.inCurrentSlot) QueueBlock(
          queue: history.current, audience: audience, now: history.serverTime),
        Text(copy.coverage(history.validCount), style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (!history.inCurrentSlot) Text(copy.refreshHistory)
        else if (history.validCount == 0) Text(copy.accumulating)
        else if (comparison == null) Text(copy.noCurrentSlot)
        else Text(copy.comparison(comparison)),
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

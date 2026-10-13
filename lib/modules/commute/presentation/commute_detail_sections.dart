import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../data/commute_models.dart';
import 'commute_strings.dart';
import 'commute_widgets.dart';

/// Same-window comparison. A conclusion is only stated when every requested day is
/// comparable; otherwise the counts and the recorded day total are shown instead.
class CommuteHistoryCard extends StatelessWidget {
  const CommuteHistoryCard({
    super.key,
    required this.strings,
    required this.audience,
    required this.history,
    required this.error,
    required this.onRetry,
  });

  final CommuteStrings strings;

  /// Null while no audience is chosen; history is per audience, so none is requested.
  final CommuteAudience? audience;
  final CommuteHistory? history;
  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final value = history;
    return CommuteSectionCard(
      title: strings.historyTitle,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // A failed refresh keeps the last values on screen and says so, rather than
        // presenting stale levels as current.
        if (error != null) _errorRow(),
        if (value != null)
          _content(value)
        else if (error == null)
          audience == null
              ? Text(strings.historyNeedsAudience, style: const TextStyle(fontSize: 13))
              : const LinearProgressIndicator(minHeight: 3),
      ]),
    );
  }

  Widget _errorRow() => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Expanded(child: Text(strings.errorMessage(error!), style: const TextStyle(fontSize: 13))),
      TextButton(onPressed: onRetry, child: Text(strings.retry)),
    ]),
  );

  Widget _content(CommuteHistory history) {
    final current = history.current;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(strings.historyIntro, style: const TextStyle(
        fontSize: 12, height: 1.5, color: Color(0xFF65788C),
      )),
      const SizedBox(height: 8),
      Text(strings.historySlot(history.hkSlot), style: const TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.ink,
      )),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: Text(strings.historyCurrent, style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.ink,
        ))),
        const SizedBox(width: 8),
        CommuteStatusChip(
          label: strings.statusLabel(current.status),
          status: current.status,
          prominent: true,
        ),
      ]),
      const SizedBox(height: 4),
      Text(
        [strings.statusDetail(current.status, history.audience), strings.fetchedAt(current.observedAt)]
            .whereType<String>()
            .join(' · '),
        style: const TextStyle(fontSize: 12, color: Color(0xFF65788C)),
      ),
      const Divider(height: 24),
      if (history.days.isEmpty)
        Text(strings.historyAccumulating, style: const TextStyle(fontSize: 13))
      else ...[
        for (final day in history.days) _dayRow(day),
        const SizedBox(height: 10),
        Text(_summary(history), style: const TextStyle(
          fontSize: 13, height: 1.5, fontWeight: FontWeight.w600, color: AppTheme.ink,
        )),
        if (current.isComparable && history.validDays > 0) Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            strings.historyValidDays(history.validDays, history.days.length),
            style: const TextStyle(fontSize: 12, color: Color(0xFF65788C)),
          ),
        ),
      ],
    ]);
  }

  Widget _dayRow(CommuteHistoryDay day) {
    final comparable = day.isComparable;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 52, child: Text(strings.shortDate(day.hkDate), style: const TextStyle(
          fontSize: 13, color: Color(0xFF65788C),
        ))),
        Expanded(child: Text(
          strings.historyDayStatus(day.status, day.statusCode),
          style: TextStyle(
            fontSize: 13,
            fontWeight: comparable ? FontWeight.w600 : FontWeight.w400,
            color: comparable ? statusColor(day.status) : const Color(0xFF9AAAB8),
          ),
        )),
      ]),
    );
  }

  String _summary(CommuteHistory history) {
    if (!history.current.isComparable || history.validDays == 0) {
      return strings.historyNoComparison;
    }
    if (history.conclusive && history.lowerDays == 0 && history.higherDays == 0) {
      return strings.historyAllNormal;
    }
    final relative = strings.historyRelative(
      history.lowerDays, history.sameDays, history.higherDays,
    );
    // A whole-week superlative is only stated with a complete, comparable week.
    if (history.conclusive && history.higherDays == 0 && history.lowerDays > 0) {
      return '$relative ${strings.historyLowest}';
    }
    if (history.conclusive && history.lowerDays == 0 && history.higherDays > 0) {
      return '$relative ${strings.historyHighest}';
    }
    return relative;
  }
}

/// Hong Kong-side connections. Only verified sources are listed, and an unavailable
/// upstream degrades to a message instead of an empty list or a failed screen.
class CommuteTransitCard extends StatelessWidget {
  const CommuteTransitCard({
    super.key,
    required this.strings,
    required this.portCode,
    required this.transit,
    required this.error,
    required this.onRetry,
    required this.favouriteRoutes,
    required this.onToggleRoute,
  });

  final CommuteStrings strings;
  final String portCode;
  final PortTransit? transit;
  final Object? error;
  final VoidCallback onRetry;
  final Set<String> favouriteRoutes;
  final Future<void> Function(String routeKey) onToggleRoute;

  @override
  Widget build(BuildContext context) {
    final value = transit;
    return CommuteSectionCard(
      title: strings.transitTitle,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (error != null) _errorRow(),
         if (value != null)
           _content(value)
         else if (error == null)
           const LinearProgressIndicator(minHeight: 3),
      ]),
    );
  }

  Widget _errorRow() => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Expanded(child: Text(strings.errorMessage(error!), style: const TextStyle(fontSize: 13))),
      TextButton(onPressed: onRetry, child: Text(strings.retry)),
    ]),
  );

  Widget _content(PortTransit transit) {
    final source = transit.primarySource;
    if (source != null && source.state == 'unverified') {
      return Text(strings.transitUnverified, style: const TextStyle(fontSize: 13));
    }
    if (source != null && source.state == 'unavailable') {
      return Text(strings.transitUnavailable, style: const TextStyle(fontSize: 13));
    }
    if (transit.departures.isEmpty) {
      return Text(strings.transitEmpty, style: const TextStyle(fontSize: 13));
    }
    final ordered = _ordered(transit.departures);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final departure in ordered) _row(departure),
      if (source?.observedAt != null) Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          strings.transitObservedAt(source!.observedAt!),
          style: const TextStyle(fontSize: 12, color: Color(0xFF65788C)),
        ),
      ),
      const SizedBox(height: 8),
      Text(strings.transitEstimatedNote, style: const TextStyle(
        fontSize: 12, height: 1.5, color: Color(0xFF65788C),
      )),
    ]);
  }

  List<TransitDeparture> _ordered(List<TransitDeparture> departures) {
    final indexed = departures.indexed.toList();
    indexed.sort((a, b) {
      final rankA = favouriteRoutes.contains(_routeKey(a.$2)) ? 0 : 1;
      final rankB = favouriteRoutes.contains(_routeKey(b.$2)) ? 0 : 1;
      if (rankA != rankB) return rankA - rankB;
      return a.$1 - b.$1;
    });
    return [for (final entry in indexed) entry.$2];
  }

  String _routeKey(TransitDeparture departure) => '$portCode:${departure.destination}';

  Widget _row(TransitDeparture departure) {
    final favourite = favouriteRoutes.contains(_routeKey(departure));
    final timing = departure.minutes == null
        ? strings.transitTimeTypeLabel(departure.timeType)
        : strings.transitMinutes(departure.minutes!);
    final details = [
      if (departure.platform.isNotEmpty) '${strings.transitPlatform} ${departure.platform}',
      strings.transitTimeTypeLabel(departure.timeType),
      strings.reportedClock(departure.time),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: favourite ? strings.favouriteRemove : strings.favouriteRoute,
          onPressed: () => onToggleRoute(_routeKey(departure)),
          icon: Icon(
            favourite ? Icons.star : Icons.star_border,
            size: 20,
            color: favourite ? AppTheme.signalAmber : const Color(0xFF9AAAB8),
          ),
        ),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            '${strings.transitTo}${strings.destinationName(departure.destination)} · $timing',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.ink),
          ),
          const SizedBox(height: 3),
          Text(details.join(' · '), style: const TextStyle(
            fontSize: 12, color: Color(0xFF65788C),
          )),
        ])),
      ]),
    );
  }
}

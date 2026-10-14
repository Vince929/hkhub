import 'residency_models.dart';

/// The official minimum period of continuous ordinary residence for permanent
/// residency. The app treats it as a planning reference, never as an eligibility
/// decision.
const residencyTargetYears = 7;

/// Strips the time component so all comparisons are calendar-day based.
DateTime dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

/// Hong Kong "today" (UTC+8) derived from any instant. Device local time is not
/// used, so the result is stable regardless of the phone's time zone.
DateTime hongKongToday(DateTime instant) =>
    dateOnly(instant.toUtc().add(const Duration(hours: 8)));

/// Adds calendar months, clamping the day to the target month's length
/// (e.g. 2026-08-31 + 1 month -> 2026-09-30).
DateTime addMonths(DateTime date, int months) {
  final totalMonths = date.year * 12 + (date.month - 1) + months;
  final year = totalMonths ~/ 12;
  final month = totalMonths % 12 + 1;
  final lastDayOfMonth = DateTime(year, month + 1, 0).day;
  final day = date.day > lastDayOfMonth ? lastDayOfMonth : date.day;
  return DateTime(year, month, day);
}

/// Adds calendar years via [addMonths] so leap days are handled consistently.
DateTime addYears(DateTime date, int years) => addMonths(date, years * 12);

/// Calendar-aware elapsed time between two days.
class CalendarElapsed {
  const CalendarElapsed({required this.years, required this.months, required this.days});

  final int years;
  final int months;
  final int days;
}

/// Returns the largest whole years/months/days from [from] to [to] using
/// calendar arithmetic (not fixed 30/365-day spans).
CalendarElapsed calendarElapsed(DateTime from, DateTime to) {
  final start = dateOnly(from);
  final end = dateOnly(to);
  if (end.isBefore(start)) return const CalendarElapsed(years: 0, months: 0, days: 0);
  var years = end.year - start.year;
  if (addYears(start, years).isAfter(end)) years--;
  var anchor = addYears(start, years);
  var months = (end.year - anchor.year) * 12 + (end.month - anchor.month);
  if (addMonths(anchor, months).isAfter(end)) months--;
  anchor = addMonths(anchor, months);
  return CalendarElapsed(
    years: years,
    months: months,
    days: dateOnly(end).difference(anchor).inDays,
  );
}

/// Derived progress from the start date to the seven-year target date.
class ResidencyProgress {
  const ResidencyProgress({
    required this.startDate,
    required this.targetDate,
    required this.today,
    required this.elapsedDays,
    required this.remainingDays,
    required this.elapsedYears,
    required this.elapsedMonths,
    required this.fraction,
    required this.reached,
  });

  final DateTime startDate;
  final DateTime targetDate;
  final DateTime today;

  /// Whole days since the start date; 0 on the start date itself.
  final int elapsedDays;

  /// Whole days until [targetDate]; 0 once reached.
  final int remainingDays;

  final int elapsedYears;
  final int elapsedMonths;

  /// Elapsed calendar days over the full seven-year span, clamped to 0..1.
  final double fraction;

  final bool reached;
}

/// Computes progress using pure calendar time. Departure marks are intentionally
/// excluded: this is a planning aid, not an eligibility calculation.
ResidencyProgress computeResidencyProgress({
  required DateTime startDate,
  required DateTime today,
}) {
  final start = dateOnly(startDate);
  final current = dateOnly(today);
  final target = addYears(start, residencyTargetYears);
  final span = target.difference(start).inDays;
  final elapsed = current.isAfter(start) ? current.difference(start).inDays : 0;
  final remaining = current.isBefore(target) ? target.difference(current).inDays : 0;
  final calendar = calendarElapsed(start, current);
  final fraction = span <= 0 ? 1.0 : (elapsed / span).clamp(0.0, 1.0).toDouble();
  return ResidencyProgress(
    startDate: start,
    targetDate: target,
    today: current,
    elapsedDays: elapsed,
    remainingDays: remaining,
    elapsedYears: calendar.years,
    elapsedMonths: calendar.months,
    fraction: fraction,
    reached: !current.isBefore(target),
  );
}

/// A single time node in the seven-year journey.
class Milestone {
  const Milestone({required this.kind, required this.index, required this.date});

  final MilestoneKind kind;

  /// Month nodes: 1..83 (multiples of 12 are promoted to year nodes).
  /// Year nodes: 1..7.
  final int index;

  final DateTime date;

  /// Which year of the journey this node falls in (1-based).
  int get yearNumber => kind == MilestoneKind.year ? index : ((index - 1) ~/ 12) + 1;

  /// The month within [yearNumber] (1..12).
  int get monthInYear => ((index - 1) % 12) + 1;
}

/// Builds the full milestone list in ascending date order. Twelve-month
/// boundaries are represented once, as year nodes, so counts stay predictable
/// (77 month nodes + 7 year nodes = 84).
List<Milestone> buildMilestones(DateTime startDate) {
  final start = dateOnly(startDate);
  final nodes = <Milestone>[];
  for (var month = 1; month <= residencyTargetYears * 12; month++) {
    if (month % 12 == 0) continue;
    nodes.add(Milestone(kind: MilestoneKind.month, index: month, date: addMonths(start, month)));
  }
  for (var year = 1; year <= residencyTargetYears; year++) {
    nodes.add(Milestone(kind: MilestoneKind.year, index: year, date: addYears(start, year)));
  }
  nodes.sort((a, b) => a.date.compareTo(b.date));
  return nodes;
}

/// The portion of the journey shown at once: everything already achieved plus
/// the single next node, so the UI never renders all 84 nodes at once.
class MilestoneWindow {
  const MilestoneWindow({required this.achieved, required this.next, required this.total});

  final List<Milestone> achieved;
  final Milestone? next;
  final int total;

  int get achievedCount => achieved.length;
  bool get isComplete => next == null;

  /// The most recent [limit] achieved nodes, newest first.
  List<Milestone> recent(int limit) {
    if (achieved.isEmpty) return const [];
    if (achieved.length <= limit) return achieved.reversed.toList();
    return achieved.sublist(achieved.length - limit).reversed.toList();
  }
}

MilestoneWindow buildMilestoneWindow(List<Milestone> nodes, DateTime today) {
  final current = dateOnly(today);
  final achieved = <Milestone>[];
  Milestone? next;
  for (final node in nodes) {
    if (!node.date.isAfter(current)) {
      achieved.add(node);
    } else {
      next ??= node;
    }
  }
  return MilestoneWindow(achieved: achieved, next: next, total: nodes.length);
}

/// Renewal urgency tiers. 90/60/30-day escalation as agreed in the design.
enum RenewalLevel { none, upcoming, soon, urgent }

class RenewalStatus {
  const RenewalStatus({required this.daysRemaining, required this.level});

  final int daysRemaining;
  final RenewalLevel level;
}

/// Days until a visa expiry date. Negative values mean already expired.
RenewalStatus renewalStatus({required DateTime expiryDate, required DateTime today}) {
  final days = dateOnly(expiryDate).difference(dateOnly(today)).inDays;
  final level = days <= 30
      ? RenewalLevel.urgent
      : days <= 60
          ? RenewalLevel.soon
          : days <= 90
              ? RenewalLevel.upcoming
              : RenewalLevel.none;
  return RenewalStatus(daysRemaining: days, level: level);
}

/// Marks lasting at least this many days trigger a soft, informational note.
/// The number is a local heuristic: it is never shown in the UI and is not
/// presented as an official threshold.
const longDepartureAdvisoryDays = 182;

/// Whole days a departure mark lasts; an ongoing mark counts up to [today].
int departureDurationDays(DepartureMark mark, DateTime today) {
  final start = DateTime.tryParse(mark.startDate);
  if (start == null) return 0;
  final end = mark.endDate == null ? dateOnly(today) : DateTime.tryParse(mark.endDate!);
  if (end == null) return 0;
  final days = dateOnly(end).difference(dateOnly(start)).inDays;
  return days < 0 ? 0 : days;
}

/// Whether any mark should trigger the continuity advisory.
bool hasLongDeparture(
  List<DepartureMark> marks,
  DateTime today, {
  int thresholdDays = longDepartureAdvisoryDays,
}) => marks.any((mark) => departureDurationDays(mark, today) >= thresholdDays);

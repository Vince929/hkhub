/// Visa-type keys are stored as stable identifiers; localised labels live in
/// `ResidencyStrings`. Keys mirror the talent-scheme families the app targets.
const residencyVisaTypes = {'ttps', 'qmas', 'asmtp', 'iang', 'other', 'none'};

/// Progression kinds used to style milestone nodes.
enum MilestoneKind { month, year }

/// A period spent away from Hong Kong.
///
/// Advisory only: departure marks never change the computed progress.
class DepartureMark {
  const DepartureMark({required this.startDate, this.endDate});

  /// 'YYYY-MM-DD' in Hong Kong time.
  final String startDate;

  /// 'YYYY-MM-DD', or null while the user is still away.
  final String? endDate;

  static DepartureMark? fromJson(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final start = cleanIsoDate(value['start']);
    if (start == null) return null;
    final rawEnd = value['end'];
    final end = rawEnd == null ? null : cleanIsoDate(rawEnd);
    if (rawEnd != null && end == null) return null;
    if (end != null && end.compareTo(start) < 0) return null;
    return DepartureMark(startDate: start, endDate: end);
  }

  Map<String, dynamic> toJson() => {'start': startDate, 'end': endDate};
}

/// The locally stored residency profile. Dates are plain 'YYYY-MM-DD' strings.
class ResidencyProfile {
  const ResidencyProfile({
    this.startDate,
    this.visaType,
    this.visaExpiryDate,
    this.seenMilestoneCount = 0,
    this.departures = const [],
  });

  static const empty = ResidencyProfile();

  final String? startDate;
  final String? visaType;
  final String? visaExpiryDate;

  /// Achieved-milestone count already acknowledged, so the "you crossed" banner
  /// is shown once per newly reached node instead of on every open.
  final int seenMilestoneCount;

  final List<DepartureMark> departures;

  bool get isConfigured => startDate != null;

  ResidencyProfile copyWith({
    String? startDate,
    String? visaType,
    String? visaExpiryDate,
    int? seenMilestoneCount,
    List<DepartureMark>? departures,
  }) => ResidencyProfile(
    startDate: startDate ?? this.startDate,
    visaType: visaType ?? this.visaType,
    visaExpiryDate: visaExpiryDate ?? this.visaExpiryDate,
    seenMilestoneCount: seenMilestoneCount ?? this.seenMilestoneCount,
    departures: departures ?? this.departures,
  );

  /// Sanitises stored data: unknown fields, malformed dates and invalid visa
  /// keys are dropped instead of raising, so a partial record stays usable.
  static ResidencyProfile fromJson(Object? value) {
    if (value is! Map<String, dynamic>) return empty;
    final visa = value['visa_type'];
    final rawDepartures = value['departures'];
    final departures = <DepartureMark>[];
    if (rawDepartures is List) {
      for (final item in rawDepartures) {
        if (departures.length >= 60) break;
        final mark = DepartureMark.fromJson(item);
        if (mark != null) departures.add(mark);
      }
    }
    final seen = value['seen_milestones'];
    return ResidencyProfile(
      startDate: cleanIsoDate(value['start_date']),
      visaType: visa is String && residencyVisaTypes.contains(visa) ? visa : null,
      visaExpiryDate: cleanIsoDate(value['visa_expiry']),
      seenMilestoneCount: seen is int && seen >= 0 && seen <= 200 ? seen : 0,
      departures: List<DepartureMark>.unmodifiable(departures),
    );
  }

  Map<String, dynamic> toJson() => {
    'start_date': startDate,
    'visa_type': visaType,
    'visa_expiry': visaExpiryDate,
    'seen_milestones': seenMilestoneCount,
    'departures': departures.map((mark) => mark.toJson()).toList(),
  };
}

final _isoDatePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

/// Formats a date as 'YYYY-MM-DD'.
String formatIsoDate(DateTime date) => '${date.year.toString().padLeft(4, '0')}'
    '-${date.month.toString().padLeft(2, '0')}'
    '-${date.day.toString().padLeft(2, '0')}';

/// Accepts only well-formed 'YYYY-MM-DD' strings that round-trip exactly.
String? cleanIsoDate(Object? value) {
  if (value is! String || !_isoDatePattern.hasMatch(value)) return null;
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return null;
  return formatIsoDate(parsed) == value ? value : null;
}

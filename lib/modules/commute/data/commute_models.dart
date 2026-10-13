/// Cross-border commute contract shared with `hkhub_server` (`/api/commute/*`).
///
/// Status codes come from the Immigration Department data dictionary. The same code
/// maps to a different "usually under N minutes" range for residents and visitors, so
/// audience is always carried alongside a status.
library;

enum CommuteAudience { resident, visitor }

extension CommuteAudienceApi on CommuteAudience {
  String get apiValue => this == CommuteAudience.resident ? 'resident' : 'visitor';

  static CommuteAudience? fromApi(Object? value) => switch (value) {
    'resident' => CommuteAudience.resident,
    'visitor' => CommuteAudience.visitor,
    _ => null,
  };
}

enum QueueStatus { normal, busy, veryBusy, maintenance, nonService, unknown }

enum QueueFreshness { fresh, stale, missing }

/// Only 0/1/2 express an ordered queue level; the rest are never compared.
bool comparableStatus(int? statusCode) =>
    statusCode == 0 || statusCode == 1 || statusCode == 2;

Map<String, dynamic> _object(Object? value, String label) {
  if (value is! Map<String, dynamic>) throw FormatException('Invalid $label');
  return value;
}

String _text(Map<String, dynamic> value, String key) {
  final field = value[key];
  if (field is! String) throw FormatException('Invalid $key');
  return field;
}

int? _optionalInt(Object? value) => value is int ? value : null;

DateTime? _optionalTime(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toUtc();
}

QueueStatus _queueStatus(Object? value) => switch (value) {
  'normal' => QueueStatus.normal,
  'busy' => QueueStatus.busy,
  'very_busy' => QueueStatus.veryBusy,
  'maintenance' => QueueStatus.maintenance,
  'non_service' => QueueStatus.nonService,
  _ => QueueStatus.unknown,
};

QueueFreshness _freshness(Object? value) => switch (value) {
  'fresh' => QueueFreshness.fresh,
  'stale' => QueueFreshness.stale,
  _ => QueueFreshness.missing,
};

class QueueState {
  const QueueState({
    required this.status,
    required this.statusCode,
    required this.observedAt,
    required this.freshness,
  });

  factory QueueState.fromJson(Object? value) {
    final map = _object(value, 'queue state');
    return QueueState(
      status: _queueStatus(map['status']),
      statusCode: _optionalInt(map['status_code']),
      observedAt: _optionalTime(map['observed_at']),
      freshness: _freshness(map['state']),
    );
  }

  final QueueStatus status;
  final int? statusCode;

  /// When this service last fetched the value, never the official assessment time.
  final DateTime? observedAt;
  final QueueFreshness freshness;

  bool get isComparable => comparableStatus(statusCode);
}

class PortQueueStatus {
  const PortQueueStatus({
    required this.portCode,
    required this.resident,
    required this.visitor,
  });

  factory PortQueueStatus.fromJson(Object? value) {
    final map = _object(value, 'port status');
    return PortQueueStatus(
      portCode: _text(map, 'port_code'),
      resident: QueueState.fromJson(map['resident']),
      visitor: QueueState.fromJson(map['visitor']),
    );
  }

  final String portCode;
  final QueueState resident;
  final QueueState visitor;

  QueueState forAudience(CommuteAudience audience) =>
      audience == CommuteAudience.resident ? resident : visitor;
}

class CommuteBorders {
  const CommuteBorders({required this.generatedAt, required this.ports});

  factory CommuteBorders.fromJson(Object? value) {
    final map = _object(value, 'commute borders');
    final ports = map['ports'];
    if (ports is! List || ports.length > 20) {
      throw const FormatException('Invalid commute ports');
    }
    return CommuteBorders(
      generatedAt: _optionalTime(map['generated_at']),
      ports: List<PortQueueStatus>.unmodifiable(ports.map(PortQueueStatus.fromJson)),
    );
  }

  final DateTime? generatedAt;
  final List<PortQueueStatus> ports;
}

class CommuteHistoryDay {
  const CommuteHistoryDay({
    required this.hkDate,
    required this.status,
    required this.statusCode,
    required this.observedAt,
  });

  factory CommuteHistoryDay.fromJson(Object? value) {
    final map = _object(value, 'history day');
    return CommuteHistoryDay(
      hkDate: _text(map, 'hk_date'),
      status: _queueStatus(map['status']),
      statusCode: _optionalInt(map['status_code']),
      observedAt: _optionalTime(map['observed_at']),
    );
  }

  final String hkDate;
  final QueueStatus status;
  final int? statusCode;
  final DateTime? observedAt;

  bool get isComparable => comparableStatus(statusCode);
}

class CommuteHistory {
  const CommuteHistory({
    required this.portCode,
    required this.audience,
    required this.hkSlot,
    required this.current,
    required this.days,
    required this.validDays,
    required this.lowerDays,
    required this.sameDays,
    required this.higherDays,
    required this.conclusive,
  });

  factory CommuteHistory.fromJson(Object? value) {
    final map = _object(value, 'commute history');
    final days = map['days'];
    if (days is! List || days.length > 14) {
      throw const FormatException('Invalid history days');
    }
    // Audience selects which official time range applies, so it is never guessed.
    final audience = CommuteAudienceApi.fromApi(map['audience']);
    if (audience == null) throw const FormatException('Invalid history audience');
    return CommuteHistory(
      portCode: _text(map, 'port_code'),
      audience: audience,
      hkSlot: _optionalInt(map['hk_slot']) ?? 0,
      current: QueueState.fromJson(map['current']),
      days: List<CommuteHistoryDay>.unmodifiable(days.map(CommuteHistoryDay.fromJson)),
      validDays: _optionalInt(map['valid_days']) ?? 0,
      lowerDays: _optionalInt(map['lower_days']) ?? 0,
      sameDays: _optionalInt(map['same_days']) ?? 0,
      higherDays: _optionalInt(map['higher_days']) ?? 0,
      conclusive: map['conclusive'] == true,
    );
  }

  final String portCode;
  final CommuteAudience audience;
  final int hkSlot;
  final QueueState current;
  final List<CommuteHistoryDay> days;
  final int validDays;
  final int lowerDays;
  final int sameDays;
  final int higherDays;

  /// True only when every requested day is comparable and the current level is too.
  final bool conclusive;
}

class TransitDeparture {
  const TransitDeparture({
    required this.line,
    required this.direction,
    required this.destination,
    required this.platform,
    required this.time,
    required this.minutes,
    required this.timeType,
  });

  factory TransitDeparture.fromJson(Object? value) {
    final map = _object(value, 'transit departure');
    return TransitDeparture(
      line: _text(map, 'line'),
      direction: _text(map, 'direction'),
      destination: _text(map, 'destination'),
      platform: _text(map, 'platform'),
      time: _text(map, 'time'),
      minutes: _optionalInt(map['minutes']),
      timeType: _text(map, 'time_type'),
    );
  }

  final String line;
  final String direction;
  final String destination;
  final String platform;
  final String time;
  final int? minutes;

  /// Reported time type. Only some official values have a verified meaning, so the
  /// app labels anything unrecognised as a published time.
  final String timeType;
}

class TransitSource {
  const TransitSource({
    required this.kind,
    required this.state,
    required this.observedAt,
    required this.reason,
  });

  factory TransitSource.fromJson(Object? value) {
    final map = _object(value, 'transit source');
    return TransitSource(
      kind: _text(map, 'kind'),
      state: _text(map, 'state'),
      observedAt: _optionalTime(map['observed_at']),
      reason: map['reason'] is String ? map['reason'] as String : null,
    );
  }

  final String kind;

  /// One of ok, unavailable or unverified.
  final String state;
  final DateTime? observedAt;
  final String? reason;
}

class PortTransit {
  const PortTransit({
    required this.portCode,
    required this.generatedAt,
    required this.sources,
    required this.departures,
  });

  factory PortTransit.fromJson(Object? value) {
    final map = _object(value, 'port transit');
    final sources = map['sources'];
    final departures = map['departures'];
    if (sources is! List || departures is! List || departures.length > 12) {
      throw const FormatException('Invalid transit payload');
    }
    return PortTransit(
      portCode: _text(map, 'port_code'),
      generatedAt: _optionalTime(map['generated_at']),
      sources: List<TransitSource>.unmodifiable(sources.map(TransitSource.fromJson)),
      departures: List<TransitDeparture>.unmodifiable(
        departures.map(TransitDeparture.fromJson),
      ),
    );
  }

  final String portCode;
  final DateTime? generatedAt;
  final List<TransitSource> sources;
  final List<TransitDeparture> departures;

  TransitSource? get primarySource => sources.isEmpty ? null : sources.first;
}

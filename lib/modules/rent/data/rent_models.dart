import 'rent_json.dart';

class RentDefinition {
  RentDefinition(Object? raw) {
    final value = rentObject(raw);
    id = rentText(value, 'series_id');
    metric = rentText(value, 'metric');
    classCode = rentText(value, 'class_code');
    region = rentText(value, 'region_code');
    unit = rentText(value, 'unit');
    base = rentOptionalText(value['base_period']);
    comparisonGroup = rentText(value, 'comparison_group');
    if (!{'rental_index', 'average_rent'}.contains(metric) ||
        !{'A', 'B', 'C', 'D', 'E', 'ABC', 'DE', 'all'}.contains(classCode) ||
        !{'hk', 'kowloon', 'nt', 'territory'}.contains(region) ||
        !{'index', 'hkd_per_m2'}.contains(unit) || value['frequency'] != 'monthly') {
      throw const FormatException('Unsupported rental definition');
    }
  }
  late final String id, metric, classCode, region, unit, comparisonGroup;
  late final String? base;

  bool comparable(RentDefinition other) => metric == other.metric &&
      comparisonGroup == other.comparisonGroup && unit == other.unit && base == other.base;
}

class RentDataset {
  RentDataset(Object? raw) {
    final value = rentObject(raw);
    sourceId = rentText(value, 'source_id');
    snapshotId = rentOptionalText(value['snapshot_id']);
    status = rentText(value, 'last_attempt_status');
    coverageStart = rentOptionalText(value['coverage_start_month']);
    coverageEnd = rentOptionalText(value['coverage_end_month']);
    checkedAt = rentTime(value['last_checked_at']);
    changedAt = rentTime(value['last_changed_at']);
    attemptedAt = rentTime(value['last_attempt_at']);
    sourceUpdatedAt = rentTime(value['source_updated_at']);
    notes = rentItems(value, 'notes', (raw) {
      if (raw is! String) throw const FormatException('Invalid rental note');
      return raw;
    });
  }
  late final String sourceId, status;
  late final String? snapshotId, coverageStart, coverageEnd;
  late final DateTime? checkedAt, changedAt, attemptedAt, sourceUpdatedAt;
  late final List<String> notes;
}

class RentMetric {
  RentMetric(Object? raw) {
    final value = rentObject(raw);
    metric = rentText(value, 'metric');
    available = rentBool(value, 'available');
    defaultId = rentOptionalText(value['default_series_id']);
    dataset = RentDataset(value['dataset']);
    series = rentItems(value, 'series', RentDefinition.new);
    if (available && (series.isEmpty || !series.any((item) => item.id == defaultId))) {
      throw const FormatException('Missing rental default series');
    }
  }
  late final String metric;
  late final bool available;
  late final String? defaultId;
  late final RentDataset dataset;
  late final List<RentDefinition> series;
}

class RentCatalog {
  RentCatalog(Object? raw) {
    final value = rentObject(raw);
    rentVersion(value);
    metrics = rentItems(value, 'metrics', RentMetric.new);
  }
  late final List<RentMetric> metrics;
  List<RentMetric> get available => metrics.where((item) => item.available).toList();
}

class RentChange {
  RentChange(Object? raw) {
    final value = rentObject(raw);
    percent = rentNumber(value['percent']);
    reason = rentOptionalText(value['reason']);
  }
  late final double? percent;
  late final String? reason;
}

class RentPoint {
  RentPoint(Object? raw) {
    final data = rentObject(raw);
    month = rentMonth(data, 'month');
    value = rentNumber(data['value']);
    relative = rentNumber(data['relative_value']);
    flag = rentText(data, 'source_flag');
    missingReason = rentOptionalText(data['missing_reason']);
    smallSample = rentBool(data, 'small_sample');
    comparabilityBreak = rentBool(data, 'comparability_break');
  }
  late final String month, flag;
  late final String? missingReason;
  late final double? value, relative;
  late final bool smallSample, comparabilityBreak;
}

class RentSeries {
  RentSeries(Object? raw) {
    final value = rentObject(raw);
    definition = RentDefinition(value['definition']);
    points = rentItems(value, 'points', RentPoint.new);
    final latest = rentObject(value['latest']);
    latestMonth = rentMonth(latest, 'month');
    latestValue = rentNumber(latest['value']);
    latestFlag = rentText(latest, 'source_flag');
    mom = RentChange(latest['mom']);
    yoy = RentChange(latest['yoy']);
    period = RentChange(value['period_change']);
    complete = rentBool(value, 'complete');
    if (points.isEmpty) throw const FormatException('Empty rental series');
  }
  late final RentDefinition definition;
  late final List<RentPoint> points;
  late final String latestMonth, latestFlag;
  late final double? latestValue;
  late final RentChange mom, yoy, period;
  late final bool complete;
}

class RentTrends {
  RentTrends(Object? raw) {
    final value = rentObject(raw);
    rentVersion(value);
    dataset = RentDataset(value['dataset']);
    final range = rentObject(value['range']);
    startMonth = rentMonth(range, 'start_month');
    endMonth = rentMonth(range, 'end_month');
    actualStartMonth = rentMonth(range, 'actual_start_month');
    complete = rentBool(range, 'complete');
    relative = rentText(value, 'view') == 'relative';
    series = rentItems(value, 'series', RentSeries.new);
    if (series.isEmpty || series.length > 3) throw const FormatException('Invalid rental comparison');
    final expected = monthNumber(endMonth) - monthNumber(startMonth) + 1;
    if (!{13, 37, 61}.contains(expected)) throw const FormatException('Invalid rental interval');
    for (final item in series) {
      if (item.points.length != expected || !series.first.definition.comparable(item.definition)) {
        throw const FormatException('Incompatible rental points');
      }
      for (var i = 0; i < expected; i++) {
        if (monthNumber(item.points[i].month) != monthNumber(startMonth) + i) {
          throw const FormatException('Invalid monthly rental axis');
        }
      }
    }
  }
  late final RentDataset dataset;
  late final String startMonth, endMonth, actualStartMonth;
  late final bool complete, relative;
  late final List<RentSeries> series;
  String get identity => '${dataset.snapshotId}:$startMonth:$relative:${series.map((item) => item.definition.id).join(',')}';
}

int monthNumber(String month) {
  final values = month.split('-').map(int.parse).toList();
  return values[0] * 12 + values[1] - 1;
}

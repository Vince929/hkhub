Map<String, dynamic> companyObject(Object? raw) {
  if (raw is! Map<String, dynamic>) throw const FormatException('Invalid company object');
  return raw;
}

String companyText(Map<String, dynamic> raw, String field) {
  final value = raw[field];
  if (value is! String) throw FormatException('Invalid company field: $field');
  return value;
}

int? companyCount(Map<String, dynamic> raw, String field, {bool optional = false}) {
  final value = raw[field];
  if (optional && value == null) return null;
  if (value is! int || value < 0) throw FormatException('Invalid company count: $field');
  return value;
}

List<T> companyItems<T>(Map<String, dynamic> raw, String field, T Function(Object?) decode) {
  final value = raw[field];
  if (value is! List || value.length > 600) throw FormatException('Invalid company list: $field');
  return List.unmodifiable(value.map(decode));
}

String companyDate(Map<String, dynamic> raw, String field) {
  final value = companyText(raw, field);
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value) || DateTime.tryParse(value) == null) {
    throw FormatException('Invalid company date: $field');
  }
  return value;
}

class CompanyPeriod {
  CompanyPeriod(Object? raw) {
    final value = companyObject(raw);
    reportId = companyText(value, 'report_id');
    start = companyDate(value, 'start_date');
    end = companyDate(value, 'end_date_exclusive');
    type = companyText(value, 'period_type');
    dataStatus = companyText(value, 'data_status');
    analysisStatus = companyText(value, 'analysis_status');
    populationScope = value.containsKey('population_scope')
        ? companyText(value, 'population_scope') : 'incorporation';
    if (!{'incorporation', 'incorporation_and_redomiciliation'}.contains(populationScope)) {
      throw const FormatException('Invalid company population scope');
    }
    if (!{'week', 'month', 'year'}.contains(type) ||
        !{'complete', 'partial', 'unavailable'}.contains(dataStatus) ||
        !{'pending', 'running', 'published', 'failed', 'not_configured', 'not_needed', 'superseded'}.contains(analysisStatus)) {
      throw const FormatException('Invalid company period status');
    }
  }
  late final String reportId, start, end, type, dataStatus, analysisStatus, populationScope;
  bool get includesRedomiciliation => populationScope == 'incorporation_and_redomiciliation';
}

class CompanyPeriods {
  CompanyPeriods(Object? raw) {
    final value = companyObject(raw);
    periods = companyItems(value, 'items', CompanyPeriod.new);
    defaultStart = value['default_start_date'] as String?;
    latestEndedStart = companyDate(value, 'latest_ended_start_date');
    lastSuccessAt = value['last_success_at'] as String?;
    sourceError = value['source_error_code'] as String?;
    if ((periods.isNotEmpty && defaultStart == null) ||
        (defaultStart != null && !periods.any((item) => item.start == defaultStart))) {
      throw const FormatException('Default company period is missing');
    }
  }
  late final List<CompanyPeriod> periods;
  late final String latestEndedStart;
  late final String? defaultStart, lastSuccessAt, sourceError;
}

class CompanySource {
  CompanySource(Object? raw) {
    final value = companyObject(raw);
    url = companyText(value, 'source_url');
    start = companyDate(value, 'coverage_start');
    end = companyDate(value, 'coverage_end_exclusive');
    fetchedAt = companyText(value, 'fetched_at');
    publishedDate = value['published_date'] as String?;
  }
  late final String url, start, end, fetchedAt;
  late final String? publishedDate;
}

class CompanyOverview {
  CompanyOverview(Object? raw) {
    final value = companyObject(raw);
    period = CompanyPeriod(raw);
    observedCount = companyCount(value, 'observed_company_count')!;
    totalCount = companyCount(value, 'total_company_count', optional: true);
    sources = companyItems(value, 'sources', CompanySource.new);
    missing = companyItems(value, 'missing_resources', (item) => companyText(companyObject(item), 'reason_code'));
    if ((period.dataStatus != 'complete' && totalCount != null) ||
        (period.dataStatus == 'complete' && totalCount != observedCount)) {
      throw const FormatException('Inconsistent company snapshot');
    }
  }
  late final CompanyPeriod period;
  late final int observedCount;
  late final int? totalCount;
  late final List<CompanySource> sources;
  late final List<String> missing;
}

class ObservedCompany {
  ObservedCompany(Object? raw) {
    final value = companyObject(raw);
    key = companyText(value, 'company_key');
    nameEn = companyText(value, 'name_en');
    nameZh = companyText(value, 'name_zh');
    identifier = companyText(value, 'identifier_value');
    identifierType = companyText(value, 'identifier_type');
    date = companyDate(value, value.containsKey('registration_date')
        ? 'registration_date' : 'incorporation_date');
    eventType = value.containsKey('event_type') ? companyText(value, 'event_type') : 'incorporation';
    if (!{'incorporation', 'incorporation_or_redomiciliation'}.contains(eventType)) {
      throw const FormatException('Invalid company registration event');
    }
    source = CompanySource(value['source']);
  }
  late final String key, nameEn, nameZh, identifier, identifierType, date, eventType;
  late final CompanySource source;
}

class CompanyPage {
  CompanyPage(Object? raw) {
    final value = companyObject(raw);
    reportId = companyText(value, 'report_id');
    companies = companyItems(value, 'items', ObservedCompany.new);
    populationScope = value.containsKey('population_scope')
        ? companyText(value, 'population_scope') : 'incorporation';
    if (!{'incorporation', 'incorporation_and_redomiciliation'}.contains(populationScope)) {
      throw const FormatException('Invalid company list population scope');
    }
    nextCursor = value['next_cursor'] as String?;
  }
  late final String reportId, populationScope;
  bool get includesRedomiciliation => populationScope == 'incorporation_and_redomiciliation';
  late final String? nextCursor;
  late final List<ObservedCompany> companies;
}

class LiquidationMonth {
  LiquidationMonth(Object? raw) {
    final value = companyObject(raw);
    start = companyDate(value, 'month_start');
    members = companyCount(value, 'members_commenced')!;
    creditors = companyCount(value, 'creditors_commenced')!;
    membersInProgress = companyCount(value, 'members_in_progress')!;
    creditorsInProgress = companyCount(value, 'creditors_in_progress')!;
    url = companyText(value, 'source_url');
    fetchedAt = companyText(value, 'fetched_at');
  }
  late final String start, url, fetchedAt;
  late final int members, creditors, membersInProgress, creditorsInProgress;
}

class CompanyLiquidations {
  CompanyLiquidations(Object? raw) {
    final value = companyObject(raw);
    status = companyText(value, 'data_status');
    months = companyItems(value, 'items', LiquidationMonth.new);
    errorCode = value['error_code'] as String?;
  }
  late final String status;
  late final String? errorCode;
  late final List<LiquidationMonth> months;
}

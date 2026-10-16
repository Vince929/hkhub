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
    if (!{'week', 'month', 'year'}.contains(type) ||
        !{'complete', 'partial', 'unavailable'}.contains(dataStatus) ||
        !{'pending', 'running', 'published', 'failed', 'not_configured', 'not_needed', 'superseded'}.contains(analysisStatus)) {
      throw const FormatException('Invalid company period status');
    }
  }
  late final String reportId, start, end, type, dataStatus, analysisStatus;
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

class CompanyTopic {
  CompanyTopic(Object? raw) {
    final value = companyObject(raw);
    id = companyText(value, 'topic_id');
    reportId = companyText(value, 'report_id');
    title = companyText(value, 'title');
    explanation = companyText(value, 'explanation');
    count = companyCount(value, 'company_count')!;
    language = companyText(value, 'content_language');
    fallback = value['language_fallback'] == true;
    terms = companyItems(value, 'terms', (item) {
      if (item is! String) throw const FormatException('Invalid company term');
      return item;
    });
  }
  late final String id, reportId, title, explanation, language;
  late final int count;
  late final bool fallback;
  late final List<String> terms;
}

class CompanyOverview {
  CompanyOverview(Object? raw) {
    final value = companyObject(raw);
    period = CompanyPeriod(raw);
    observedCount = companyCount(value, 'observed_company_count')!;
    totalCount = companyCount(value, 'total_company_count', optional: true);
    unknownCount = companyCount(value, 'unknown_company_count', optional: true);
    summary = value['summary'] as String?;
    language = value['content_language'] as String?;
    fallback = value['language_fallback'] == true;
    errorCode = value['error_code'] as String?;
    analysisAttemptCount = companyCount(value, 'analysis_attempt_count', optional: true);
    analysisMaxAttempts = companyCount(value, 'analysis_max_attempts', optional: true);
    analysisRetryAfter = value['analysis_retry_after'] as String?;
    analysisRetryAllowed = value['analysis_retry_allowed'] as bool?;
    findings = companyItems(value, 'findings', (item) {
      if (item is! String) throw const FormatException('Invalid company finding');
      return item;
    });
    topics = companyItems(value, 'topics', CompanyTopic.new);
    sources = companyItems(value, 'sources', CompanySource.new);
    missing = companyItems(value, 'missing_resources', (item) => companyText(companyObject(item), 'reason_code'));
    if (topics.any((topic) => topic.reportId != period.reportId) ||
        (period.dataStatus != 'complete' && totalCount != null) ||
        (period.dataStatus == 'complete' && totalCount != observedCount)) {
      throw const FormatException('Inconsistent company snapshot');
    }
  }
  late final CompanyPeriod period;
  late final int observedCount;
  late final int? totalCount, unknownCount;
  late final String? summary, language, errorCode, analysisRetryAfter;
  late final int? analysisAttemptCount, analysisMaxAttempts;
  late final bool? analysisRetryAllowed;
  late final bool fallback;
  late final List<String> findings, missing;
  late final List<CompanyTopic> topics;
  late final List<CompanySource> sources;
}

class ObservedCompany {
  ObservedCompany(Object? raw) {
    final value = companyObject(raw);
    key = companyText(value, 'company_key');
    nameEn = companyText(value, 'name_en');
    nameZh = companyText(value, 'name_zh');
    identifier = companyText(value, 'identifier_value');
    identifierType = companyText(value, 'identifier_type');
    date = companyDate(value, 'incorporation_date');
    source = CompanySource(value['source']);
    evidence = companyItems(value, 'evidence', (item) => companyText(companyObject(item), 'text'));
  }
  late final String key, nameEn, nameZh, identifier, identifierType, date;
  late final CompanySource source;
  late final List<String> evidence;
}

class CompanyPage {
  CompanyPage(Object? raw) {
    final value = companyObject(raw);
    reportId = companyText(value, 'report_id');
    companies = companyItems(value, 'items', ObservedCompany.new);
    nextCursor = value['next_cursor'] as String?;
  }
  late final String reportId;
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

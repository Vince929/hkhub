import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/api_client.dart';
import 'company_models.dart';

final companyPeriodsProvider = FutureProvider.autoDispose.family<CompanyPeriods, String>((ref, type) {
  final client = ref.watch(apiClientProvider);
  final token = CancelToken();
  ref.onDispose(() => token.cancel());
  return client.request('company-observation/periods', queryParameters: {'period_type': type},
    decode: CompanyPeriods.new, cancelToken: token);
});

final companyOverviewProvider = FutureProvider.autoDispose.family<CompanyOverview, (String, String)>((ref, key) {
  final client = ref.watch(apiClientProvider);
  final token = CancelToken();
  ref.onDispose(() => token.cancel());
  return client.request('company-observation/overview',
    queryParameters: {'period_type': key.$1, 'start_date': key.$2},
    decode: CompanyOverview.new, cancelToken: token);
});

final companyTopicProvider = FutureProvider.autoDispose.family<CompanyTopic, (String, String)>((ref, key) {
  final client = ref.watch(apiClientProvider);
  final token = CancelToken();
  ref.onDispose(() => token.cancel());
  return client.request('company-observation/reports/${key.$1}/topics/${key.$2}',
    decode: CompanyTopic.new, cancelToken: token);
});

typedef CompanyPageKey = (String, String?, String, String?);
final companyPageProvider = FutureProvider.autoDispose.family<CompanyPage, CompanyPageKey>((ref, key) {
  final client = ref.watch(apiClientProvider);
  final token = CancelToken();
  ref.onDispose(() => token.cancel());
  return client.request('company-observation/reports/${key.$1}/companies',
    queryParameters: {if (key.$2 != null) 'topic_id': key.$2,
      'q': key.$3, if (key.$4 != null) 'cursor': key.$4, 'limit': 30},
    decode: (raw) {
      final page = CompanyPage(raw);
      if (page.reportId != key.$1) throw const FormatException('Company report mismatch');
      return page;
    }, cancelToken: token);
});

final companyLiquidationsProvider = FutureProvider.autoDispose<CompanyLiquidations>((ref) {
  final client = ref.watch(apiClientProvider);
  final token = CancelToken();
  ref.onDispose(() => token.cancel());
  return client.request('company-observation/liquidations',
    decode: CompanyLiquidations.new, cancelToken: token);
});

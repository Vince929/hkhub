import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/api_client.dart';
import 'rent_models.dart';

final rentCatalogProvider = FutureProvider.autoDispose<RentCatalog>((ref) {
  final client = ref.watch(apiClientProvider);
  final token = CancelToken();
  ref.onDispose(() => token.cancel());
  return client.request('rent/catalog', decode: RentCatalog.new, cancelToken: token);
});

// Selection order is part of the key: the first series is the primary summary.
typedef RentQuery = (String, int, bool);
final rentTrendsProvider = FutureProvider.autoDispose.family<RentTrends, RentQuery>((ref, key) {
  final client = ref.watch(apiClientProvider);
  final token = CancelToken();
  ref.onDispose(() => token.cancel());
  // Uri encodes list values as repeated keys (not series_id[]).
  final query = Uri(queryParameters: {
    'series_id': key.$1.split(','), 'years': '${key.$2}',
    'view': key.$3 ? 'relative' : 'original',
  }).query;
  return client.request('rent/trends?$query', decode: RentTrends.new, cancelToken: token);
});

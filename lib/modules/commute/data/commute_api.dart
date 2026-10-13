import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/api_client.dart';
import 'commute_models.dart';

/// Supported control points, ordered as shown in the app.
///
/// The server rejects unknown codes, and native routing validates against this list
/// so a malformed in-app link can never target an arbitrary path segment.
const commutePortCodes = <String>['LWS', 'LSC', 'SBC'];

bool isCommutePort(String portCode) => commutePortCodes.contains(portCode);

final commuteBordersProvider =
    AsyncNotifierProvider.autoDispose<CommuteBordersController, CommuteBorders>(
      CommuteBordersController.new,
    );

class CommuteBordersController extends AutoDisposeAsyncNotifier<CommuteBorders> {
  late ApiClient _client;
  late CancelToken _cancelToken;
  int _generation = 0;
  Future<void>? _refreshing;

  @override
  Future<CommuteBorders> build() {
    _client = ref.watch(apiClientProvider);
    _cancelToken = CancelToken();
    final token = _cancelToken;
    ref.onDispose(() => token.cancel());
    _generation++;
    _refreshing = null;
    return _client.request(
      'commute/borders',
      decode: CommuteBorders.fromJson,
      cancelToken: token,
    );
  }

  Future<void> refresh() {
    if (_refreshing != null) return _refreshing!;
    if (state.isLoading) return Future<void>.value();
    final request = _reload();
    _refreshing = request;
    return request;
  }

  Future<void> _reload() async {
    final generation = _generation;
    final token = _cancelToken;
    // Keep the list steady only while updating; an error replaces it, not cached data.
    if (!state.hasValue || state.hasError) state = const AsyncLoading();
    try {
      final result = await _client.request(
        'commute/borders',
        decode: CommuteBorders.fromJson,
        cancelToken: token,
      );
      if (!token.isCancelled && generation == _generation) state = AsyncData(result);
    } catch (error, stack) {
      if (!token.isCancelled && generation == _generation) state = AsyncError(error, stack);
    } finally {
      if (generation == _generation) _refreshing = null;
    }
  }
}

/// Per-visit detail reads. History and connections fail independently of each other
/// and of the port list, so one unavailable source never blanks the whole screen.
class CommuteDetailClient {
  const CommuteDetailClient(this._client);

  final ApiClient _client;

  Future<PortQueueStatus> port(String portCode, CancelToken cancelToken) => _client.request(
    'commute/borders/$portCode',
    decode: PortQueueStatus.fromJson,
    cancelToken: cancelToken,
  );

  Future<CommuteHistory> history(
    String portCode,
    CommuteAudience audience,
    CancelToken cancelToken,
  ) => _client.request(
    'commute/borders/$portCode/history',
    queryParameters: {'audience': audience.apiValue},
    decode: CommuteHistory.fromJson,
    cancelToken: cancelToken,
  );

  Future<PortTransit> transit(String portCode, CancelToken cancelToken) => _client.request(
    'commute/borders/$portCode/transit',
    decode: PortTransit.fromJson,
    cancelToken: cancelToken,
  );
}

final commuteDetailClientProvider = Provider<CommuteDetailClient>(
  (ref) => CommuteDetailClient(ref.watch(apiClientProvider)),
);

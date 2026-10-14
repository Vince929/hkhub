import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/api_client.dart';
import '../../../app/providers.dart';
import 'commute_models.dart';

final bordersProvider = FutureProvider.autoDispose<BordersData>((ref) {
  final client = ref.watch(apiClientProvider);
  final token = CancelToken();
  ref.onDispose(() => token.cancel());
  return client.request('commute/borders', decode: BordersData.new, cancelToken: token);
});

final historyProvider = FutureProvider.autoDispose.family<HistoryData, (String, String, String)>((ref, key) {
  final client = ref.watch(apiClientProvider);
  final token = CancelToken();
  ref.onDispose(() => token.cancel());
  return client.request('commute/borders/${key.$1}/history',
    queryParameters: {'audience': key.$2, 'direction': key.$3},
    decode: HistoryData.new, cancelToken: token);
});

final transitProvider = FutureProvider.autoDispose.family<TransitData, String>((ref, code) {
  final client = ref.watch(apiClientProvider);
  final token = CancelToken();
  ref.onDispose(() => token.cancel());
  return client.request('commute/borders/$code/transit', decode: TransitData.new, cancelToken: token);
});

class CommutePreferences {
  const CommutePreferences({this.borders = const {}, this.routes = const {}, this.busy = false});
  final Set<String> borders;
  final Set<String> routes;
  final bool busy;
}

final commutePreferencesProvider = NotifierProvider<CommutePreferencesController, CommutePreferences>(
  CommutePreferencesController.new,
);

class CommutePreferencesController extends Notifier<CommutePreferences> {
  late String _key;
  int _generation = 0;

  @override
  CommutePreferences build() {
    _generation++;
    final config = ref.watch(activeAppConfigProvider);
    _key = 'hkhub.commute.${Uri.encodeComponent(config.apiBaseUrl)}';
    final preferences = ref.watch(preferencesProvider);
    return CommutePreferences(
      borders: (preferences.getStringList('$_key.borders') ?? []).where(borderCodes.contains).toSet(),
      routes: (preferences.getStringList('$_key.routes') ?? []).toSet(),
    );
  }

  Future<void> toggleBorder(String code) => _save('borders', code);
  Future<void> toggleRoute(String id) => _save('routes', id);

  Future<void> _save(String field, String? value) async {
    if (state.busy) return;
    final previous = state;
    final generation = _generation;
    final key = _key;
    final preferences = ref.read(preferencesProvider);
    final borders = {...state.borders};
    final routes = {...state.routes};
    if (field == 'borders' && value != null) {
      if (!borderCodes.contains(value)) return;
      if (!borders.remove(value)) borders.add(value);
    }
    if (field == 'routes' && value != null) {
      if (!routes.remove(value)) routes.add(value);
    }
    state = CommutePreferences(borders: borders, routes: routes, busy: true);
    try {
      final saved = await preferences.setStringList(
        '$key.$field', (field == 'borders' ? borders : routes).toList());
      if (!saved) throw StateError('Could not save commute preference');
      if (generation == _generation) {
        state = CommutePreferences(borders: borders, routes: routes);
      }
    } catch (_) {
      if (generation == _generation) state = previous;
      rethrow;
    }
  }
}

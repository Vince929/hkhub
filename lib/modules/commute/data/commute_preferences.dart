import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/providers.dart';
import 'commute_models.dart';

/// Local-only commute preferences. No account, identity document or travel history
/// is stored, so switching devices simply loses the audience choice and favourites.
class CommutePreferences {
  CommutePreferences(this._preferences, String apiBaseUrl)
      : _key = 'hkhub.commute.${Uri.encodeComponent(apiBaseUrl)}';

  final SharedPreferences _preferences;
  final String _key;

  String get _audienceKey => '$_key.audience';
  String get _favouritesKey => '$_key.ports';

  CommuteAudience? loadAudience() =>
      CommuteAudienceApi.fromApi(_preferences.getString(_audienceKey));

  Future<void> saveAudience(CommuteAudience audience) async {
    if (!await _preferences.setString(_audienceKey, audience.apiValue)) {
      throw StateError('Could not save commute audience');
    }
  }

  Set<String> loadFavourites() =>
      (_preferences.getStringList(_favouritesKey) ?? const <String>[]).toSet();

  Future<void> saveFavourites(Set<String> portCodes) async {
    final ordered = portCodes.toList()..sort();
    if (!await _preferences.setStringList(_favouritesKey, ordered)) {
      throw StateError('Could not save commute favourites');
    }
  }

  Set<String> loadRouteFavourites() =>
      (_preferences.getStringList(_routesKey) ?? const <String>[]).toSet();

  Future<void> saveRouteFavourites(Set<String> routeKeys) async {
    final ordered = routeKeys.toList()..sort();
    if (!await _preferences.setStringList(_routesKey, ordered)) {
      throw StateError('Could not save commute route favourites');
    }
  }
}

final commutePreferencesProvider = Provider<CommutePreferences>((ref) {
  final config = ref.watch(activeAppConfigProvider);
  return CommutePreferences(ref.watch(preferencesProvider), config.apiBaseUrl);
});

/// Null means the traveller has not chosen yet, so both audiences are shown.
class CommuteAudienceController extends Notifier<CommuteAudience?> {
  @override
  CommuteAudience? build() => ref.watch(commutePreferencesProvider).loadAudience();

  /// Persists before updating, so a failed write never looks like a saved choice.
  Future<void> select(CommuteAudience audience) async {
    if (state == audience) return;
    await ref.read(commutePreferencesProvider).saveAudience(audience);
    state = audience;
  }
}

final commuteAudienceProvider =
    NotifierProvider<CommuteAudienceController, CommuteAudience?>(
      CommuteAudienceController.new,
    );

class CommuteFavouritesController extends Notifier<Set<String>> {
  @override
  Set<String> build() => ref.watch(commutePreferencesProvider).loadFavourites();

  Future<void> toggle(String portCode) async {
    final next = {...state};
    if (!next.remove(portCode)) next.add(portCode);
    await ref.read(commutePreferencesProvider).saveFavourites(next);
    state = next;
  }
}

final commuteFavouritesProvider =
    NotifierProvider<CommuteFavouritesController, Set<String>>(
      CommuteFavouritesController.new,
    );

/// Route favourites are keyed by `port:destination`, so a frequent destination can be
/// pinned without claiming that every service on that route is tracked.
class CommuteRouteFavouritesController extends Notifier<Set<String>> {
  @override
  Set<String> build() => ref.watch(commutePreferencesProvider).loadRouteFavourites();

  Future<void> toggle(String routeKey) async {
    final next = {...state};
    if (!next.remove(routeKey)) next.add(routeKey);
    await ref.read(commutePreferencesProvider).saveRouteFavourites(next);
    state = next;
  }
}

final commuteRouteFavouritesProvider =
    NotifierProvider<CommuteRouteFavouritesController, Set<String>>(
      CommuteRouteFavouritesController.new,
    );


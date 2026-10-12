import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/app_config.dart';

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnvironment());

final preferencesProvider = Provider<SharedPreferences>(
  (ref) => throw StateError('SharedPreferences must be initialized in main().'),
);

final apiEnvironmentProvider = NotifierProvider<ApiEnvironmentController, String>(
  ApiEnvironmentController.new,
);

// All requests and environment UI consume this runtime configuration.
// appConfigProvider is refreshed on development hot reload; environment choices stay persisted.
final activeAppConfigProvider = Provider<AppConfig>((ref) {
  final configured = ref.watch(appConfigProvider);
  return configured.withEnvironment(ref.watch(apiEnvironmentProvider));
});

class ApiEnvironmentController extends Notifier<String> {
  String _storageKey(AppConfig config) => 'hkhub.api_environment.${config.environment}';

  @override
  String build() {
    final config = ref.watch(appConfigProvider);
    final preferences = ref.watch(preferencesProvider);
    final saved = preferences.getString(_storageKey(config));
    // Separate defaults prevent a development preference leaking into a production build.
    return saved != null && config.isConfigured(saved) ? saved : config.environment;
  }

  Future<void> setEnvironment(String environment) async {
    final config = ref.read(appConfigProvider);
    if (!config.isConfigured(environment)) {
      throw ArgumentError('API address is not configured for $environment.');
    }
    if (state == environment) return;
    final preferences = ref.read(preferencesProvider);
    final saved = await preferences.setString(_storageKey(config), environment);
    if (!saved) throw StateError('Could not save API environment.');
    state = environment;
  }
}

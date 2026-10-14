import 'package:flutter/foundation.dart';

const apiEnvironments = ['local', 'test', 'production'];

class AppConfig {
  AppConfig({
    required this.environment,
    String? apiBaseUrl,
    Map<String, String> apiBaseUrls = const {},
  }) : apiBaseUrls = _normalizeUrls({
          ...apiBaseUrls,
          if (apiBaseUrl != null) environment: apiBaseUrl,
        }) {
    if (!apiEnvironments.contains(environment)) {
      throw ArgumentError('APP_ENV must be local, test or production.');
    }
    if (!isConfigured(environment)) {
      throw StateError('API address is not configured for $environment.');
    }
  }

  // Public configuration: edit these getters, then hot reload during development.
  // Getters are re-evaluated; top-level/static final initializers would retain old values.
  // Real phones need your Mac's reachable LAN address, not localhost.
  // Empty LOCAL uses the launch command's fallback or the platform default.
  static String get localApiBaseUrl => 'http://localhost:8000/api/';
  static String get testApiBaseUrl => 'http://10.170.182.126:8000/api/';
  static String get productionApiBaseUrl => 'https://10.170.182.126:8000/api/';
  static String get initialEnvironment => kReleaseMode ? 'production' : 'local';

  factory AppConfig.fromEnvironment() {
    // Optional launch overrides select the initial environment/device fallback only.
    // API addresses themselves come from the Dart getters above, never .env.
    const configuredEnvironment = String.fromEnvironment('APP_ENV');
    const localFallback = String.fromEnvironment('LOCAL_API_FALLBACK');
    final environment = configuredEnvironment.isEmpty
        ? initialEnvironment
        : configuredEnvironment;
    final defaultLocalUrl = localFallback.isNotEmpty
        ? localFallback
        : (!kIsWeb && defaultTargetPlatform == TargetPlatform.android
            ? 'http://10.0.2.2:8001/api/'
            : 'http://localhost:8001/api/');
    final localUrl = localApiBaseUrl.trim();
    return AppConfig(
      environment: environment,
      apiBaseUrls: {
        'local': localUrl.isEmpty ? defaultLocalUrl : localUrl,
        'test': testApiBaseUrl,
        'production': productionApiBaseUrl,
      },
    );
  }

  final String environment;
  final Map<String, String> apiBaseUrls;

  String get apiBaseUrl => apiBaseUrls[environment]!;

  bool isConfigured(String value) => apiBaseUrls[value]?.isNotEmpty ?? false;

  AppConfig withEnvironment(String value) =>
      AppConfig(environment: value, apiBaseUrls: apiBaseUrls);

  static Map<String, String> _normalizeUrls(Map<String, String> values) {
    return Map.unmodifiable({
      for (final entry in values.entries)
        if (entry.value.trim().isNotEmpty)
          entry.key: _validateUrl(entry.value.trim(), entry.key),
    });
  }

  static String _validateUrl(String value, String environment) {
    if (!apiEnvironments.contains(environment)) {
      throw ArgumentError('APP_ENV must be local, test or production.');
    }
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        !{'http', 'https'}.contains(uri.scheme) ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw ArgumentError('API URLs must use HTTP(S), without credentials or query.');
    }
    // Local device development may use HTTP; production always uses TLS.
    if (environment == 'production' && uri.scheme != 'https') {
      throw ArgumentError('The production API address must use HTTPS.');
    }
    return value.endsWith('/') ? value : '$value/';
  }
}

import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/locale_controller.dart';
import '../providers.dart';
import 'api_exception.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(activeAppConfigProvider);
  // Recreate language-dependent requests when the app/device language changes.
  final locale = ref.watch(effectiveLocaleProvider);
  final dio = Dio(BaseOptions(
    baseUrl: config.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Accept': 'application/json', 'Accept-Language': locale.toLanguageTag()},
  ));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      options.headers['Accept-Language'] = locale.toLanguageTag();
      final random = Random.secure();
      options.headers['X-Request-ID'] = List.generate(
        16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();
      options.extra['requestStopwatch'] = Stopwatch()..start();
      if (kDebugMode) {
        debugPrint('[api] ${options.method} ${options.uri.origin}${options.uri.path} '
          'request_id=${options.headers['X-Request-ID']}');
      }
      handler.next(options);
    },
    onResponse: (response, handler) {
      if (kDebugMode) {
        final options = response.requestOptions;
        final watch = options.extra['requestStopwatch'] as Stopwatch?;
        watch?.stop();
        debugPrint('[api] completed status=${response.statusCode} path=${options.uri.path} '
          'request_id=${response.headers.value('x-request-id') ?? options.headers['X-Request-ID']} '
          'duration_ms=${watch?.elapsedMilliseconds}');
      }
      handler.next(response);
    },
    onError: (error, handler) {
      if (kDebugMode) {
        final options = error.requestOptions;
        final watch = options.extra['requestStopwatch'] as Stopwatch?;
        watch?.stop();
        debugPrint('[api] failed type=${error.type.name} status=${error.response?.statusCode} '
          'path=${options.uri.path} request_id=${error.response?.headers.value('x-request-id') ?? options.headers['X-Request-ID']} '
          'duration_ms=${watch?.elapsedMilliseconds}');
      }
      handler.next(error);
    },
  ));
  ref.onDispose(() => dio.close(force: true));
  return ApiClient(dio);
});

class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  Future<T> request<T>(
    String path, {
    required T Function(Object? data) decode,
    String method = 'GET',
    Map<String, dynamic>? queryParameters,
    Object? data,
    CancelToken? cancelToken,
    Duration? receiveTimeout,
  }) async {
    // Relative paths preserve /api/. Reject other origins and parent traversal.
    final uri = Uri.parse(path);
    if (uri.hasScheme || uri.hasAuthority || path.startsWith('/') ||
        uri.pathSegments.any((segment) => segment == '..' || segment == '.')) {
      throw ArgumentError('API paths must be relative to API_BASE_URL.');
    }
    try {
      final response = await _dio.request<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method, receiveTimeout: receiveTimeout),
        cancelToken: cancelToken,
      );
      final requestId = response.headers.value('x-request-id') ??
          response.requestOptions.headers['X-Request-ID'] as String?;
      try {
        final result = decode(response.data);
        if (kDebugMode) debugPrint('[api] decoded path=${response.requestOptions.uri.path} request_id=$requestId');
        return result;
      } on FormatException {
        if (kDebugMode) debugPrint('[api] invalid_response path=${response.requestOptions.uri.path} request_id=$requestId');
        throw ApiException(code: 'invalid_response', message: 'Invalid server response',
          requestId: requestId);
      }
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

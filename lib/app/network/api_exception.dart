import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.requestId,
    this.isServerMessage = false,
  });

  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    final payload = response?.data;
    final problem = payload is Map ? payload['error'] : null;
    final requestId = payload is Map && payload['request_id'] is String
        ? payload['request_id'] as String
        : response?.headers.value('x-request-id');
    if (problem is Map && problem['code'] is String && problem['message'] is String) {
      return ApiException(
        code: problem['code'] as String,
        message: problem['message'] as String,
        statusCode: response?.statusCode,
        requestId: requestId,
        isServerMessage: true,
      );
    }
    final code = switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => 'timeout',
      DioExceptionType.cancel => 'cancelled',
      DioExceptionType.connectionError => 'network_error',
      DioExceptionType.badCertificate => 'invalid_certificate',
      DioExceptionType.badResponse => 'http_${response?.statusCode ?? 0}',
      DioExceptionType.unknown => 'network_error',
    };
    return ApiException(
      code: code,
      message: 'Request failed',
      statusCode: response?.statusCode,
      requestId: requestId,
    );
  }

  final String code;
  final String message;
  final int? statusCode;
  final String? requestId;
  final bool isServerMessage;

  @override
  String toString() => 'ApiException($code, status=$statusCode, requestId=$requestId)';
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/api_client.dart';

class ServiceStatus {
  const ServiceStatus({required this.status, required this.database, this.message});

  factory ServiceStatus.fromJson(Object? value) {
    if (value is! Map || value['status'] is! String || value['database'] is! String) {
      throw const FormatException('Invalid readiness response');
    }
    return ServiceStatus(
      status: value['status'] as String,
      database: value['database'] as String,
      message: value['message'] is String ? value['message'] as String : null,
    );
  }

  final String status;
  final String database;
  final String? message;

  bool get isReady => status == 'ok' && database == 'ok';
}

final serviceStatusProvider = FutureProvider.autoDispose<ServiceStatus>((ref) {
  final client = ref.watch(apiClientProvider);
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);
  return client.request(
    'health/ready',
    decode: ServiceStatus.fromJson,
    cancelToken: cancelToken,
  );
});

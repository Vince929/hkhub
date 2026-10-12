import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/network/api_exception.dart';
import '../../../app/theme/app_theme.dart';
import '../data/service_status.dart';

class ServiceConnectionPanel extends ConsumerStatefulWidget {
  const ServiceConnectionPanel({super.key});

  @override
  ConsumerState<ServiceConnectionPanel> createState() => _ServiceConnectionPanelState();
}

class _ServiceConnectionPanelState extends ConsumerState<ServiceConnectionPanel> {
  bool _requested = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final status = _requested ? ref.watch(serviceStatusProvider) : null;
    final loading = status?.isLoading ?? false;
    final message = status == null
        ? strings.serviceDescription
        : status.when(
            data: (value) => value.isReady ? strings.serviceConnected : strings.serviceUnavailable,
            loading: () => strings.checkingConnection,
            error: (error, stack) => _errorMessage(error, strings),
          );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCBDCE8)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.link, color: AppTheme.ferryGreen),
            const SizedBox(width: 8),
            Expanded(child: Text(strings.serviceTitle,
                style: Theme.of(context).textTheme.titleMedium)),
          ]),
          const SizedBox(height: 12),
          Text(message, semanticsLabel: message),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: loading ? null : _checkConnection,
            icon: loading
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh),
            label: Text(_requested ? strings.retry : strings.checkConnection),
          ),
        ],
      ),
    );
  }

  void _checkConnection() {
    if (_requested) ref.invalidate(serviceStatusProvider);
    setState(() => _requested = true);
  }

  String _errorMessage(Object error, AppLocalizations strings) {
    if (error is! ApiException) return strings.serviceUnavailable;
    return switch (error.code) {
      'network_error' => strings.networkError,
      'timeout' => strings.timeoutError,
      'invalid_response' => strings.invalidResponse,
      _ => strings.serviceUnavailable,
    };
  }
}

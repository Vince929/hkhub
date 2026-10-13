import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../../app/config/app_config.dart';
import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/providers.dart';

class ApiEnvironmentSettings extends ConsumerStatefulWidget {
  const ApiEnvironmentSettings({super.key});

  @override
  ConsumerState<ApiEnvironmentSettings> createState() => _ApiEnvironmentSettingsState();
}

class _ApiEnvironmentSettingsState extends ConsumerState<ApiEnvironmentSettings> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final config = ref.watch(activeAppConfigProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(strings.environmentTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(strings.environmentSwitchDescription),
        const SizedBox(height: 12),
        TDRadioGroup(
          key: ValueKey('${config.environment}.$_saving'),
          selectId: config.environment, direction: Axis.vertical,
          radioCheckStyle: TDRadioStyle.hollowCircle,
          onRadioGroupChange: (selectedId) {
            if (selectedId != null) _switchEnvironment(selectedId);
          },
          directionalTdRadios: [
            for (final environment in apiEnvironments) TDRadio(
              id: environment, enable: config.isConfigured(environment) && !_saving,
              title: _label(environment, strings), titleMaxLine: 2, subTitleMaxLine: 4,
              subTitle: config.isConfigured(environment)
                ? config.apiBaseUrls[environment]!
                : strings.environmentNotConfigured('API_BASE_URL_${environment.toUpperCase()}'),
            ),
          ],
        ),
        if (_saving) const LinearProgressIndicator(),
        const SizedBox(height: 16),
        Text(strings.apiAddressTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SelectableText(config.apiBaseUrl),
      ],
    );
  }

  String _label(String environment, AppLocalizations strings) => switch (environment) {
        'local' => strings.environmentLocal,
        'test' => strings.environmentTest,
        'production' => strings.environmentProduction,
        _ => environment,
      };

  Future<void> _switchEnvironment(String environment) async {
    if (_saving || ref.read(apiEnvironmentProvider) == environment) return;
    setState(() => _saving = true);
    try {
      await ref.read(apiEnvironmentProvider.notifier).setEnvironment(environment);
    } catch (_) {
      if (mounted) {
        TDToast.showText(AppLocalizations.of(context).environmentSwitchFailed, context: context);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

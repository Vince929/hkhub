import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/localization/locale_controller.dart';
import '../../../app/widgets/hk_dropdown_field.dart';
import '../../home/presentation/service_connection_panel.dart';
import 'api_environment_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.settingsTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(strings.languageTitle, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(strings.languageDescription),
                  const SizedBox(height: 16),
                  const _LanguagePicker(),
                  const SizedBox(height: 32),
                  const ApiEnvironmentSettings(),
                  const SizedBox(height: 32),
                  const ServiceConnectionPanel(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguagePicker extends ConsumerWidget {
  const _LanguagePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(localeProvider);
    final choices = <(Locale?, String)>[
      (null, AppLocalizations.of(context).systemLanguage),
      (simplifiedChineseLocale, '简体中文'),
      (traditionalChineseLocale, '繁體中文'),
      (cantoneseLocale, '粵語（香港）'),
      (englishLocale, 'English'),
    ];
    return HkDropdownField(
      label: AppLocalizations.of(context).languageTitle,
      value: selected?.toLanguageTag() ?? 'system',
      items: {for (final (locale, label) in choices) (locale?.toLanguageTag() ?? 'system'): label},
      onChanged: (value) {
        final locale = choices.firstWhere((choice) =>
          (choice.$1?.toLanguageTag() ?? 'system') == value).$1;
        ref.read(localeProvider.notifier).setLocale(locale);
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

const traditionalChineseLocale = Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
const simplifiedChineseLocale = Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
const cantoneseLocale = Locale.fromSubtags(
  languageCode: 'yue', scriptCode: 'Hant', countryCode: 'HK',
);
const englishLocale = Locale('en');

const supportedAppLocales = [
  traditionalChineseLocale,
  simplifiedChineseLocale,
  cantoneseLocale,
  englishLocale,
];

final deviceLocalesProvider = NotifierProvider<DeviceLocalesController, List<Locale>>(
  DeviceLocalesController.new,
);

class DeviceLocalesController extends Notifier<List<Locale>> with WidgetsBindingObserver {
  @override
  List<Locale> build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));
    return WidgetsBinding.instance.platformDispatcher.locales;
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    state = locales ?? const <Locale>[];
  }
}

final effectiveLocaleProvider = Provider<Locale>((ref) {
  final selected = ref.watch(localeProvider);
  return selected ?? resolveAppLocale(ref.watch(deviceLocalesProvider), supportedAppLocales);
});

final localeProvider = NotifierProvider<LocaleController, Locale?>(LocaleController.new);

class LocaleController extends Notifier<Locale?> {
  static const _storageKey = 'hkhub.locale';

  @override
  Locale? build() {
    final saved = ref.watch(preferencesProvider).getString(_storageKey);
    for (final locale in supportedAppLocales) {
      if (locale.toLanguageTag() == saved) return locale;
      if (locale == cantoneseLocale && saved == 'yue') return locale;
    }
    return null; // Follow the device until the user explicitly chooses a language.
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale != null && !supportedAppLocales.contains(locale)) {
      throw ArgumentError('Unsupported locale');
    }
    final preferences = ref.read(preferencesProvider);
    if (locale == null) {
      await preferences.remove(_storageKey);
    } else {
      await preferences.setString(_storageKey, locale.toLanguageTag());
    }
    state = locale;
  }
}

Locale resolveAppLocale(List<Locale>? preferred, Iterable<Locale> supported) {
  final available = supported.toList();
  for (final locale in preferred ?? const <Locale>[]) {
    Locale? candidate;
    if (locale.languageCode == 'yue') {
      candidate = cantoneseLocale;
    } else if (locale.languageCode == 'en') {
      candidate = englishLocale;
    } else if (locale.languageCode == 'zh') {
      final traditional = locale.scriptCode == 'Hant' ||
          (locale.scriptCode != 'Hans' && {'HK', 'TW', 'MO'}.contains(locale.countryCode));
      candidate = traditional ? traditionalChineseLocale : simplifiedChineseLocale;
    }
    if (candidate != null && available.contains(candidate)) return candidate;
  }
  return available.isEmpty ? traditionalChineseLocale : available.first;
}

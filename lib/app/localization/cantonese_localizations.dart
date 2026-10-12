import 'package:flutter/widgets.dart';

/// Flutter's built-in controls use Traditional Chinese for Cantonese.
/// The app's own delegate still loads its Cantonese ARB messages.
class CantoneseLocalizationsDelegate<T> extends LocalizationsDelegate<T> {
  const CantoneseLocalizationsDelegate(this.delegate);

  final LocalizationsDelegate<T> delegate;

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'yue';

  @override
  Future<T> load(Locale locale) => delegate.load(
        const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'HK',
        ),
      );

  @override
  bool shouldReload(CantoneseLocalizationsDelegate<T> old) => false;
}

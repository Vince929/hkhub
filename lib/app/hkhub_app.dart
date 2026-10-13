import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'l10n/generated/app_localizations.dart';
import 'localization/cantonese_localizations.dart';
import 'localization/locale_controller.dart';
import 'providers.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class HkHubApp extends ConsumerStatefulWidget {
  const HkHubApp({super.key});

  @override
  ConsumerState<HkHubApp> createState() => _HkHubAppState();
}

class _HkHubAppState extends ConsumerState<HkHubApp> {
  @override
  void initState() {
    super.initState();
    // TDesign follows the nearest Material theme, including education's palette.
    TDTheme.needMultiTheme();
  }

  @override
  void reassemble() {
    super.reassemble();
    // Hot reload replaces Dart method bodies but does not rerun main() or cached providers.
    // Refresh the config and its dependent API clients without resetting the widget tree.
    assert(() {
      ref.invalidate(appConfigProvider);
      return true;
    }());
  }

  @override
  Widget build(BuildContext context) {
    // Validate the selected API configuration even before the first request.
    ref.watch(activeAppConfigProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: ref.watch(effectiveLocaleProvider),
      localeListResolutionCallback: resolveAppLocale,
      supportedLocales: supportedAppLocales,
      localizationsDelegates: const [
        CantoneseLocalizationsDelegate<MaterialLocalizations>(GlobalMaterialLocalizations.delegate),
        CantoneseLocalizationsDelegate<CupertinoLocalizations>(GlobalCupertinoLocalizations.delegate),
        CantoneseLocalizationsDelegate<WidgetsLocalizations>(GlobalWidgetsLocalizations.delegate),
        ...AppLocalizations.localizationsDelegates,
      ],
      routerConfig: ref.watch(routerProvider),
    );
  }
}

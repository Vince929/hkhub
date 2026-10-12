import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hkhub_app/app/config/app_config.dart';
import 'package:hkhub_app/app/hkhub_app.dart';
import 'package:hkhub_app/app/providers.dart';

void main() {
  testWidgets('Home renders tools and opens settings', (tester) async {
    SharedPreferences.setMockInitialValues({'hkhub.locale': 'en'});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        preferencesProvider.overrideWithValue(preferences),
        appConfigProvider.overrideWithValue(AppConfig(
          environment: 'test',
          apiBaseUrl: 'http://localhost:8000/api/',
        )),
      ],
      child: const HkHubApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('HK Hub'), findsOneWidget);
    expect(find.text('Cross-border commute'), findsOneWidget);
    expect(find.text('Not connected yet'), findsNWidgets(4));
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('繁體中文'), findsOneWidget);
    expect(find.text('简体中文'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });
}

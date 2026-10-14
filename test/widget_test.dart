import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hkhub_app/app/config/app_config.dart';
import 'package:hkhub_app/app/hkhub_app.dart';
import 'package:hkhub_app/app/providers.dart';
import 'package:hkhub_app/modules/home/data/home_tools.dart';

/// Serves a fixed catalog so the home grid can be asserted without a server.
/// Home tools come from the API, so the real provider cannot resolve in tests.
class _FixedHomeTools extends HomeToolsController {
  @override
  Future<HomeTools> build() async => HomeTools.fromJson({
        'version': 'test',
        'language': 'en',
        'groups': [
          {
            'id': 'new_hongkongers',
            'title': 'New Hongkongers',
            'items': [
              {
                'id': 'commute',
                'feature_id': 'commute',
                'title': 'Cross-border commute',
                'description': 'Border crossing and transport updates',
                'icon': 'train',
                'visible': true,
                'aliases': <String>[],
              },
              {
                'id': 'residency',
                'feature_id': 'residency',
                'title': 'Residency planning',
                'description': 'Track your stay and the seven-year journey',
                'icon': 'event_note',
                'visible': true,
                'aliases': <String>[],
              },
            ],
          },
        ],
      });
}

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
        homeToolsProvider.overrideWith(_FixedHomeTools.new),
      ],
      child: const HkHubApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('HK Hub'), findsOneWidget);
    expect(find.text('Cross-border commute'), findsOneWidget);
    expect(find.text('Residency planning'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });
}

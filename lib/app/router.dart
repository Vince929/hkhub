import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../modules/commute/presentation/commute_detail_screen.dart';
import '../modules/commute/presentation/commute_screen.dart';
import '../modules/education/presentation/education_screen.dart';
import '../modules/home/presentation/home_screen.dart';
import '../modules/settings/presentation/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/education', builder: (context, state) => const EducationScreen()),
      GoRoute(path: '/commute', builder: (context, state) => const CommuteScreen()),
      // The port code is validated by the screen before any request is made.
      GoRoute(
        path: '/commute/:portCode',
        builder: (context, state) => CommuteDetailScreen(
          portCode: state.pathParameters['portCode'] ?? '',
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

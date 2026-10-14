import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../modules/commute/data/commute_models.dart';
import '../modules/commute/presentation/commute_detail_screen.dart';
import '../modules/commute/presentation/commute_screen.dart';
import '../modules/education/presentation/education_screen.dart';
import '../modules/home/presentation/home_screen.dart';
import '../modules/residency/presentation/residency_screen.dart';
import '../modules/settings/presentation/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/education', builder: (context, state) => const EducationScreen()),
      GoRoute(path: '/residency', builder: (context, state) => const ResidencyScreen()),
      GoRoute(path: '/commute', builder: (context, state) => const CommuteScreen(), routes: [
        GoRoute(path: ':code', builder: (context, state) {
          final code = state.pathParameters['code'];
          return borderCodes.contains(code)
              ? CommuteDetailScreen(code: code!) : const CommuteScreen();
        }),
      ]),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

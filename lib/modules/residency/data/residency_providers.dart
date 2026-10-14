import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import 'residency_calculator.dart';
import 'residency_models.dart';
import 'residency_storage.dart';

/// Hong Kong "today", exposed as a provider so widgets (and tests) share one
/// value per build and can override it deterministically.
final residencyTodayProvider = Provider<DateTime>(
  (ref) => hongKongToday(DateTime.now()),
);

class ResidencyState {
  const ResidencyState({
    required this.profile,
    this.busy = false,
    this.storageFailed = false,
  });

  final ResidencyProfile profile;
  final bool busy;
  final bool storageFailed;
}

final residencyControllerProvider =
    NotifierProvider<ResidencyController, ResidencyState>(ResidencyController.new);

class ResidencyController extends Notifier<ResidencyState> {
  late ResidencyStorage _storage;
  int _generation = 0;

  @override
  ResidencyState build() {
    _generation++;
    final config = ref.watch(activeAppConfigProvider);
    _storage = ResidencyStorage(ref.watch(preferencesProvider), config.apiBaseUrl);
    return ResidencyState(profile: _storage.load());
  }

  Future<void> save(ResidencyProfile profile) async {
    if (state.busy) return;
    final previous = state;
    final generation = _generation;
    final storage = _storage;
    state = ResidencyState(profile: profile, busy: true);
    try {
      await storage.save(profile);
      if (generation == _generation) state = ResidencyState(profile: profile);
    } catch (_) {
      if (generation == _generation) {
        state = ResidencyState(profile: previous.profile, storageFailed: true);
      }
      rethrow;
    }
  }

  Future<void> clear() async {
    if (state.busy) return;
    final previous = state;
    final generation = _generation;
    final storage = _storage;
    state = ResidencyState(profile: previous.profile, busy: true);
    try {
      await storage.clear();
      if (generation == _generation) {
        state = const ResidencyState(profile: ResidencyProfile.empty);
      }
    } catch (_) {
      if (generation == _generation) {
        state = ResidencyState(profile: previous.profile, storageFailed: true);
      }
      rethrow;
    }
  }
}

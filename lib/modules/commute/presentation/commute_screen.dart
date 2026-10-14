import 'package:flutter/material.dart' hide Border;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/hk_sail_mark.dart';
import '../data/commute_models.dart';
import '../data/commute_providers.dart';
import '../theme/commute_theme.dart';
import 'commute_refresh.dart';
import 'commute_strings.dart';
import 'commute_widgets.dart';

class CommuteScreen extends ConsumerStatefulWidget {
  const CommuteScreen({super.key});

  @override
  ConsumerState<CommuteScreen> createState() => _CommuteScreenState();
}

class _CommuteScreenState extends ConsumerState<CommuteScreen>
    with WidgetsBindingObserver, CommuteRefresh<CommuteScreen> {
  @override
  void refreshCommute() {
    if (!ref.read(bordersProvider).isLoading) ref.invalidate(bordersProvider);
  }

  Future<void> _pullRefresh() async {
    refreshCommute();
    try { await ref.read(bordersProvider.future); } catch (_) { /* Rendered by the provider. */ }
  }

  List<Border> _ordered(BordersData data, CommutePreferences preferences) {
    final result = [...data.borders];
    result.sort((left, right) {
      final saved = (preferences.borders.contains(right.code) ? 1 : 0) -
          (preferences.borders.contains(left.code) ? 1 : 0);
      if (saved != 0) return saved;
      return ['LWS', 'LSC', 'SBC'].indexOf(left.code).compareTo(['LWS', 'LSC', 'SBC'].indexOf(right.code));
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final copy = CommuteStrings(Localizations.localeOf(context));
    final data = ref.watch(bordersProvider);
    final preferences = ref.watch(commutePreferencesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(copy.title), actions: [
        IconButton(onPressed: data.isLoading ? null : refreshCommute,
          tooltip: copy.refresh, icon: const Icon(Icons.refresh)),
      ]),
      body: RefreshIndicator(onRefresh: _pullRefresh, child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(20),
          children: [
            CommuteHeroCard(title: copy.selectPort,
              tags: [copy.ports(borderCodes.length), copy.updateInterval]),
            const SizedBox(height: 18),
            if (data.isLoading) const LinearProgressIndicator(minHeight: 2),
            data.when(
              data: (value) => Column(children: [
                for (final border in _ordered(value, preferences)) _BorderCard(
                  border: border, now: value.now, preferences: preferences),
              ]),
              error: (_, _) => CommuteFailure(retry: refreshCommute),
              loading: () => const Padding(padding: EdgeInsets.all(40), child: HkSailLoader(size: 52)),
            ),
            const SizedBox(height: 8),
            Text(copy.source, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(copy.notice, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            const _ResidencyHint(),
          ]),
      ))),
    );
  }
}

/// Light, single-direction nudge to the residency planner (D22).
class _ResidencyHint extends StatelessWidget {
  const _ResidencyHint();

  @override
  Widget build(BuildContext context) {
    final copy = CommuteStrings(Localizations.localeOf(context));
    final radius = BorderRadius.circular(AppTheme.cardRadius);
    return Material(
      color: CommuteTheme.accent.withValues(alpha: 0.08),
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/residency'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            const Icon(Icons.event_note_rounded, size: 20, color: CommuteTheme.accent),
            const SizedBox(width: 10),
            Expanded(child: Text(copy.residencyHint, style: const TextStyle(
              fontSize: 13, height: 1.4, color: AppTheme.ink))),
            const Icon(Icons.chevron_right, color: CommuteTheme.accent),
          ]),
        ),
      ),
    );
  }
}

class _BorderCard extends ConsumerWidget {
  const _BorderCard({required this.border, required this.now, required this.preferences});
  final Border border;
  final DateTime now;
  final CommutePreferences preferences;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = CommuteStrings(Localizations.localeOf(context));
    return Padding(padding: const EdgeInsets.only(bottom: 14), child: Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(side: const BorderSide(color: AppTheme.surfaceLine),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: () => context.push('/commute/${border.code}'), child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 12, 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(border.name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: AppTheme.ink)),
              const SizedBox(height: 3),
              Text('↔ ${border.counterpart}', style: Theme.of(context).textTheme.bodySmall),
            ])),
            FavoriteButton(saved: preferences.borders.contains(border.code),
              onPressed: preferences.busy ? null : () => savePreference(context,
                () => ref.read(commutePreferencesProvider.notifier).toggleBorder(border.code))),
          ]),
          const SizedBox(height: 6),
          BorderQueues(border: border, now: now),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Wrap(spacing: 12, children: [
              for (final mode in border.modes) Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(mode == 'mtr' ? Icons.train_outlined : Icons.directions_bus_outlined, size: 18, color: CommuteTheme.accent),
                const SizedBox(width: 5), Text(copy.mode(mode)),
              ]),
            ])),
            const Icon(Icons.chevron_right, color: CommuteTheme.accent),
          ]),
        ]),
      )),
    ));
  }
}

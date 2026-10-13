import 'package:flutter/material.dart' hide Border;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../data/commute_models.dart';
import '../data/commute_providers.dart';
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
  bool _sortQueue = false;

  @override
  void refreshCommute() {
    if (!ref.read(bordersProvider).isLoading) ref.invalidate(bordersProvider);
  }

  Future<void> _pullRefresh() async {
    refreshCommute();
    try { await ref.read(bordersProvider.future); } catch (_) { /* Rendered by the provider. */ }
  }

  List<Border> _ordered(BordersData data, CommutePreferences preferences) {
    int rank(Border border) {
      if (!_sortQueue || preferences.audience == null) return 0;
      final queue = border.queues[preferences.audience]!;
      return queue.reasonAt(data.now) == 'available' ? queue.code! : 3;
    }
    final result = [...data.borders];
    result.sort((left, right) {
      final saved = (preferences.borders.contains(right.code) ? 1 : 0) -
          (preferences.borders.contains(left.code) ? 1 : 0);
      if (saved != 0) return saved;
      final level = rank(left).compareTo(rank(right));
      if (level != 0) return level;
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
            Text(copy.direction, style: const TextStyle(color: AppTheme.ferryGreen, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(copy.selectPort, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.ink)),
            const SizedBox(height: 18),
            const AudiencePicker(),
            const SizedBox(height: 14),
            SwitchListTile.adaptive(contentPadding: EdgeInsets.zero,
              title: Text(copy.sortQueue), subtitle: Text(copy.favoriteFirst),
              value: _sortQueue && preferences.audience != null,
              onChanged: preferences.audience == null ? null : (value) => setState(() => _sortQueue = value)),
            const SizedBox(height: 10),
            if (data.isLoading) const LinearProgressIndicator(minHeight: 2),
            data.when(
              data: (value) => Column(children: [
                for (final border in _ordered(value, preferences)) _BorderCard(
                  border: border, now: value.now, preferences: preferences),
              ]),
              error: (_, _) => CommuteFailure(retry: refreshCommute),
              loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
            ),
            const SizedBox(height: 8),
            Text(copy.source, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(copy.notice, style: Theme.of(context).textTheme.bodySmall),
          ]),
      ))),
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
      color: Colors.white, borderRadius: BorderRadius.circular(18), clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: () => context.push('/commute/${border.code}'), child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 12, 18),
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
          const Divider(height: 22),
          Text(copy.queueTitle, style: const TextStyle(color: AppTheme.harborBlue, fontWeight: FontWeight.w600)),
          BorderQueues(border: border, audience: preferences.audience, now: now),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Wrap(spacing: 12, children: [
              for (final mode in border.modes) Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(mode == 'mtr' ? Icons.train_outlined : Icons.directions_bus_outlined, size: 18, color: AppTheme.harborBlue),
                const SizedBox(width: 5), Text(copy.mode(mode)),
              ]),
            ])),
            const Icon(Icons.chevron_right, color: AppTheme.harborBlue),
          ]),
        ]),
      )),
    ));
  }
}

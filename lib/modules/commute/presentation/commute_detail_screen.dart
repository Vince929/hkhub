import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/hk_sail_mark.dart';
import '../data/commute_models.dart' show directions, queueAudience;
import '../data/commute_providers.dart';
import '../theme/commute_theme.dart';
import 'commute_history_section.dart';
import 'commute_refresh.dart';
import 'commute_strings.dart';
import 'commute_transit_section.dart';
import 'commute_widgets.dart';

class CommuteDetailScreen extends ConsumerStatefulWidget {
  const CommuteDetailScreen({super.key, required this.code});
  final String code;

  @override
  ConsumerState<CommuteDetailScreen> createState() => _CommuteDetailScreenState();
}

class _CommuteDetailScreenState extends ConsumerState<CommuteDetailScreen>
    with WidgetsBindingObserver, CommuteRefresh<CommuteDetailScreen> {
  @override
  void refreshCommute() {
    if (!ref.read(bordersProvider).isLoading) ref.invalidate(bordersProvider);
    final transit = transitProvider(widget.code);
    if (!ref.read(transit).isLoading) ref.invalidate(transit);
    for (final direction in directions) {
      final history = historyProvider((widget.code, queueAudience, direction));
      if (!ref.read(history).isLoading) ref.invalidate(history);
    }
  }

  Future<void> _pullRefresh() async {
    refreshCommute();
    Future<void> wait(Future<Object?> future) async {
      try { await future; } catch (_) { /* Each section renders its own failure. */ }
    }
    await Future.wait([
      wait(ref.read(bordersProvider.future)),
      wait(ref.read(transitProvider(widget.code).future)),
      for (final direction in directions)
        wait(ref.read(historyProvider((widget.code, queueAudience, direction)).future)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final copy = CommuteStrings(Localizations.localeOf(context));
    final borders = ref.watch(bordersProvider);
    final preferences = ref.watch(commutePreferencesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(copy.title), actions: [
        FavoriteButton(saved: preferences.borders.contains(widget.code),
          onPressed: preferences.busy ? null : () => savePreference(context,
            () => ref.read(commutePreferencesProvider.notifier).toggleBorder(widget.code))),
        IconButton(onPressed: refreshCommute, tooltip: copy.refresh, icon: const Icon(Icons.refresh)),
      ]),
      body: RefreshIndicator(onRefresh: _pullRefresh, child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(20), children: [
          CommuteSection(title: copy.queueTitle, icon: Icons.hourglass_bottom_rounded,
            child: borders.when(
              data: (data) {
                final border = data.borders.firstWhere((item) => item.code == widget.code);
                return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  CommuteHeroCard(title: border.name, tags: [border.counterpart]),
                  const SizedBox(height: 14),
                  Container(padding: const EdgeInsets.all(18),
                    decoration: AppTheme.cardSurface(),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      BorderQueues(border: border, now: data.now),
                      const SizedBox(height: 16),
                      Container(padding: const EdgeInsets.all(14),
                        decoration: AppTheme.tinted(CommuteTheme.accent, radius: 16, alpha: 0.045),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(copy.source, style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 6),
                          Text(copy.notice, style: Theme.of(context).textTheme.bodySmall),
                        ])),
                    ])),
                ]);
              },
              error: (_, _) => CommuteFailure(retry: () => ref.invalidate(bordersProvider)),
              loading: () => const HkSailLoader(),
            )),
          CommuteTransitSection(code: widget.code),
          CommuteHistorySection(code: widget.code),
        ]),
      ))),
    );
  }
}

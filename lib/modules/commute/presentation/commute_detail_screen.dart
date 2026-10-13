import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../data/commute_providers.dart';
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
    final audience = ref.read(commutePreferencesProvider).audience;
    if (audience != null) {
      final history = historyProvider((widget.code, audience));
      if (!ref.read(history).isLoading) ref.invalidate(history);
    }
  }

  Future<void> _pullRefresh() async {
    refreshCommute();
    Future<void> wait(Future<Object?> future) async {
      try { await future; } catch (_) { /* Each section renders its own failure. */ }
    }
    final audience = ref.read(commutePreferencesProvider).audience;
    await Future.wait([
      wait(ref.read(bordersProvider.future)),
      wait(ref.read(transitProvider(widget.code).future)),
      if (audience != null) wait(ref.read(historyProvider((widget.code, audience)).future)),
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
          Text(copy.direction, style: const TextStyle(color: AppTheme.ferryGreen, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          const AudiencePicker(),
          const SizedBox(height: 22),
          CommuteSection(title: copy.queueTitle, child: borders.when(
            data: (data) {
              final border = data.borders.firstWhere((item) => item.code == widget.code);
              return Container(padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(border.name, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
                  Text('↔ ${border.counterpart}', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 10),
                  BorderQueues(border: border, audience: preferences.audience, now: data.now),
                  const Divider(height: 20),
                  Text(copy.source, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Text(copy.notice, style: Theme.of(context).textTheme.bodySmall),
                ]));
            },
            error: (_, _) => CommuteFailure(retry: () => ref.invalidate(bordersProvider)),
            loading: () => const Center(child: CircularProgressIndicator()),
          )),
          CommuteTransitSection(code: widget.code),
          CommuteHistorySection(code: widget.code),
        ]),
      ))),
    );
  }
}

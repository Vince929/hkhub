import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../data/commute_api.dart';
import '../data/commute_models.dart';
import '../data/commute_preferences.dart';
import 'commute_strings.dart';
import 'commute_widgets.dart';

/// Control point list. The audience choice and favourite ports stay on this device.
class CommuteScreen extends ConsumerStatefulWidget {
  const CommuteScreen({super.key});

  @override
  ConsumerState<CommuteScreen> createState() => _CommuteScreenState();
}

class _CommuteScreenState extends ConsumerState<CommuteScreen> with WidgetsBindingObserver {
  Timer? _timer;
  bool _active = true;
  bool _visible = true;
  bool _sortByLevel = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _active = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    // The official source publishes every 15 minutes, so one minute keeps a visible
    // screen reasonably current without polling for a change that cannot exist yet.
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _refresh());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wasVisible = _visible;
    _visible = TickerMode.of(context);
    if (!wasVisible && _visible) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    if (_active) _refresh();
  }

  void _refresh() {
    if (mounted && _active && _visible && (ModalRoute.of(context)?.isCurrent ?? true)) {
      unawaited(ref.read(commuteBordersProvider.notifier).refresh());
    }
  }

  void _warnSaveFailed(CommuteStrings strings) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(strings.preferenceSaveFailed)));
  }

  int _levelRank(PortQueueStatus port, CommuteAudience audience) {
    // Level sorting needs one audience: mixing a resident code with a visitor code
    // would combine two different published time ranges.
    final state = port.forAudience(audience);
    return state.isComparable ? state.statusCode! : 9;
  }

  List<PortQueueStatus> _ordered(
    List<PortQueueStatus> ports,
    CommuteAudience? audience,
    Set<String> favourites,
  ) {
    final indexed = ports.indexed.toList();
    indexed.sort((a, b) {
      final rankA = favourites.contains(a.$2.portCode) ? 0 : 1;
      final rankB = favourites.contains(b.$2.portCode) ? 0 : 1;
      if (rankA != rankB) return rankA - rankB;
      if (_sortByLevel && audience != null) {
        final levelA = _levelRank(a.$2, audience);
        final levelB = _levelRank(b.$2, audience);
        if (levelA != levelB) return levelA - levelB;
      }
      // Falling back to the original index keeps the order deterministic.
      return a.$1 - b.$1;
    });
    return [for (final entry in indexed) entry.$2];
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = CommuteStrings(Localizations.localeOf(context));
    final audience = ref.watch(commuteAudienceProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.title),
        actions: [
          if (audience != null)
            IconButton(
              tooltip: strings.sortByLevel,
              onPressed: () => setState(() => _sortByLevel = !_sortByLevel),
              icon: Icon(_sortByLevel ? Icons.sort : Icons.swap_vert),
            ),
          IconButton(
            tooltip: strings.refresh,
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ref.watch(commuteBordersProvider).when(
        skipLoadingOnRefresh: false,
        skipLoadingOnReload: false,
        skipError: false,
        data: (borders) => _content(borders, strings, audience),
        loading: () => _status(strings, loading: true),
        error: (error, stack) => _status(strings, retry: true, message: strings.errorMessage(error)),
      ),
    );
  }

  Widget _content(CommuteBorders borders, CommuteStrings strings, CommuteAudience? audience) {
    final favourites = ref.watch(commuteFavouritesProvider);
    final ports = _ordered(borders.ports, audience, favourites);
    return RefreshIndicator(
      onRefresh: () => ref.read(commuteBordersProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            CommuteAudienceSwitch(
              strings: strings,
              selected: audience,
              onSelected: (value) async {
                try {
                  await ref.read(commuteAudienceProvider.notifier).select(value);
                } catch (_) {
                  _warnSaveFailed(strings);
                }
              },
            ),
            const SizedBox(height: 16),
            for (final port in ports) _PortCard(
              port: port,
              strings: strings,
              audience: audience,
              favourite: favourites.contains(port.portCode),
              onToggleFavourite: () async {
                try {
                  await ref.read(commuteFavouritesProvider.notifier).toggle(port.portCode);
                } catch (_) {
                  _warnSaveFailed(strings);
                }
              },
            ),
            const SizedBox(height: 8),
            Text(strings.listDisclaimer, style: const TextStyle(
              fontSize: 12, height: 1.5, color: Color(0xFF65788C),
            )),
          ]),
        )),
      ),
    );
  }

  Widget _status(
    CommuteStrings strings, {
    bool loading = false,
    bool retry = false,
    String? message,
  }) {
    return Center(child: SingleChildScrollView(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (loading) const CircularProgressIndicator(strokeWidth: 2)
        else const Icon(Icons.cloud_off_outlined, size: 36, color: AppTheme.harborBlue),
        const SizedBox(height: 16),
        Text(message ?? strings.loadFailed, textAlign: TextAlign.center),
        if (retry) Padding(
          padding: const EdgeInsets.only(top: 12),
          child: FilledButton(onPressed: _refresh, child: Text(strings.retry)),
        ),
      ]),
    ));
  }
}

class _PortCard extends StatelessWidget {
  const _PortCard({
    required this.port,
    required this.strings,
    required this.audience,
    required this.favourite,
    required this.onToggleFavourite,
  });

  final PortQueueStatus port;
  final CommuteStrings strings;
  final CommuteAudience? audience;
  final bool favourite;
  final Future<void> Function() onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final selected = audience;
    // With no choice yet both audiences are shown, because one code means different
    // waiting ranges for residents and visitors.
    final audiences = selected == null
        ? const <CommuteAudience>[CommuteAudience.resident, CommuteAudience.visitor]
        : <CommuteAudience>[selected];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EAF1)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        InkWell(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          onTap: () => context.push('/commute/${port.portCode}'),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(children: [
              Expanded(child: Text(
                strings.connectionLabel(port.portCode),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.ink),
              )),
              IconButton(
                tooltip: favourite ? strings.favouriteRemove : strings.favouriteAdd,
                onPressed: () => unawaited(onToggleFavourite()),
                icon: Icon(
                  favourite ? Icons.star : Icons.star_border,
                  color: favourite ? AppTheme.signalAmber : const Color(0xFF9AAAB8),
                ),
              ),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final item in audiences) CommuteQueueRow(
              strings: strings,
              audience: item,
              label: item == CommuteAudience.resident
                  ? strings.audienceResident
                  : strings.audienceVisitor,
              state: port.forAudience(item),
              prominent: selected != null,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => context.push('/commute/${port.portCode}'),
                child: Text(strings.transitTitle),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

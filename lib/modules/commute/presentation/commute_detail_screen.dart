import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/commute_api.dart';
import '../data/commute_models.dart';
import '../data/commute_preferences.dart';
import 'commute_detail_sections.dart';
import 'commute_strings.dart';
import 'commute_widgets.dart';

/// Single control point: current queue status, the same-window week comparison and the
/// verified Hong Kong-side connections. Each of the three loads independently, so one
/// unavailable source never blanks the screen.
class CommuteDetailScreen extends ConsumerStatefulWidget {
  const CommuteDetailScreen({super.key, required this.portCode});

  final String portCode;

  @override
  ConsumerState<CommuteDetailScreen> createState() => _CommuteDetailScreenState();
}

class _CommuteDetailScreenState extends ConsumerState<CommuteDetailScreen>
    with WidgetsBindingObserver {
  PortQueueStatus? _port;
  Object? _portError;
  CommuteHistory? _history;
  CommuteAudience? _historyAudience;
  Object? _historyError;
  PortTransit? _transit;
  Object? _transitError;
  int _generation = 0;
  CancelToken? _cancel;
  Timer? _timer;
  bool _active = true;
  bool _visible = true;

  bool get _supported => isCommutePort(widget.portCode);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _active = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _refresh());
    if (_supported) unawaited(_load());
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
    if (!_supported) return;
    if (mounted && _active && _visible && (ModalRoute.of(context)?.isCurrent ?? true)) {
      unawaited(_load());
    }
  }

  Future<(T?, Object?)> _attempt<T>(Future<T> request) async {
    try {
      return (await request, null);
    } catch (error) {
      return (null, error);
    }
  }

  Future<void> _load() async {
    final audience = ref.read(commuteAudienceProvider);
    final client = ref.read(commuteDetailClientProvider);
    final token = CancelToken();
    final generation = ++_generation;
    _cancel?.cancel();
    _cancel = token;
    // All requests start together. History is per audience, so it is skipped while no
    // audience is chosen instead of guessing one.
    final port = _attempt(client.port(widget.portCode, token));
    final transit = _attempt(client.transit(widget.portCode, token));
    final history = audience == null
        ? Future<(CommuteHistory?, Object?)>.value((null, null))
        : _attempt(client.history(widget.portCode, audience, token));
    final portResult = await port;
    final transitResult = await transit;
    final historyResult = await history;
    if (!mounted || generation != _generation) return;
    setState(() {
      if (portResult.$1 != null) _port = portResult.$1;
      _portError = portResult.$2;
      if (transitResult.$1 != null) _transit = transitResult.$1;
      _transitError = transitResult.$2;
      if (audience != null) {
        _history = historyResult.$1;
        _historyError = historyResult.$2;
        _historyAudience = audience;
      } else {
        _history = null;
        _historyError = null;
        _historyAudience = null;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cancel?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = CommuteStrings(Localizations.localeOf(context));
    if (!_supported) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.title)),
        body: Center(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(strings.notFound, textAlign: TextAlign.center),
        )),
      );
    }
    final audience = ref.watch(commuteAudienceProvider);
    ref.listen<CommuteAudience?>(commuteAudienceProvider, (previous, next) {
      if (previous != next) unawaited(_load());
    });
    final selected = audience;
    // Without a choice both official groups are shown, because one code means a
    // different waiting range for each.
    final audiences = selected == null
        ? const <CommuteAudience>[CommuteAudience.resident, CommuteAudience.visitor]
        : <CommuteAudience>[selected];
    // A history payload belongs to the audience it was requested for.
    final history = _historyAudience == selected ? _history : null;
    final historyError = _historyAudience == selected ? _historyError : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.connectionLabel(widget.portCode)),
        actions: [
          IconButton(
            tooltip: strings.refresh,
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Center(child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              CommuteAudienceSwitch(
                strings: strings,
                selected: selected,
                onSelected: (value) async {
                  try {
                    await ref.read(commuteAudienceProvider.notifier).select(value);
                  } catch (_) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(strings.preferenceSaveFailed)));
                  }
                },
              ),
              const SizedBox(height: 16),
              CommuteSectionCard(
                title: strings.queueScope,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (_port == null && _portError != null) _portErrorRow(strings)
                  else if (_port == null) const LinearProgressIndicator(minHeight: 3)
                  else ...[
                    for (final item in audiences) CommuteQueueRow(
                      strings: strings,
                      audience: item,
                      label: item == CommuteAudience.resident
                          ? strings.audienceResident
                          : strings.audienceVisitor,
                      state: _port!.forAudience(item),
                      prominent: selected != null,
                    ),
                    Text(strings.queueNotWholeTrip, style: const TextStyle(
                      fontSize: 12, height: 1.5, color: Color(0xFF65788C),
                    )),
                  ],
                ]),
              ),
              CommuteHistoryCard(
                strings: strings,
                audience: selected,
                history: history,
                error: historyError,
                onRetry: _refresh,
              ),
              CommuteTransitCard(
                strings: strings,
                portCode: widget.portCode,
                transit: _transit,
                error: _transitError,
                onRetry: _refresh,
                favouriteRoutes: ref.watch(commuteRouteFavouritesProvider),
                onToggleRoute: (routeKey) async {
                  try {
                    await ref.read(commuteRouteFavouritesProvider.notifier).toggle(routeKey);
                  } catch (_) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(strings.preferenceSaveFailed)));
                  }
                },
              ),
              Text(strings.listDisclaimer, style: const TextStyle(
                fontSize: 12, height: 1.5, color: Color(0xFF65788C),
              )),
            ]),
          )),
        ),
      ),
    );
  }

  Widget _portErrorRow(CommuteStrings strings) => Row(children: [
    Expanded(child: Text(strings.errorMessage(_portError!), style: const TextStyle(fontSize: 13))),
    TextButton(onPressed: _refresh, child: Text(strings.retry)),
  ]);
}

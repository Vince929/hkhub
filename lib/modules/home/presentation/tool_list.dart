import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../data/home_tools.dart';
import 'tool_grid.dart';

class ToolList extends ConsumerStatefulWidget {
  const ToolList({super.key});

  @override
  ConsumerState<ToolList> createState() => _ToolListState();
}

class _ToolListState extends ConsumerState<ToolList> with WidgetsBindingObserver {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  final _groupKeys = <String, GlobalKey>{};
  Timer? _timer;
  bool _active = true;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _active = lifecycle == null || lifecycle == AppLifecycleState.resumed;
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
      unawaited(ref.read(homeToolsProvider.notifier).refresh());
    }
  }

  void _updateQuery(String value) {
    setState(() {});
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _locate(String id) {
    FocusScope.of(context).unfocus();
    final target = _groupKeys[id]?.currentContext;
    if (target != null) {
      unawaited(Scrollable.ensureVisible(
        target, alignment: 0,
        duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 220),
      ));
    }
  }

  List<HomeToolGroup> _groups(HomeTools catalog) {
    // Previews are only for development builds on non-production API environments.
    final preview = kDebugMode && ref.read(activeAppConfigProvider).environment != 'production';
    final query = _search.text.trim();
    final groups = <HomeToolGroup>[];
    for (final group in catalog.groups) {
      final items = group.items.where((tool) => tool.visible &&
          (preview || supportsNativeTool(tool)) && tool.matches(query)).toList(growable: false);
      if (items.isNotEmpty) groups.add(HomeToolGroup(id: group.id, title: group.title, items: items));
    }
    return groups;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _search.dispose();
    _scroll.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    ref.watch(activeAppConfigProvider);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: TextField(
            controller: _search,
            onChanged: _updateQuery,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              hintText: strings.toolsSearch,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty ? null : IconButton(
                tooltip: strings.clearSearch,
                onPressed: () { _search.clear(); _updateQuery(''); },
                icon: const Icon(Icons.close),
              ),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
        )),
      ),
      Expanded(child: ref.watch(homeToolsProvider).when(
        skipLoadingOnRefresh: false,
        skipLoadingOnReload: false,
        skipError: false,
        data: (catalog) => _directory(catalog, strings),
        loading: () => _status(strings.toolsLoading, loading: true),
        error: (error, stack) => _status(strings.toolsLoadFailed, retry: true),
      )),
    ]);
  }

  Widget _directory(HomeTools catalog, AppLocalizations strings) {
    final groups = _groups(catalog);
    // Key maps follow catalog identities, not search results, so locating stays stable.
    final ids = catalog.groups.map((group) => group.id).toSet();
    _groupKeys.removeWhere((id, key) => !ids.contains(id));
    for (final group in groups) {
      _groupKeys.putIfAbsent(group.id, () => GlobalKey());
    }
    return LayoutBuilder(builder: (context, constraints) => Column(children: [
      if (groups.length > 1 && constraints.maxHeight >= 140) _shortcuts(groups),
      Expanded(child: RefreshIndicator(
        onRefresh: () => ref.read(homeToolsProvider.notifier).refresh(),
        child: LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Center(child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: groups.isEmpty
                ? SizedBox(height: (constraints.maxHeight - 40).clamp(0.0, double.infinity).toDouble(),
                    child: Center(child: Text(
                      _search.text.trim().isEmpty ? strings.toolsEmpty : strings.toolsNoResults,
                      textAlign: TextAlign.center,
                    )))
                : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    for (final group in groups) Padding(
                      key: _groupKeys[group.id],
                      padding: const EdgeInsets.only(bottom: 24),
                      child: ToolGroupGrid(group: group),
                    ),
                  ]),
          )),
        )),
      )),
    ]));
  }

  Widget _shortcuts(List<HomeToolGroup> groups) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Row(children: [
          for (final group in groups) Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(group.title),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFDFE8EE)),
              onPressed: () => _locate(group.id),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _status(String message, {bool loading = false, bool retry = false}) {
    return Center(child: SingleChildScrollView(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (loading) const CircularProgressIndicator(strokeWidth: 2)
        else const Icon(Icons.cloud_off_outlined, size: 36, color: AppTheme.harborBlue),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center),
        if (retry) Padding(
          padding: const EdgeInsets.only(top: 16),
          child: FilledButton.icon(
            onPressed: () => ref.read(homeToolsProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context).retry),
          ),
        ),
      ]),
    )));
  }
}

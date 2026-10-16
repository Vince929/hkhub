import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../data/home_tools.dart';
import 'tool_grid.dart';

class ToolList extends StatefulWidget {
  const ToolList({super.key});

  @override
  State<ToolList> createState() => _ToolListState();
}

class _ToolListState extends State<ToolList> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  final _groupKeys = <String, GlobalKey>{};

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
    final query = _search.text.trim();
    final groups = <HomeToolGroup>[];
    for (final group in catalog.groups) {
      final items = group.items.where((tool) => tool.visible && tool.matches(query)).toList(growable: false);
      if (items.isNotEmpty) groups.add(HomeToolGroup(id: group.id, title: group.title, items: items));
    }
    return groups;
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
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
      Expanded(child: _directory(HomeTools.localized(strings), strings)),
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
      Expanded(child: LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
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
      ))),
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
}

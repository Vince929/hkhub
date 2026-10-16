import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/api_client.dart';
import '../../../app/network/api_exception.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/hk_dropdown_field.dart';
import '../../../app/widgets/hk_sail_mark.dart';
import '../data/rent_models.dart';
import '../data/rent_providers.dart';
import 'rent_chart.dart';
import 'rent_details.dart';
import 'rent_strings.dart';
import 'rent_widgets.dart';

class RentScreen extends ConsumerWidget {
  const RentScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = RentStrings(Localizations.localeOf(context));
    final catalog = ref.watch(rentCatalogProvider);
    final client = ref.watch(apiClientProvider);
    void refresh() {
      ref.invalidate(rentCatalogProvider);
      ref.invalidate(rentTrendsProvider);
    }
    return Scaffold(appBar: AppBar(title: Text(copy.title), actions: [
      IconButton(tooltip: copy.refresh, onPressed: catalog.isLoading ? null : refresh,
        icon: const Icon(Icons.refresh)),
    ]), body: RefreshIndicator(onRefresh: () async {
      refresh();
      try { await ref.read(rentCatalogProvider.future); } catch (_) { /* Shown inline. */ }
    }, child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760),
      child: ListView(padding: const EdgeInsets.all(20), physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Text(copy.scope, style: const TextStyle(color: AppTheme.levelNeutral)),
          const SizedBox(height: 16),
          if (catalog.isRefreshing) const LinearProgressIndicator(minHeight: 2),
          if (catalog.hasError && catalog.hasValue) RentNotice(copy.staleResponse, warning: true),
          catalog.when(skipError: catalog.hasValue,
            data: (value) => value.available.isEmpty ? RentSurface(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(copy.notReady, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12), Text(copy.notReadyDetail),
                const SizedBox(height: 12), OutlinedButton(onPressed: refresh, child: Text(copy.retry)),
              ])) : _RentBrowser(key: ValueKey(client), catalog: value),
            error: (_, _) => RentFailure(message: copy.loadFailed, retry: refresh),
            loading: () => const Padding(padding: EdgeInsets.all(48), child: HkSailLoader(size: 52)),
          ),
        ])))));
  }
}

class _RentBrowser extends ConsumerStatefulWidget {
  const _RentBrowser({super.key, required this.catalog});
  final RentCatalog catalog;
  @override
  ConsumerState<_RentBrowser> createState() => _RentBrowserState();
}

class _RentBrowserState extends ConsumerState<_RentBrowser> {
  late String _metric = widget.catalog.available.any((item) => item.metric == 'rental_index')
      ? 'rental_index' : widget.catalog.available.first.metric;
  late List<String> _ids = [_current.defaultId!];
  int _years = 1;
  bool _relative = false;
  String? _catalogRefreshSnapshot;
  RentMetric get _current => widget.catalog.available.firstWhere((item) => item.metric == _metric);
  RentQuery get _query => (_ids.join(','), _years, _relative);
  RentStrings get _copy => RentStrings(Localizations.localeOf(context));

  @override
  Widget build(BuildContext context) {
    if (!widget.catalog.available.any((item) => item.metric == _metric) ||
        _ids.any((id) => !_current.series.any((item) => item.id == id))) {
      return RentFailure(message: _copy.seriesUnavailable, retry: () => setState(() {
        _metric = widget.catalog.available.first.metric;
        _ids = [_current.defaultId!];
        _relative = false;
      }));
    }
    final response = ref.watch(rentTrendsProvider(_query));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _filters(), const SizedBox(height: 16),
      if (response.isRefreshing) RentNotice(_copy.refreshing),
      if (response.hasError && response.hasValue) ...[
        RentNotice(_copy.staleResponse, warning: true),
        OutlinedButton(onPressed: () => ref.invalidate(rentTrendsProvider(_query)), child: Text(_copy.retry)),
      ],
      response.when(skipError: response.hasValue, data: _content,
        error: (error, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          RentFailure(message: _error(error), retry: () => ref.invalidate(rentTrendsProvider(_query))),
          if (_relative) TextButton(onPressed: () => setState(() => _relative = false),
            child: Text(_copy.original)),
          TextButton(onPressed: () {
            ref.invalidate(rentCatalogProvider);
            ref.invalidate(rentTrendsProvider(_query));
          }, child: Text(_copy.refresh)),
        ]), loading: () => const Padding(padding: EdgeInsets.all(48), child: HkSailLoader(size: 52))),
    ]);
  }

  Widget _filters() {
    final primary = _current.series.firstWhere((item) => item.id == _ids.first);
    final choices = _current.series.where((item) => !_ids.contains(item.id) && primary.comparable(item)).toList();
    return RentSurface(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final item in widget.catalog.available) ChoiceChip(label: Text(_copy.metric(item.metric)),
          selected: item.metric == _metric, onSelected: (_) => _switchMetric(item, primary)),
      ]),
      const SizedBox(height: 16), HkDropdownField(
        label: _copy.mainSeries, value: _ids.first,
        items: {for (final item in _current.series) item.id: _copy.seriesName(item)},
        onChanged: (id) => setState(() { _ids = [id]; _relative = false; })),
      const SizedBox(height: 10), Text(_copy.areaBasis, style: Theme.of(context).textTheme.bodySmall),
      if (choices.isNotEmpty && _ids.length < 3) ...[
        const SizedBox(height: 16),
        HkDropdownField(
          label: _copy.addComparison, value: null, hint: _copy.addComparison,
          items: {for (final item in choices) item.id: _copy.seriesName(item)},
          onChanged: (id) => setState(() => _ids = [..._ids, id]),
        ),
        const SizedBox(height: 8),
        Text(_copy.comparisonHint, style: Theme.of(context).textTheme.bodySmall),
      ],
    ]));
  }

  void _switchMetric(RentMetric metric, RentDefinition primary) {
    if (metric.metric == _metric) return;
    final mapped = metric.series.where((item) => item.classCode == primary.classCode && item.region == primary.region);
    setState(() { _metric = metric.metric; _relative = false;
      _ids = [mapped.isEmpty ? metric.defaultId! : mapped.first.id]; });
    if (mapped.isEmpty) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_copy.selectionReset)));
  }

  Widget _content(RentTrends data) {
    if (data.dataset.snapshotId != _current.dataset.snapshotId &&
        data.dataset.snapshotId != _catalogRefreshSnapshot) {
      _catalogRefreshSnapshot = data.dataset.snapshotId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.invalidate(rentCatalogProvider);
      });
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (data.dataset.status == 'failed') RentNotice(_copy.syncFailed, warning: true),
      if (_metric == 'average_rent') RentNotice(_copy.averageWarning),
      RentSummary(series: data.series.first), const SizedBox(height: 16),
      RentChart(key: ValueKey(data.identity), data: data, years: _years,
        onYears: (years) => setState(() => _years = years),
        onRelative: (value) => setState(() => _relative = value),
        onRemove: (id) => setState(() => _ids = _ids.where((value) => value != id).toList())),
      const SizedBox(height: 16), RentMonthlyTable(key: ValueKey('table:${data.identity}'), data: data),
      const SizedBox(height: 16), RentSourceDetails(dataset: data.dataset),
    ]);
  }

  String _error(Object error) => error is ApiException ? switch (error.code) {
    'relative_baseline_unavailable' => _copy.baselineUnavailable,
    'incompatible_series' => _copy.incompatible,
    'series_not_available' => _copy.seriesUnavailable,
    'data_unavailable' => _copy.notReadyDetail,
    _ => _copy.loadFailed,
  } : _copy.loadFailed;
}

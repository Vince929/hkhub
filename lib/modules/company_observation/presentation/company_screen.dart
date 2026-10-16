import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/hk_dropdown_field.dart';
import '../../../app/widgets/hk_sail_mark.dart';
import '../data/company_models.dart';
import '../data/company_providers.dart';
import 'company_liquidations.dart';
import 'company_strings.dart';
import 'company_widgets.dart';

class CompanyScreen extends ConsumerStatefulWidget {
  const CompanyScreen({super.key});
  @override
  ConsumerState<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends ConsumerState<CompanyScreen> {
  String _type = 'month';
  String? _start;

  void _refresh() {
    final start = _start ?? ref.read(companyPeriodsProvider(_type)).asData?.value.defaultStart;
    ref.invalidate(companyPeriodsProvider(_type));
    if (start != null) ref.invalidate(companyOverviewProvider((_type, start)));
    ref.invalidate(companyLiquidationsProvider);
  }

  Future<void> _pullRefresh() async {
    _refresh();
    try {
      final periods = await ref.read(companyPeriodsProvider(_type).future);
      final start = _start ?? periods.defaultStart;
      if (start != null) {
        ref.invalidate(companyOverviewProvider((_type, start)));
        await ref.read(companyOverviewProvider((_type, start)).future);
      }
    } catch (_) { /* The provider renders the failure. */ }
  }

  @override
  Widget build(BuildContext context) {
    final copy = CompanyStrings(Localizations.localeOf(context));
    final periods = ref.watch(companyPeriodsProvider(_type));
    return Scaffold(appBar: AppBar(title: Text(copy.title), actions: [
      IconButton(onPressed: _refresh, tooltip: copy.refresh, icon: const Icon(Icons.refresh)),
    ]), body: RefreshIndicator(onRefresh: _pullRefresh, child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(20), children: [
        Text(copy.intro, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: AppTheme.ink)),
        const SizedBox(height: 18),
        Wrap(spacing: 8, children: [for (final type in ['week', 'month', 'year']) ChoiceChip(
          label: Text(copy.periodType(type)), selected: type == _type,
          onSelected: (_) => setState(() { _type = type; _start = null; }),
        )]),
        const SizedBox(height: 14),
        periods.when(data: (value) => _periodContent(value, copy),
          error: (error, _) => CompanyFailure(error: error, retry: _refresh),
          loading: () => const Padding(padding: EdgeInsets.all(40), child: HkSailLoader(size: 52))),
        const SizedBox(height: 24), const CompanyLiquidationsPanel(),
        const SizedBox(height: 20), Text(copy.attribution, style: const TextStyle(fontSize: 12, height: 1.5)),
        TextButton(onPressed: () => openCompanySource(context, 'https://data.gov.hk/en/terms-and-conditions'),
          child: const Text('DATA.GOV.HK')),
      ]),
    ))));
  }

  Widget _periodContent(CompanyPeriods data, CompanyStrings copy) {
    if (data.periods.isEmpty) return CompanyPanel(child: Text(copy.noPeriods));
    final chosen = _start != null && data.periods.any((period) => period.start == _start)
        ? _start! : data.defaultStart!;
    final overview = ref.watch(companyOverviewProvider((_type, chosen)));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (chosen == data.defaultStart && chosen != data.latestEndedStart &&
          !data.periods.any((period) => period.start == data.latestEndedStart && period.dataStatus == 'complete'))
        Padding(padding: const EdgeInsets.only(bottom: 12),
        child: Text(copy.earlierPeriod, style: const TextStyle(fontSize: 13, color: AppTheme.levelNeutral))),
      if (data.sourceError != null && data.lastSuccessAt != null)
        Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(copy.stale)),
      HkDropdownField(
        label: copy.periodType(_type), value: chosen,
        selectedLabel: copy.dateRange(chosen,
          data.periods.firstWhere((period) => period.start == chosen).end),
        items: {for (final period in data.periods) period.start:
          '${copy.dateRange(period.start, period.end)} (${copy.status(period.dataStatus)})'},
        onChanged: (value) => setState(() => _start = value),
      ),
      const SizedBox(height: 18),
      overview.when(data: (value) => CompanyOverviewContent(data: value),
        error: (error, _) => CompanyFailure(error: error,
          retry: () => ref.invalidate(companyOverviewProvider((_type, chosen)))),
        loading: () => const Padding(padding: EdgeInsets.all(40), child: HkSailLoader(size: 52))),
    ]);
  }
}

class CompanyOverviewContent extends StatelessWidget {
  const CompanyOverviewContent({super.key, required this.data});
  final CompanyOverview data;
  @override
  Widget build(BuildContext context) {
    final copy = CompanyStrings(Localizations.localeOf(context));
    final complete = data.period.dataStatus == 'complete';
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      CompanyPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CompanyStatus(status: data.period.dataStatus), const SizedBox(height: 12),
        Text(complete ? copy.total(data.totalCount!,
          includesRedomiciliation: data.period.includesRedomiciliation) : copy.observed(data.observedCount),
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, height: 1.4)),
        const SizedBox(height: 12),
        Text(data.period.includesRedomiciliation ? copy.populationNotice : copy.legacyPopulationNotice,
          style: const TextStyle(fontSize: 13, height: 1.5)),
        if (!complete) ...[const SizedBox(height: 12),
          Text(data.missing.contains('incorporation_or_redomiciliation') ? copy.combinedDate : copy.partial)],
        if (data.sources.isNotEmpty) ...[const SizedBox(height: 12),
          ExpansionTile(tilePadding: EdgeInsets.zero, childrenPadding: EdgeInsets.zero,
            title: Text(copy.source), children: [for (final source in data.sources) CompanySourceTile(source: source)])],
      ])),
      const SizedBox(height: 18),
      FilledButton.icon(onPressed: () => context.push('/business/reports/${data.period.reportId}/companies'),
        icon: const Icon(Icons.business_outlined), label: Text(copy.allCompanies)),
    ]);
  }
}

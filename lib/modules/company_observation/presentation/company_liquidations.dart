import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/widgets/hk_sail_mark.dart';
import '../data/company_models.dart';
import '../data/company_providers.dart';
import 'company_strings.dart';
import 'company_widgets.dart';

class CompanyLiquidationsPanel extends ConsumerWidget {
  const CompanyLiquidationsPanel({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = CompanyStrings(Localizations.localeOf(context));
    final data = ref.watch(companyLiquidationsProvider);
    return CompanyPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(copy.liquidationTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 10), Text(copy.independentlyDated, style: const TextStyle(fontSize: 13)),
      const SizedBox(height: 12),
      data.when(data: (value) => _LiquidationContent(data: value),
        error: (_, _) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(copy.liquidationUnavailable),
          TextButton(onPressed: () => ref.invalidate(companyLiquidationsProvider), child: Text(copy.retry)),
        ]), loading: () => const HkSailLoader()),
      const SizedBox(height: 12), Text(copy.liquidationNotice, style: const TextStyle(fontSize: 12, height: 1.5)),
    ]));
  }
}

class _LiquidationContent extends StatelessWidget {
  const _LiquidationContent({required this.data});
  final CompanyLiquidations data;
  @override
  Widget build(BuildContext context) {
    final copy = CompanyStrings(Localizations.localeOf(context));
    if (data.months.isEmpty) return Text(copy.liquidationUnavailable);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (data.errorCode != null) Text(copy.stale),
      if (data.status == 'partial') CompanyStatus(status: data.status),
      for (final month in data.months) ExpansionTile(
        key: PageStorageKey('liquidation-${month.start}'), tilePadding: EdgeInsets.zero,
        title: Text(month.start.substring(0, 7)), initiallyExpanded: identical(month, data.months.first),
        children: [
          _Counts(title: copy.commenced, month: month, progress: false),
          const SizedBox(height: 12), _Counts(title: copy.inProgress, month: month, progress: true),
          Align(alignment: Alignment.centerLeft, child: TextButton.icon(
            onPressed: () => openCompanySource(context, month.url), icon: const Icon(Icons.open_in_new, size: 16),
            label: Text(copy.source))),
          Text(copy.fetched(month.fetchedAt), style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 12),
        ],
      ),
    ]);
  }
}

class _Counts extends StatelessWidget {
  const _Counts({required this.title, required this.month, required this.progress});
  final String title;
  final LiquidationMonth month;
  final bool progress;
  @override
  Widget build(BuildContext context) {
    final copy = CompanyStrings(Localizations.localeOf(context));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Wrap(spacing: 18, runSpacing: 8, children: [
        Text('${copy.members}: ${progress ? month.membersInProgress : month.members}'),
        Text('${copy.creditors}: ${progress ? month.creditorsInProgress : month.creditors}'),
      ]),
    ]);
  }
}

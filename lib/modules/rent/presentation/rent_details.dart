import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_theme.dart';
import '../data/rent_models.dart';
import 'rent_strings.dart';
import 'rent_widgets.dart';

class RentMonthlyTable extends StatelessWidget {
  const RentMonthlyTable({super.key, required this.data});
  final RentTrends data;
  @override
  Widget build(BuildContext context) {
    final copy = RentStrings(Localizations.localeOf(context));
    final count = data.series.first.points.length;
    return RentSurface(child: ExpansionTile(tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero, title: Text(copy.table), children: [
        Text(copy.flagsNotice, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12), SingleChildScrollView(scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 32 + MediaQuery.textScalerOf(context).scale(14) * 2.5,
            dataRowMinHeight: 32 + MediaQuery.textScalerOf(context).scale(14) * 2.5,
            dataRowMaxHeight: 32 + MediaQuery.textScalerOf(context).scale(14) * 2.5,
            columns: [DataColumn(label: Text(copy.month)),
            for (final series in data.series) DataColumn(numeric: true,
              label: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end,
                children: [Text(copy.seriesName(series.definition)),
                  Text(data.relative ? copy.relativeUnit : copy.unit(series.definition),
                    style: Theme.of(context).textTheme.bodySmall)])),
          ], rows: [for (var i = count - 1; i >= 0; i--) DataRow(cells: [
            DataCell(Text(data.series.first.points[i].month)),
            for (final series in data.series) DataCell(_value(context, copy, series, i)),
          ])])),
      ]));
  }

  Widget _value(BuildContext context, RentStrings copy, RentSeries series, int index) {
    final point = series.points[index];
    return Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end,
      children: [Text(data.relative ? copy.number(point.relative)
          : copy.number(point.value, index: series.definition.unit == 'index')),
        if (point.value == null || point.flag.isNotEmpty) Text(point.value == null
          ? copy.missing(point.missingReason) : copy.flag(point.flag),
          style: Theme.of(context).textTheme.bodySmall),
      ]);
  }
}

class RentSourceDetails extends StatelessWidget {
  const RentSourceDetails({super.key, required this.dataset});
  final RentDataset dataset;
  @override
  Widget build(BuildContext context) {
    final copy = RentStrings(Localizations.localeOf(context));
    return RentSurface(child: ExpansionTile(tilePadding: EdgeInsets.zero,
      title: Text(copy.sourceTitle), children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(copy.attribution, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 12), Text(copy.areaBasis),
          const SizedBox(height: 12), Text(copy.flagsNotice),
          if (dataset.sourceId == 'average_rent') Padding(padding: const EdgeInsets.only(top: 12),
            child: Text(copy.averageWarning)),
          const SizedBox(height: 12), Text(copy.valuationNotice),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
          Text(copy.through(dataset.coverageEnd ?? '—')),
          const SizedBox(height: 8), Text('${copy.checked}: ${copy.time(dataset.checkedAt)}'),
          const SizedBox(height: 8), Text('${copy.changed}: ${copy.time(dataset.changedAt)}'),
          const SizedBox(height: 8), Text('${copy.attempted}: ${copy.time(dataset.attemptedAt)}'),
          const SizedBox(height: 8), Text('${copy.sourceUpdated}: ${dataset.sourceUpdatedAt == null ? copy.sourceUnknown : copy.time(dataset.sourceUpdatedAt)}'),
          if (dataset.snapshotId != null) Padding(padding: const EdgeInsets.only(top: 8),
            child: Text('Snapshot: ${dataset.snapshotId}', style: Theme.of(context).textTheme.bodySmall)),
          const SizedBox(height: 12), Wrap(spacing: 8, runSpacing: 8, children: [
            _link(context, copy.official, 'https://data.gov.hk/en-data/dataset/hk-rvd-tsinfo_rvd-property-market-statistics'),
            _link(context, copy.dictionary, 'https://www.rvd.gov.hk/datagovhk/Data_Dic.pdf'),
            _link(context, copy.terms, 'https://data.gov.hk/en/terms-and-conditions'),
          ]),
        ])]));
  }

  Widget _link(BuildContext context, String label, String url) => TextButton.icon(
    icon: const Icon(Icons.open_in_new, size: 16, color: AppTheme.ferryGreen), label: Text(label),
    onPressed: () async {
      bool opened;
      try { opened = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); }
      catch (_) { opened = false; }
      if (!opened && context.mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(RentStrings(Localizations.localeOf(context)).linkFailed)));
    });
}

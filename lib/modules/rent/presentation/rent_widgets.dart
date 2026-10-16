import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tool_accents.dart';
import '../data/rent_models.dart';
import 'rent_strings.dart';

final rentAccent = ToolAccents.forGroup('utilities');
final rentSeriesColors = [rentAccent, ...ToolAccents.palette.where((color) => color != rentAccent)].take(3).toList();

class RentSurface extends StatelessWidget {
  const RentSurface({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      side: const BorderSide(color: AppTheme.surfaceLine)),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: const EdgeInsets.all(20), child: child));
}

class RentNotice extends StatelessWidget {
  const RentNotice(this.text, {super.key, this.warning = false});
  final String text;
  final bool warning;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 12),
    decoration: AppTheme.tinted(warning ? AppTheme.signalAmber : rentAccent),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(warning ? Icons.info_outline : Icons.data_usage_outlined,
        size: 18, color: warning ? AppTheme.signalAmber : AppTheme.ink),
      const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(height: 1.5))),
    ]));
}

class RentFailure extends StatelessWidget {
  const RentFailure({super.key, required this.message, required this.retry});
  final String message;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) {
    final copy = RentStrings(Localizations.localeOf(context));
    return RentSurface(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.cloud_off_outlined, color: AppTheme.levelNeutral),
      const SizedBox(height: 12), Text(message),
      const SizedBox(height: 12), OutlinedButton.icon(onPressed: retry,
        icon: const Icon(Icons.refresh), label: Text(copy.retry)),
    ]));
  }
}

class RentSummary extends StatelessWidget {
  const RentSummary({super.key, required this.series});
  final RentSeries series;
  @override
  Widget build(BuildContext context) {
    final copy = RentStrings(Localizations.localeOf(context));
    return RentSurface(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(copy.seriesName(series.definition), style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8), Text(copy.through(series.latestMonth)),
      const SizedBox(height: 6), Text(copy.number(series.latestValue,
        index: series.definition.unit == 'index'), style: const TextStyle(
          fontSize: 40, fontWeight: FontWeight.w700, color: AppTheme.harborBlue)),
      Text(copy.unit(series.definition), style: Theme.of(context).textTheme.bodySmall),
      if (series.latestFlag.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8),
        child: Text(copy.flag(series.latestFlag), style: const TextStyle(color: AppTheme.signalAmber))),
      const SizedBox(height: 18), Wrap(spacing: 32, runSpacing: 14, children: [
        _Change(label: copy.mom, value: copy.percent(series.mom.percent)),
        _Change(label: copy.yoy, value: copy.percent(series.yoy.percent)),
      ]),
      const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
      Text(copy.insight(series), style: const TextStyle(height: 1.5)),
    ]));
  }
}

class _Change extends StatelessWidget {
  const _Change({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: Theme.of(context).textTheme.bodySmall), const SizedBox(height: 4),
    Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600, color: AppTheme.ink)),
  ]);
}

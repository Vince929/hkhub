import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../data/rent_models.dart';
import 'rent_strings.dart';
import 'rent_widgets.dart';

class RentChart extends StatefulWidget {
  const RentChart({super.key, required this.data, required this.years,
    required this.onYears, required this.onRelative, required this.onRemove});
  final RentTrends data;
  final int years;
  final ValueChanged<int> onYears;
  final ValueChanged<bool> onRelative;
  final ValueChanged<String> onRemove;
  @override
  State<RentChart> createState() => _RentChartState();
}

class _RentChartState extends State<RentChart> {
  late int _selected = widget.data.series.first.points.length - 1;
  RentStrings get _copy => RentStrings(Localizations.localeOf(context));

  @override
  Widget build(BuildContext context) => RentSurface(child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final years in [1, 3, 5]) ChoiceChip(label: Text(_copy.years(years)),
          selected: widget.years == years, onSelected: (_) => widget.onYears(years)),
      ]),
      const SizedBox(height: 12), Wrap(spacing: 8, runSpacing: 8, children: [
        ChoiceChip(label: Text(_copy.original), selected: !widget.data.relative,
          onSelected: (_) => widget.onRelative(false)),
        ChoiceChip(label: Text(_copy.relative), selected: widget.data.relative,
          onSelected: (_) => widget.onRelative(true)),
      ]),
      const SizedBox(height: 14), Text(widget.data.relative ? _copy.relativeUnit
        : _copy.unit(widget.data.series.first.definition), style: Theme.of(context).textTheme.bodySmall),
      if (widget.data.relative) Padding(padding: const EdgeInsets.only(top: 8),
        child: Text(_copy.relativeNotice, style: Theme.of(context).textTheme.bodySmall)),
      const SizedBox(height: 20), _plot(),
      const SizedBox(height: 10), Text('${widget.data.startMonth} → ${widget.data.endMonth}',
        textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 14), _legend(),
      const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
      _selection(),
      const SizedBox(height: 12),
      for (final item in widget.data.series) Padding(padding: const EdgeInsets.only(bottom: 6),
        child: Wrap(spacing: 8, children: [Text(_copy.seriesName(item.definition)),
          Text('${_copy.period}: ${_copy.percent(item.period.percent)}',
            style: const TextStyle(fontWeight: FontWeight.w600))])),
      if (!widget.data.complete) Padding(padding: const EdgeInsets.only(top: 12),
        child: Text(_copy.partial, style: Theme.of(context).textTheme.bodySmall)),
      if (widget.data.actualStartMonth != widget.data.startMonth) Padding(
        padding: const EdgeInsets.only(top: 8), child: Text(_copy.historyStarts(widget.data.actualStartMonth))),
    ]));

  Widget _plot() {
    final values = widget.data.series.expand((item) => item.points)
        .map((point) => widget.data.relative ? point.relative : point.value).whereType<double>().toList();
    if (values.isEmpty) return SizedBox(height: 180, child: Center(child: Text(_copy.unavailable)));
    final (minY, maxY, interval) = _bounds(values);
    final last = widget.data.series.first.points.length - 1;
    return Semantics(label: '${_copy.title}. ${widget.data.startMonth} → ${widget.data.endMonth}. ${_copy.table}',
      child: SizedBox(height: 240, child: LineChart(LineChartData(
        minX: 0, maxX: last.toDouble(), minY: minY, maxY: maxY,
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: interval,
          getDrawingHorizontalLine: (_) => const FlLine(color: AppTheme.surfaceLine, strokeWidth: 1)),
        borderData: FlBorderData(show: false), titlesData: _titles(last, interval),
        lineTouchData: LineTouchData(handleBuiltInTouches: false, touchCallback: (event, response) {
          final spots = response?.lineBarSpots;
          if (event.isInterestedForInteractions && spots != null && spots.isNotEmpty) {
            final index = spots.first.x.round().clamp(0, last).toInt();
            if (index != _selected) setState(() => _selected = index);
          }
        }),
        lineBarsData: [for (var i = 0; i < widget.data.series.length; i++) _line(i)],
      ), duration: Duration.zero)));
  }

  LineChartBarData _line(int index) {
    final item = widget.data.series[index];
    final spots = <FlSpot>[];
    for (var i = 0; i < item.points.length; i++) {
      final point = item.points[i];
      final value = widget.data.relative ? point.relative : point.value;
      if (point.comparabilityBreak && spots.isNotEmpty) spots.add(FlSpot.nullSpot);
      spots.add(value == null ? FlSpot.nullSpot : FlSpot(i.toDouble(), value));
    }
    return LineChartBarData(spots: spots, isCurved: false, color: rentSeriesColors[index], barWidth: 2.5,
      dashArray: index == 0 ? null : index == 1 ? [7, 4] : [2, 4],
      dotData: FlDotData(show: true, checkToShowDot: (spot, _) => spot.x.round() == _selected,
        getDotPainter: (_, _, _, _) => FlDotCirclePainter(radius: 4,
          color: rentSeriesColors[index], strokeWidth: 2, strokeColor: Colors.white)));
  }

  FlTitlesData _titles(int last, double interval) => FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 52, interval: interval,
      getTitlesWidget: (value, meta) => Padding(padding: const EdgeInsets.only(right: 6),
        child: Text(value.toStringAsFixed(0), textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 11, color: AppTheme.levelNeutral))))),
    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32,
      interval: last / 2, getTitlesWidget: (value, meta) {
        final index = value.round();
        if (index < 0 || index > last || (value - index).abs() > 0.01) return const SizedBox.shrink();
        final month = widget.data.series.first.points[index].month;
        return Padding(padding: const EdgeInsets.only(top: 8),
          child: Text(month, style: const TextStyle(fontSize: 10, color: AppTheme.levelNeutral)));
      })));

  Widget _legend() => Wrap(spacing: 10, runSpacing: 10, children: [
    for (var i = 0; i < widget.data.series.length; i++) InputChip(
      avatar: Text(i == 0 ? '━' : i == 1 ? '┄' : '┈',
        style: TextStyle(color: rentSeriesColors[i], fontWeight: FontWeight.w900)),
      label: Text(_copy.seriesName(widget.data.series[i].definition)),
      deleteButtonTooltipMessage: _copy.remove,
      onDeleted: i == 0 ? null : () => widget.onRemove(widget.data.series[i].definition.id)),
  ]);

  Widget _selection() {
    final points = widget.data.series.first.points;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('${_copy.selectedMonth}: ${points[_selected].month}',
        style: const TextStyle(fontWeight: FontWeight.w600)),
      Slider(value: _selected.toDouble(), min: 0, max: (points.length - 1).toDouble(),
        divisions: points.length - 1, label: points[_selected].month,
        semanticFormatterCallback: (value) => points[value.round()].month,
        onChanged: (value) => setState(() => _selected = value.round())),
      for (var i = 0; i < widget.data.series.length; i++) _selectedValue(i),
    ]);
  }

  Widget _selectedValue(int index) {
    final series = widget.data.series[index];
    final point = series.points[_selected];
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Wrap(spacing: 8, runSpacing: 4,
      children: [Text(_copy.seriesName(series.definition)),
        Text(widget.data.relative ? _copy.number(point.relative)
          : _copy.number(point.value, index: series.definition.unit == 'index'),
          style: TextStyle(color: rentSeriesColors[index], fontWeight: FontWeight.w700)),
        if (point.value == null) Text(_copy.missing(point.missingReason)),
        if (point.flag.isNotEmpty) Text(_copy.flag(point.flag)),
      ]));
  }
}

(double, double, double) _bounds(List<double> values) {
  final low = values.reduce(math.min), high = values.reduce(math.max);
  final spread = math.max(high - low, math.max(high.abs() * 0.04, 2.0));
  final raw = spread / 4;
  final magnitude = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
  final step = (raw / magnitude).ceil() * magnitude;
  final min = math.max(0.0, ((low - spread * 0.1) / step).floor() * step);
  final max = ((high + spread * 0.1) / step).ceil() * step;
  return (min, math.max(max, min + step), step);
}

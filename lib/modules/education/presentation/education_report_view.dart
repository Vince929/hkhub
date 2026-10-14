import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../data/education_models.dart';
import '../theme/education_theme.dart';
import 'education_strings.dart';

Color _tierColor(String tier) => switch (tier) {
  'reach' => AppTheme.levelHigh,
  'match' => AppTheme.levelMedium,
  _ => AppTheme.levelLow,
};

class EducationReportView extends StatefulWidget {
  const EducationReportView({super.key, required this.report, required this.onEdit});
  final EducationReport report;
  final VoidCallback onEdit;

  @override
  State<EducationReportView> createState() => _EducationReportViewState();
}

class _EducationReportViewState extends State<EducationReportView> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final strings = EducationStrings(Localizations.localeOf(context));
    final schools = widget.report.schools.where((school) =>
      _filter == 'all' || school.programmes.any((item) => item.tier == _filter)).toList();
    if (_filter == 'all') {
      schools.sort((a, b) {
        final probabilityOrder = b.maximum.compareTo(a.maximum);
        return probabilityOrder != 0 ? probabilityOrder : a.id.compareTo(b.id);
      });
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _overview(strings),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: widget.onEdit,
        icon: const Icon(Icons.edit_outlined, size: 19), label: Text(strings.edit)),
      const SizedBox(height: 16),
      Row(children: [
        const Icon(Icons.account_balance_outlined, size: 20, color: EducationTheme.blue),
        const SizedBox(width: 9),
        Expanded(child: Text(strings.programmeLabel, style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700, color: EducationTheme.ink))),
      ]),
      const SizedBox(height: 10),
      _filters(strings),
      const SizedBox(height: 12),
      if (schools.isEmpty) Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(children: [
          const Icon(Icons.search_off_rounded, size: 34, color: EducationTheme.muted),
          const SizedBox(height: 12),
          Text(widget.report.schools.isEmpty ? strings.noSchools : strings.noResults,
            textAlign: TextAlign.center, style: const TextStyle(height: 1.6, color: EducationTheme.muted)),
        ]),
      ),
      for (final school in schools) Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _SchoolCard(key: ValueKey(school.id), school: school, filter: _filter, strings: strings),
      ),
    ]);
  }

  Widget _overview(EducationStrings strings) {
    final date = DateTime.parse(widget.report.generatedAt).toLocal();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: EducationTheme.ink, borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 36, height: 36,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.school_rounded, color: Color(0xFF8DE2D6), size: 25)),
          const SizedBox(width: 12),
          Expanded(child: Text(strings.reportTitle,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 10),
        Text(strings.schoolCount(widget.report.schools.length),
          style: const TextStyle(color: Color(0xFFB9D3E7), fontSize: 13, height: 1.5)),
        const SizedBox(height: 8),
        Divider(color: Colors.white.withValues(alpha: 0.13)),
        const SizedBox(height: 8),
        Text(strings.reportOverview,
          style: const TextStyle(color: Color(0xFF8DE2D6), fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SelectableText(widget.report.summary,
          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.history_rounded, color: Color(0xFFB9D3E7), size: 15),
          const SizedBox(width: 6),
          Expanded(child: Text('${strings.saved}\n${MaterialLocalizations.of(context).formatMediumDate(date)}',
            style: const TextStyle(color: Color(0xFFB9D3E7), fontSize: 11, height: 1.6))),
        ]),
      ]),
    );
  }

  Widget _filters(EducationStrings strings) {
    final programmes = widget.report.schools.expand((school) => school.programmes).toList();
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
      for (final filter in ['all', 'reach', 'match', 'safer']) Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text('${filter == 'all' ? strings.all : strings.band(filter)}  '
            '${filter == 'all' ? programmes.length : programmes.where((item) => item.tier == filter).length}'),
          selected: _filter == filter, showCheckmark: false,
          labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
            color: _filter == filter ? Colors.white : EducationTheme.muted),
          selectedColor: filter == 'all' ? EducationTheme.blue : _tierColor(filter),
          backgroundColor: Colors.white, side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          onSelected: (_) => setState(() => _filter = filter),
        ),
      ),
    ]));
  }
}

class _SchoolCard extends StatelessWidget {
  const _SchoolCard({super.key, required this.school, required this.filter, required this.strings});
  final SchoolResult school;
  final String filter;
  final EducationStrings strings;

  @override
  Widget build(BuildContext context) {
    final color = _tierColor(school.tier);
    final programmes = school.programmes.where((item) => filter == 'all' || item.tier == filter).toList();
    if (filter == 'all') {
      programmes.sort((a, b) {
        final probabilityOrder = b.probability.compareTo(a.probability);
        return probabilityOrder != 0 ? probabilityOrder : a.nameEn.compareTo(b.nameEn);
      });
    }
    final single = school.programmes.length == 1;
    final probability = single ? '${school.programmes.single.probability}%'
        : '${school.minimum}%–${school.maximum}%';
    final explanation = single ? strings.singleProbabilityExplanation : strings.rangeExplanation;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EducationTheme.line)),
      child: ExpansionTile(
        key: ValueKey('${school.id}:$filter'), initiallyExpanded: false,
        dense: true, visualDensity: VisualDensity.compact,
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        shape: const Border(), collapsedShape: const Border(),
        leading: Container(width: 36, height: 36, alignment: Alignment.center,
          decoration: BoxDecoration(color: const Color(0xFFEAF0FF), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.account_balance_rounded, color: EducationTheme.blue, size: 20)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(school.name, style: const TextStyle(fontSize: 16, height: 1.3,
            fontWeight: FontWeight.w700, color: EducationTheme.ink)),
          if (school.name != school.nameEn) Padding(padding: const EdgeInsets.only(top: 2),
            child: Text(school.nameEn,
              style: const TextStyle(fontSize: 11, height: 1.3, color: EducationTheme.muted))),
        ]),
        subtitle: Padding(padding: const EdgeInsets.only(top: 6),
          child: Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
            Tooltip(message: explanation, child: Text(probability,
              semanticsLabel: '${single ? strings.aiEstimate : strings.probabilityRange}: $probability',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: color))),
            _TierBadge(tier: school.tier, strings: strings),
            Text(strings.programmeCount(school.programmes.length),
              style: const TextStyle(fontSize: 11, color: EducationTheme.muted)),
          ])),
        children: [
          Align(alignment: Alignment.centerLeft, child: Text(explanation,
            style: const TextStyle(fontSize: 11, height: 1.4, color: EducationTheme.muted))),
          for (final programme in programmes) Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _ProgrammeCard(key: ValueKey('${school.id}:${programme.nameEn}'),
              programme: programme, strings: strings),
          ),
        ],
      ),
    );
  }
}

class _ProgrammeCard extends StatelessWidget {
  const _ProgrammeCard({super.key, required this.programme, required this.strings});
  final ProgrammeResult programme;
  final EducationStrings strings;

  @override
  Widget build(BuildContext context) {
    final color = _tierColor(programme.tier);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: const Color(0xFFF6F8FC), borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        initiallyExpanded: false, dense: true, visualDensity: VisualDensity.compact,
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        shape: const Border(), collapsedShape: const Border(),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(programme.name, style: const TextStyle(fontSize: 14, height: 1.35,
            fontWeight: FontWeight.w600, color: EducationTheme.ink)),
          if (programme.nameEn != programme.name) Padding(padding: const EdgeInsets.only(top: 2),
            child: Text(programme.nameEn,
              style: const TextStyle(fontSize: 11, height: 1.3, color: EducationTheme.muted))),
        ]),
        subtitle: Padding(padding: const EdgeInsets.only(top: 5),
          child: Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
            Text('${programme.probability}%', style: TextStyle(fontSize: 20,
              fontWeight: FontWeight.w700, letterSpacing: -0.4, color: color)),
            _TierBadge(tier: programme.tier, strings: strings),
            Text(strings.aiEstimate, style: const TextStyle(fontSize: 11, color: EducationTheme.muted)),
          ])),
        children: [
          Align(alignment: Alignment.centerLeft, child: SelectableText(programme.relevance,
            style: const TextStyle(fontSize: 13, height: 1.5, color: EducationTheme.ink))),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
            value: programme.probability / 100, minHeight: 4, color: color,
            backgroundColor: color.withValues(alpha: 0.10),
            semanticsLabel: strings.aiEstimate, semanticsValue: '${programme.probability}%',
          )),
          const SizedBox(height: 8),
          _Reasons(title: strings.strengths, items: programme.strengths,
            icon: Icons.check_circle_outline_rounded, accent: EducationTheme.teal),
          const SizedBox(height: 6),
          _Reasons(title: strings.weaknesses, items: programme.weaknesses,
            icon: Icons.info_outline_rounded, accent: AppTheme.levelMedium),
          const SizedBox(height: 6),
          _Reasons(title: strings.nextSteps, items: programme.nextSteps,
            icon: Icons.route_outlined, accent: EducationTheme.blue),
        ],
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier, required this.strings});
  final String tier;
  final EducationStrings strings;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: _tierColor(tier).withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(10)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.circle, size: 6, color: _tierColor(tier)), const SizedBox(width: 6),
      Flexible(child: Text(strings.band(tier), style: TextStyle(color: _tierColor(tier),
        fontSize: 12, fontWeight: FontWeight.w600))),
    ]),
  );
}

class _Reasons extends StatelessWidget {
  const _Reasons({required this.title, required this.items, required this.icon, required this.accent});
  final String title;
  final List<String> items;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, size: 17, color: accent), const SizedBox(width: 7),
        Expanded(child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accent)))]),
      const SizedBox(height: 6),
      for (final item in items) Padding(padding: const EdgeInsets.only(bottom: 3),
        child: SelectableText(item, style: const TextStyle(fontSize: 13, height: 1.5, color: EducationTheme.ink))),
    ]),
  );
}

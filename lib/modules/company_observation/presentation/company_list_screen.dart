import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/widgets/hk_sail_mark.dart';
import '../data/company_models.dart';
import '../data/company_providers.dart';
import 'company_strings.dart';
import 'company_widgets.dart';

class CompanyListScreen extends ConsumerStatefulWidget {
  const CompanyListScreen({super.key, required this.reportId, this.topicId});
  final String reportId;
  final String? topicId;
  @override
  ConsumerState<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends ConsumerState<CompanyListScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';
  int _generation = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _searchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() { _query = value.trim(); _generation++; });
    });
  }

  void _backToOverview() {
    ref.invalidate(companyOverviewProvider);
    ref.invalidate(companyPeriodsProvider);
    if (context.canPop()) { context.pop(); } else { context.go('/business'); }
  }

  @override
  Widget build(BuildContext context) {
    final copy = CompanyStrings(Localizations.localeOf(context));
    final topicId = widget.topicId;
    final topic = topicId == null ? null : ref.watch(companyTopicProvider((widget.reportId, topicId)));
    return Scaffold(appBar: AppBar(title: Text(topic?.asData?.value.title ?? copy.allCompanies)),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(padding: const EdgeInsets.all(20), children: [
          if (topic != null) ...[
            topic.when(data: (value) => CompanyPanel(child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(value.explanation, style: const TextStyle(height: 1.6)),
                const SizedBox(height: 12), Text(copy.count(value.count)),
                const SizedBox(height: 12), Text(copy.synonyms, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8), Wrap(spacing: 8, runSpacing: 6,
                  children: [for (final term in value.terms) Chip(label: Text(term))]),
                if (value.fallback) Text(copy.languageFallback, style: const TextStyle(fontSize: 12)),
              ])),
              error: (error, _) => CompanyFailure(error: error, back: _backToOverview,
                retry: () => ref.invalidate(companyTopicProvider((widget.reportId, topicId!)))),
              loading: () => const HkSailLoader()),
            const SizedBox(height: 18),
          ],
          Text(copy.notice, style: const TextStyle(fontSize: 13, height: 1.5)),
          const SizedBox(height: 14),
          TextField(controller: _search, maxLength: 120, onChanged: _searchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(labelText: copy.search, counterText: '',
              prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder(),
              suffixIcon: IconButton(tooltip: copy.refresh, icon: const Icon(Icons.clear),
                onPressed: () { _search.clear(); _searchChanged(''); }))),
          const SizedBox(height: 8), Text(copy.searchNotice, style: const TextStyle(fontSize: 12, height: 1.5)),
          const SizedBox(height: 18),
          _CompanyPageSection(key: ValueKey('${widget.reportId}:$topicId:$_query:$_generation'),
            reportId: widget.reportId, topicId: topicId, query: _query, cursor: null, back: _backToOverview),
        ]),
      )),
    );
  }
}

class _CompanyPageSection extends ConsumerStatefulWidget {
  const _CompanyPageSection({super.key, required this.reportId, required this.topicId,
    required this.query, required this.cursor, required this.back});
  final String reportId, query;
  final String? topicId, cursor;
  final VoidCallback back;
  @override
  ConsumerState<_CompanyPageSection> createState() => _CompanyPageSectionState();
}

class _CompanyPageSectionState extends ConsumerState<_CompanyPageSection> {
  bool _more = false;
  @override
  Widget build(BuildContext context) {
    final copy = CompanyStrings(Localizations.localeOf(context));
    final key = (widget.reportId, widget.topicId, widget.query, widget.cursor);
    final page = ref.watch(companyPageProvider(key));
    return page.when(data: (value) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (value.companies.isEmpty && widget.cursor == null)
        CompanyPanel(child: Text(widget.query.isEmpty ? copy.noCompanies : copy.noResults)),
      for (final company in value.companies) _CompanyRow(
        key: PageStorageKey('${widget.reportId}:${widget.topicId}:${widget.query}:${company.key}'),
        company: company),
      if (value.nextCursor != null)
        if (_more) _CompanyPageSection(reportId: widget.reportId, topicId: widget.topicId,
          query: widget.query, cursor: value.nextCursor, back: widget.back)
        else OutlinedButton(onPressed: () => setState(() => _more = true), child: Text(copy.more)),
    ]), error: (error, _) => CompanyFailure(error: error, retry: () => ref.invalidate(companyPageProvider(key)),
        back: widget.back), loading: () => const Padding(padding: EdgeInsets.all(24), child: HkSailLoader()));
  }
}

class _CompanyRow extends StatelessWidget {
  const _CompanyRow({super.key, required this.company});
  final ObservedCompany company;
  @override
  Widget build(BuildContext context) {
    final copy = CompanyStrings(Localizations.localeOf(context));
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: CompanyPanel(
      child: ExpansionTile(
        maintainState: true,
        shape: const Border(), collapsedShape: const Border(),
        backgroundColor: Colors.transparent, collapsedBackgroundColor: Colors.transparent,
        tilePadding: EdgeInsets.zero, childrenPadding: EdgeInsets.zero,
        title: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (company.nameZh.isNotEmpty) Text(company.nameZh,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          if (company.nameEn.isNotEmpty) Text(company.nameEn, style: const TextStyle(fontSize: 14, height: 1.4)),
        ]),
        subtitle: Padding(padding: const EdgeInsets.only(top: 8), child: Text(copy.registered(company.date))),
        children: [
          Align(alignment: Alignment.centerLeft,
            child: SelectableText('${company.identifierType.toUpperCase()}: ${company.identifier}')),
          if (company.evidence.isNotEmpty) ...[
            const SizedBox(height: 12), Align(alignment: Alignment.centerLeft, child: Text(copy.evidence)),
            const SizedBox(height: 8), Align(alignment: Alignment.centerLeft,
              child: SelectableText(company.evidence.toSet().join(' / '))),
          ],
          CompanySourceTile(source: company.source),
        ],
      ),
    ));
  }
}

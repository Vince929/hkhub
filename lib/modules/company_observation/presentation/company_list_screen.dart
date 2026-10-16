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
  const CompanyListScreen({super.key, required this.reportId});
  final String reportId;
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
    return Scaffold(appBar: AppBar(title: Text(copy.allCompanies)),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(padding: const EdgeInsets.all(20), children: [
          TextField(controller: _search, maxLength: 120, onChanged: _searchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(labelText: copy.search, counterText: '',
              prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder(),
              suffixIcon: IconButton(tooltip: copy.refresh, icon: const Icon(Icons.clear),
                onPressed: () { _search.clear(); _searchChanged(''); }))),
          const SizedBox(height: 8), Text(copy.searchNotice, style: const TextStyle(fontSize: 12, height: 1.5)),
          const SizedBox(height: 18),
          _CompanyPageSection(key: ValueKey('${widget.reportId}:$_query:$_generation'),
            reportId: widget.reportId, query: _query, cursor: null, back: _backToOverview),
        ]),
      )),
    );
  }
}

class _CompanyPageSection extends ConsumerStatefulWidget {
  const _CompanyPageSection({super.key, required this.reportId,
    required this.query, required this.cursor, required this.back});
  final String reportId, query;
  final String? cursor;
  final VoidCallback back;
  @override
  ConsumerState<_CompanyPageSection> createState() => _CompanyPageSectionState();
}

class _CompanyPageSectionState extends ConsumerState<_CompanyPageSection> {
  bool _more = false;
  @override
  Widget build(BuildContext context) {
    final copy = CompanyStrings(Localizations.localeOf(context));
    final key = (widget.reportId, widget.query, widget.cursor);
    final page = ref.watch(companyPageProvider(key));
    return page.when(data: (value) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (widget.cursor == null) Padding(padding: const EdgeInsets.only(bottom: 12),
        child: Text(value.includesRedomiciliation ? copy.populationNotice : copy.legacyPopulationNotice,
          style: const TextStyle(fontSize: 13, height: 1.5))),
      if (value.companies.isEmpty && widget.cursor == null)
        CompanyPanel(child: Text(widget.query.isEmpty ? copy.noCompanies : copy.noResults)),
      for (final company in value.companies) _CompanyRow(
        key: PageStorageKey('${widget.reportId}:${widget.query}:${company.key}'),
        company: company),
      if (value.nextCursor != null)
        if (_more) _CompanyPageSection(reportId: widget.reportId,
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
        subtitle: Padding(padding: const EdgeInsets.only(top: 8), child: Text(copy.registered(company.date,
          includesRedomiciliation: company.eventType == 'incorporation_or_redomiciliation'))),
        children: [
          Align(alignment: Alignment.centerLeft,
            child: SelectableText('${company.identifierType.toUpperCase()}: ${company.identifier}')),
          CompanySourceTile(source: company.source),
        ],
      ),
    ));
  }
}

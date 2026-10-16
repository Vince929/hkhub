import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/network/api_exception.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tool_accents.dart';
import '../data/company_models.dart';
import 'company_strings.dart';

Future<void> openCompanySource(BuildContext context, String url) async {
  final copy = CompanyStrings(Localizations.localeOf(context));
  try {
    final uri = Uri.parse(url);
    if (uri.scheme != 'https' || !{'www.cr.gov.hk', 'data.gov.hk'}.contains(uri.host) ||
        uri.userInfo.isNotEmpty || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw const FormatException('Invalid company source');
    }
  } catch (_) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(copy.sourceFailed)));
  }
}

class CompanyPanel extends StatelessWidget {
  const CompanyPanel({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      side: const BorderSide(color: AppTheme.surfaceLine)),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: const EdgeInsets.all(18), child: child));
}

class CompanyFailure extends StatelessWidget {
  const CompanyFailure({super.key, required this.error, required this.retry, this.back});
  final Object error;
  final VoidCallback retry;
  final VoidCallback? back;
  @override
  Widget build(BuildContext context) {
    final copy = CompanyStrings(Localizations.localeOf(context));
    final superseded = error is ApiException && (error as ApiException).code == 'report_superseded';
    return CompanyPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(superseded ? copy.superseded : copy.failed),
      const SizedBox(height: 12),
      Align(alignment: Alignment.centerLeft, child: OutlinedButton(
        onPressed: superseded && back != null ? back : retry,
        child: Text(superseded && back != null ? copy.back : copy.retry))),
    ]));
  }
}

class CompanyStatus extends StatelessWidget {
  const CompanyStatus({super.key, required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final copy = CompanyStrings(Localizations.localeOf(context));
    final color = status == 'complete' ? AppTheme.levelLow : AppTheme.levelNeutral;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(status == 'complete' ? Icons.check_circle_outline : Icons.info_outline, size: 16, color: color),
      const SizedBox(width: 6), Flexible(child: Text(copy.status(status), style: TextStyle(color: color, fontSize: 13))),
    ]);
  }
}

class CompanyTopicTile extends StatelessWidget {
  const CompanyTopicTile({super.key, required this.topic, required this.onTap});
  final CompanyTopic topic;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final copy = CompanyStrings(Localizations.localeOf(context));
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: const BorderSide(color: AppTheme.surfaceLine)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: AppTheme.tinted(ToolAccents.amber),
              child: const Icon(Icons.business_outlined, size: 22, color: ToolAccents.amber)),
            const SizedBox(width: 12),
            Expanded(child: Text(topic.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
            const Icon(Icons.chevron_right, color: AppTheme.ferryGreen),
          ]),
          const SizedBox(height: 12),
          Text(topic.explanation, style: const TextStyle(fontSize: 14, height: 1.5)),
          const SizedBox(height: 10),
          Text(copy.count(topic.count), style: const TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w600)),
        ]))),
    ));
  }
}

class CompanySourceTile extends StatelessWidget {
  const CompanySourceTile({super.key, required this.source});
  final CompanySource source;
  @override
  Widget build(BuildContext context) {
    final copy = CompanyStrings(Localizations.localeOf(context));
    return ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.description_outlined),
      title: Text(copy.dateRange(source.start, source.end), style: const TextStyle(fontSize: 13)),
      subtitle: Text(copy.fetched(source.fetchedAt), style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () => openCompanySource(context, source.url));
  }
}

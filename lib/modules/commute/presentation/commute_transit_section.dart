import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/hk_sail_mark.dart';
import '../data/commute_models.dart' hide Border;
import '../data/commute_providers.dart';
import '../theme/commute_theme.dart';
import 'commute_strings.dart';
import 'commute_widgets.dart';

class CommuteTransitSection extends ConsumerWidget {
  const CommuteTransitSection({super.key, required this.code});
  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = CommuteStrings(Localizations.localeOf(context));
    final preferences = ref.watch(commutePreferencesProvider);
    return CommuteSection(title: copy.transitTitle, subtitle: copy.transitNotice,
      icon: Icons.directions_transit_rounded,
      child: ref.watch(transitProvider(code)).when(
        data: (data) {
          final routes = [...data.routes];
          routes.sort((a, b) {
            final saved = (preferences.routes.contains(b.id) ? 1 : 0) -
                (preferences.routes.contains(a.id) ? 1 : 0);
            return saved != 0 ? saved : data.routes.indexOf(a).compareTo(data.routes.indexOf(b));
          });
          if (routes.isEmpty) return Text(copy.transitUnavailable);
          return Column(children: [for (final route in routes) _RouteCard(route: route, data: data)]);
        },
        error: (_, _) => CommuteFailure(retry: () => ref.invalidate(transitProvider(code))),
        loading: () => const HkSailLoader(),
      ));
  }
}

class _RouteCard extends ConsumerWidget {
  const _RouteCard({required this.route, required this.data});
  final TransitRoute route;
  final TransitData data;

  Future<void> _openMap(BuildContext context) async {
    var opened = false;
    try { opened = await launchUrl(route.mapUrl!, mode: LaunchMode.externalApplication); } catch (_) { /* Show stop name. */ }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(CommuteStrings(Localizations.localeOf(context)).mapFailed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = CommuteStrings(Localizations.localeOf(context));
    final fresh = data.fresh(route);
    final departures = route.departures.where((departure) => !departure.time.isBefore(data.now) &&
      departure.dataTime != null && data.now.difference(departure.dataTime!).inSeconds < 120).toList();
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 16),
      decoration: AppTheme.cardSurface(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _RouteHeader(route: route),
        const SizedBox(height: 10),
        if (route.delayed) Padding(padding: const EdgeInsets.only(bottom: 8),
          child: Text(copy.delay, style: const TextStyle(color: AppTheme.signalAmber))),
        if (!fresh || route.state == 'unavailable') Text(copy.transitUnavailable)
        else if (departures.isEmpty) Text(copy.noDepartures)
        else ...[for (final departure in departures) _DepartureRow(departure: departure)],
        if (route.fetchedAt != null) Padding(padding: const EdgeInsets.only(top: 8),
          child: Text(copy.fetched(route.fetchedAt!), style: Theme.of(context).textTheme.bodySmall)),
        if (route.mapUrl != null) Align(alignment: Alignment.centerLeft,
          child: TextButton.icon(onPressed: () => _openMap(context),
            icon: const Icon(Icons.place_outlined, size: 18), label: Text(copy.map))),
      ]),
    ));
  }
}

class _RouteHeader extends ConsumerWidget {
  const _RouteHeader({required this.route});
  final TransitRoute route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = CommuteStrings(Localizations.localeOf(context));
    final preferences = ref.watch(commutePreferencesProvider);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(top: 8, right: 10), child: Icon(
        route.mode == 'mtr' ? Icons.train_outlined : Icons.directions_bus_outlined,
        color: CommuteTheme.accent)),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text.rich(TextSpan(children: [
          TextSpan(text: '${copy.operatorName(route.operatorCode)}  ${route.route}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.ink)),
          TextSpan(text: '  ${route.stop}', style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: CommuteTheme.accent)),
        ])),
        Text(copy.destination(route.destination)),
      ])),
      FavoriteButton(saved: preferences.routes.contains(route.id),
        onPressed: preferences.busy ? null : () => savePreference(context,
          () => ref.read(commutePreferencesProvider.notifier).toggleRoute(route.id))),
    ]);
  }
}

class _DepartureRow extends StatelessWidget {
  const _DepartureRow({required this.departure});
  final TransitDeparture departure;

  @override
  Widget build(BuildContext context) {
    final copy = CommuteStrings(Localizations.localeOf(context));
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [
      Container(width: 64, padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: AppTheme.tinted(CommuteTheme.accent, radius: 12, alpha: 0.07),
        child: Text(copy.timeOnly(departure.time), style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700, color: CommuteTheme.accent))),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(copy.destination(departure.destination), style: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.ink)),
        if (departure.remark.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 3),
          child: Text(departure.remark, style: Theme.of(context).textTheme.bodySmall)),
      ])),
      if (departure.platform.isNotEmpty) Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: AppTheme.tinted(CommuteTheme.accent, radius: 10, alpha: 0.09),
        child: Text(copy.platform(departure.platform), style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: CommuteTheme.accent)),
      ),
    ]));
  }
}

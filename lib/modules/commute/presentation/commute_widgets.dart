import 'package:flutter/material.dart' hide Border;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../data/commute_models.dart';
import '../data/commute_providers.dart';
import 'commute_strings.dart';

Future<void> savePreference(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(CommuteStrings(Localizations.localeOf(context)).saveFailed)));
    }
  }
}

class AudiencePicker extends ConsumerWidget {
  const AudiencePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = CommuteStrings(Localizations.localeOf(context));
    final preferences = ref.watch(commutePreferencesProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 8, runSpacing: 4, children: [
        for (final audience in <String?>[null, 'resident', 'visitor']) ChoiceChip(
          label: Text(audience == null ? copy.both : copy.audience(audience)),
          selected: preferences.audience == audience,
          onSelected: preferences.busy ? null : (_) => savePreference(context,
            () => ref.read(commutePreferencesProvider.notifier).selectAudience(audience)),
        ),
      ]),
      const SizedBox(height: 6),
      Text(copy.audienceHint, style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}

Color queueColor(QueueStatus value, {String? reason}) => (reason ?? value.reason) != 'available'
    ? const Color(0xFF65788C) : switch (value.code) {
      0 => AppTheme.ferryGreen, 1 => AppTheme.signalAmber, _ => const Color(0xFFB23E37),
    };

class QueueBlock extends StatelessWidget {
  const QueueBlock({super.key, required this.queue, required this.audience, required this.now});
  final QueueStatus queue;
  final String audience;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final copy = CommuteStrings(Localizations.localeOf(context));
    final reason = queue.reasonAt(now);
    final color = queueColor(queue, reason: reason);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(copy.audience(audience), style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Row(children: [
          ExcludeSemantics(child: Icon(reason == 'available' ? Icons.circle : Icons.info_outline,
            size: 12, color: color)),
          const SizedBox(width: 7),
          Expanded(child: Text(copy.queueLabel(queue, reason: reason), style: TextStyle(
            color: color, fontWeight: FontWeight.w700, fontSize: 18))),
        ]),
        if (reason == 'available') Padding(padding: const EdgeInsets.only(top: 4),
          child: Text(copy.wait(queue.code!, audience))),
        if (queue.fetchedAt != null) Padding(padding: const EdgeInsets.only(top: 6),
          child: Text(copy.fetched(queue.fetchedAt!), style: Theme.of(context).textTheme.bodySmall)),
      ]),
    );
  }
}

class BorderQueues extends StatelessWidget {
  const BorderQueues({super.key, required this.border, required this.audience, required this.now});
  final Border border;
  final String? audience;
  final DateTime now;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    for (final group in audience == null ? ['resident', 'visitor'] : [audience!])
      QueueBlock(queue: border.queues[group]!, audience: group, now: now),
  ]);
}

class CommuteSection extends StatelessWidget {
  const CommuteSection({super.key, required this.title, required this.child, this.subtitle});
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Semantics(header: true, child: Text(title, style: const TextStyle(
        color: AppTheme.ink, fontSize: 20, fontWeight: FontWeight.w700))),
      if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 6),
        child: Text(subtitle!, style: Theme.of(context).textTheme.bodySmall)),
      const SizedBox(height: 12),
      child,
    ]),
  );
}

class CommuteFailure extends StatelessWidget {
  const CommuteFailure({super.key, required this.retry});
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    final copy = CommuteStrings(Localizations.localeOf(context));
    return Padding(padding: const EdgeInsets.symmetric(vertical: 18), child: Column(children: [
      const Icon(Icons.cloud_off_outlined, color: AppTheme.harborBlue, size: 28),
      const SizedBox(height: 8),
      Text(copy.loadFailed, textAlign: TextAlign.center),
      TextButton.icon(onPressed: retry, icon: const Icon(Icons.refresh), label: Text(copy.retry)),
    ]));
  }
}

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.saved, required this.onPressed});
  final bool saved;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final copy = CommuteStrings(Localizations.localeOf(context));
    return IconButton(tooltip: saved ? copy.unfavorite : copy.favorite,
      onPressed: onPressed, color: AppTheme.harborBlue,
      icon: Icon(saved ? Icons.star_rounded : Icons.star_outline_rounded));
  }
}

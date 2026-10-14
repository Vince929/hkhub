import 'package:flutter/material.dart' hide Border;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../data/commute_models.dart';
import '../data/commute_providers.dart';
import '../theme/commute_theme.dart';
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

Color queueColor(QueueStatus value, {String? reason}) => (reason ?? value.reason) != 'available'
    ? AppTheme.levelNeutral : switch (value.code) {
      0 => AppTheme.levelLow, 1 => AppTheme.levelMedium, _ => AppTheme.levelHigh,
    };

/// Soft accent hero, the same anchor the residency card opens with.
class CommuteHeroCard extends StatelessWidget {
  const CommuteHeroCard({super.key, required this.title, this.tags = const []});
  final String title;
  final List<String> tags;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: ShapeDecoration(
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [CommuteTheme.tintTop, CommuteTheme.tintBottom]),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: CommuteTheme.tintLine),
        borderRadius: BorderRadius.circular(26),
      ),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: AppTheme.ink, fontSize: 26,
        fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.5)),
      if (tags.isNotEmpty) ...[
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final tag in tags) Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: AppTheme.tinted(CommuteTheme.accent, radius: 12, alpha: 0.08),
            child: Text(tag, style: const TextStyle(color: CommuteTheme.accent,
              fontSize: 12, fontWeight: FontWeight.w600))),
        ]),
      ],
    ]),
  );
}

class QueueLevelChip extends StatelessWidget {
  const QueueLevelChip({super.key, required this.queue, required this.now});
  final QueueStatus queue;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final copy = CommuteStrings(Localizations.localeOf(context));
    final reason = queue.reasonAt(now);
    final color = queueColor(queue, reason: reason);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: AppTheme.tinted(color, radius: 11, alpha: 0.12),
      child: Text(copy.queueLabel(queue, reason: reason), style: TextStyle(
        color: color, fontSize: 15, fontWeight: FontWeight.w700)),
    );
  }
}

class QueueBlock extends StatelessWidget {
  const QueueBlock({super.key, required this.queue, required this.direction, required this.now});
  final QueueStatus queue;
  final String direction;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final copy = CommuteStrings(Localizations.localeOf(context));
    final reason = queue.reasonAt(now);
    final accent = direction == 'arrival' ? CommuteTheme.accentDeep : CommuteTheme.accent;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
        decoration: AppTheme.tinted(accent, radius: 16, alpha: 0.07),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ExcludeSemantics(child: Icon(
              direction == 'arrival' ? Icons.login_rounded : Icons.logout_rounded,
              size: 17, color: accent)),
            const SizedBox(width: 7),
            Expanded(child: Text(copy.directionName(direction), style: TextStyle(
              color: accent, fontSize: 16, fontWeight: FontWeight.w800))),
          ]),
          const SizedBox(height: 9),
          Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 10,
            runSpacing: 6, children: [
              QueueLevelChip(queue: queue, now: now),
              if (reason == 'available')
                Text(copy.wait(queue.code!), style: Theme.of(context).textTheme.bodySmall),
            ]),
          if (queue.fetchedAt != null) Padding(padding: const EdgeInsets.only(top: 8),
            child: Text(copy.fetched(queue.fetchedAt!), style: Theme.of(context).textTheme.bodySmall)),
        ]),
      ),
    );
  }
}

class BorderQueues extends StatelessWidget {
  const BorderQueues({super.key, required this.border, required this.now});
  final Border border;
  final DateTime now;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    for (final direction in directions)
      QueueBlock(queue: border.queues[direction]!, direction: direction, now: now),
  ]);
}

class CommuteSection extends StatelessWidget {
  const CommuteSection({super.key, required this.title, required this.icon, required this.child,
    this.subtitle});
  final String title;
  final IconData icon;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Container(width: 38, height: 38,
          decoration: AppTheme.tinted(CommuteTheme.accent, radius: 12, alpha: 0.09),
          child: Icon(icon, size: 21, color: CommuteTheme.accent)),
        const SizedBox(width: 12),
        Expanded(child: Semantics(header: true, child: Text(title, style: const TextStyle(
          color: AppTheme.ink, fontSize: 18, fontWeight: FontWeight.w700)))),
      ]),
      if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 8),
        child: Text(subtitle!, style: Theme.of(context).textTheme.bodySmall)),
      const SizedBox(height: 14),
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
      const Icon(Icons.cloud_off_outlined, color: CommuteTheme.accent, size: 28),
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
      onPressed: onPressed, color: CommuteTheme.accent,
      icon: Icon(saved ? Icons.star_rounded : Icons.star_outline_rounded));
  }
}

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../data/residency_calculator.dart';
import '../data/residency_models.dart';
import '../theme/residency_theme.dart';
import 'residency_strings.dart';

/// The shareable journey card (D6, D21 v3). Rendered locally: nothing is
/// uploaded, and the card is only produced when the user asks for it.
class ResidencyShareCard extends StatelessWidget {
  const ResidencyShareCard({
    super.key,
    required this.progress,
    required this.strings,
    this.latest,
  });

  final ResidencyProgress progress;
  final ResidencyStrings strings;
  final Milestone? latest;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: ResidencyTheme.cardGradient,
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 40, height: 40, alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.event_note_rounded, color: Colors.white, size: 23),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(strings.shareTitle, style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white))),
          ]),
          const SizedBox(height: 22),
          Text(strings.elapsedPrefix, style: const TextStyle(fontSize: 12, color: ResidencyTheme.cardSubtle)),
          const SizedBox(height: 4),
          Text(strings.elapsed(progress.elapsedYears, progress.elapsedMonths),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700,
              color: Colors.white, height: 1.15, letterSpacing: -0.5)),
          const SizedBox(height: 12),
          Text(
            progress.reached ? strings.reachedNotice : strings.remainingDays(progress.remainingDays),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: ResidencyTheme.cardHighlight),
          ),
          const SizedBox(height: 16),
          ClipRRect(borderRadius: BorderRadius.circular(5), child: LinearProgressIndicator(
            value: progress.fraction, minHeight: 8,
            color: ResidencyTheme.cardBar,
            backgroundColor: Colors.white.withValues(alpha: 0.20),
          )),
          const SizedBox(height: 16),
          if (latest != null) Row(children: [
            const Icon(Icons.workspace_premium_rounded, size: 17, color: ResidencyTheme.cardHighlight),
            const SizedBox(width: 7),
            Expanded(child: Text(_label(latest!), style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
          ]),
          const SizedBox(height: 14),
          Text(strings.startedOn(_iso(progress.startDate)),
            style: const TextStyle(fontSize: 11.5, color: ResidencyTheme.cardSubtle)),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withValues(alpha: 0.16), height: 1),
          const SizedBox(height: 10),
          Text(strings.shareTagline,
            style: const TextStyle(fontSize: 11, color: ResidencyTheme.cardSubtle)),
        ],
      ),
    );
  }

  String _label(Milestone milestone) => milestone.kind == MilestoneKind.year
      ? strings.yearLabel(milestone.index)
      : strings.monthLabel(milestone.index);

  static String _iso(DateTime date) => '${date.year.toString().padLeft(4, '0')}'
      '-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// Shows a preview and shares the card as a PNG. No upload, no server call.
Future<void> showResidencyShareSheet({
  required BuildContext context,
  required ResidencyStrings strings,
  required ResidencyProgress progress,
  Milestone? latest,
}) async {
  final boundaryKey = GlobalKey();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (sheetContext) => Theme(
      data: ResidencyTheme.apply(Theme.of(sheetContext)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          color: Theme.of(sheetContext).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(strings.sharePreviewTitle, style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700, color: ResidencyTheme.ink)),
              const SizedBox(height: 16),
              Center(child: RepaintBoundary(
                key: boundaryKey,
                child: ResidencyShareCard(progress: progress, strings: strings, latest: latest),
              )),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => _shareCard(sheetContext, boundaryKey, strings),
                icon: const Icon(Icons.ios_share_rounded, size: 20),
                label: Text(strings.shareAction),
              ),
            ]),
        ),
      ),
    ),
  );
}

Future<void> _shareCard(BuildContext context, GlobalKey boundaryKey, ResidencyStrings strings) async {
  // Resolve the popover source rect before any await (iPad needs it).
  final box = context.findRenderObject();
  final origin = box is RenderBox ? box.localToGlobal(Offset.zero) & box.size : null;
  try {
    await WidgetsBinding.instance.endOfFrame;
    final renderObject = boundaryKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) throw StateError('Share card is not ready');
    final image = await renderObject.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (data == null) throw StateError('Could not encode the share card');
    final bytes = data.buffer.asUint8List();
    await SharePlus.instance.share(ShareParams(
      files: [XFile.fromData(bytes, mimeType: 'image/png', name: 'residency-journey.png')],
      fileNameOverrides: const ['residency-journey.png'],
      sharePositionOrigin: origin,
    ));
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(strings.shareFailed)));
  }
}

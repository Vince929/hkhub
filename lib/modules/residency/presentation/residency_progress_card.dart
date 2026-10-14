import 'package:flutter/material.dart';

import '../data/residency_calculator.dart';
import '../theme/residency_theme.dart';
import 'residency_strings.dart';

/// The hero card: elapsed time, the countdown, and the progress bar.
///
/// Progress is pure calendar time; departure marks never appear here.
/// The card uses a mid-tone plum: strong enough to stand out from the white
/// sections below, light enough not to read as a dark block.
class ResidencyProgressCard extends StatelessWidget {
  const ResidencyProgressCard({
    super.key,
    required this.progress,
    required this.strings,
    required this.showMonths,
    required this.onToggleUnit,
    this.visaExpiry,
    this.visaExpiryDate,
  });

  final ResidencyProgress progress;
  final ResidencyStrings strings;
  final bool showMonths;
  final VoidCallback onToggleUnit;
  final RenewalStatus? visaExpiry;
  final String? visaExpiryDate;

  static const _highlight = ResidencyTheme.cardHighlight;
  static const _barFill = ResidencyTheme.cardBar;
  static const _subtle = ResidencyTheme.cardSubtle;

  @override
  Widget build(BuildContext context) {
    final remaining = showMonths ? _remainingMonths() : progress.remainingDays;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: ResidencyTheme.cardGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(color: ResidencyTheme.plum.withValues(alpha: 0.22),
            blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40, height: 40, alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.event_note_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(strings.title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700))),
          _unitToggle(),
        ]),
        const SizedBox(height: 22),
        Text(strings.elapsedPrefix, style: const TextStyle(
          color: _subtle, fontSize: 13)),
        const SizedBox(height: 4),
        Text(strings.elapsed(progress.elapsedYears, progress.elapsedMonths),
          style: const TextStyle(color: Colors.white, fontSize: 30,
            fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -0.6)),
        const SizedBox(height: 14),
        if (progress.reached)
          Text(strings.reachedNotice, style: const TextStyle(
            color: _highlight, fontSize: 15, height: 1.5, fontWeight: FontWeight.w600))
        else ...[
          Text(strings.remainingPrefix, style: const TextStyle(
            color: _subtle, fontSize: 13)),
          const SizedBox(height: 4),
          Text(showMonths ? strings.remainingMonths(remaining) : strings.remainingDays(remaining),
            style: const TextStyle(color: _highlight, fontSize: 26,
              fontWeight: FontWeight.w700, letterSpacing: -0.4)),
        ],
        const SizedBox(height: 18),
        ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(
          value: progress.fraction, minHeight: 8,
          color: _barFill,
          backgroundColor: Colors.white.withValues(alpha: 0.20),
          semanticsLabel: strings.elapsed(progress.elapsedYears, progress.elapsedMonths),
          semanticsValue: '${(progress.fraction * 100).round()}%',
        )),
        const SizedBox(height: 14),
        Divider(color: Colors.white.withValues(alpha: 0.16), height: 1),
        const SizedBox(height: 10),
        _fact(Icons.flag_outlined, strings.startedOn(_iso(progress.startDate))),
        const SizedBox(height: 8),
        _fact(Icons.event_available_outlined, strings.targetOn(_iso(progress.targetDate))),
        if (visaExpiry != null && visaExpiryDate != null) ...[
          const SizedBox(height: 8),
          _fact(Icons.badge_outlined, strings.visaExpiry(visaExpiryDate!, visaExpiry!.daysRemaining)),
        ],
      ]),
    );
  }

  int _remainingMonths() {
    final calendar = calendarElapsed(progress.today, progress.targetDate);
    return calendar.years * 12 + calendar.months;
  }

  Widget _unitToggle() {
    Widget chip(String label, bool selected) => Padding(
      padding: const EdgeInsets.only(left: 6),
      child: GestureDetector(
        onTap: selected ? null : onToggleUnit,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label, style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: selected ? ResidencyTheme.plum : Colors.white,
          )),
        ),
      ),
    );
    return Row(mainAxisSize: MainAxisSize.min, children: [
      chip(strings.showDays, !showMonths),
      chip(strings.showMonths, showMonths),
    ]);
  }

  Widget _fact(IconData icon, String text) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 15, color: Colors.white.withValues(alpha: 0.70)),
    const SizedBox(width: 8),
    Expanded(child: Text(text, style: TextStyle(
      color: Colors.white.withValues(alpha: 0.88), fontSize: 12.5, height: 1.4))),
  ]);

  static String _iso(DateTime date) => '${date.year.toString().padLeft(4, '0')}'
      '-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../../app/localization/locale_controller.dart';
import '../data/residency_calculator.dart';
import '../data/residency_models.dart';
import '../data/residency_providers.dart';
import '../theme/residency_theme.dart';
import 'residency_departure_section.dart';
import 'residency_progress_card.dart';
import 'residency_renewal_section.dart';
import 'residency_setup_form.dart';
import 'residency_share_card.dart';
import 'residency_strings.dart';
import 'residency_timeline.dart';

class ResidencyScreen extends ConsumerStatefulWidget {
  const ResidencyScreen({super.key});

  @override
  ConsumerState<ResidencyScreen> createState() => _ResidencyScreenState();
}

class _ResidencyScreenState extends ConsumerState<ResidencyScreen> {
  bool _editing = false;
  bool _showMonths = false;
  Milestone? _crossed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _acknowledgeCrossed());
  }

  /// Shows the "you crossed" banner once per newly reached node (D10), then
  /// advances the acknowledged count so it does not reappear on every open.
  void _acknowledgeCrossed() {
    if (!mounted) return;
    final profile = ref.read(residencyControllerProvider).profile;
    final window = _windowFor(profile);
    if (window == null || window.achievedCount <= profile.seenMilestoneCount) return;
    setState(() => _crossed = window.achieved.last);
    ref.read(residencyControllerProvider.notifier).save(
      profile.copyWith(seenMilestoneCount: window.achievedCount),
    ).catchError((_) {});
  }

  MilestoneWindow? _windowFor(ResidencyProfile profile) {
    final startText = profile.startDate;
    if (startText == null) return null;
    final start = DateTime.tryParse(startText);
    if (start == null) return null;
    return buildMilestoneWindow(buildMilestones(start), ref.read(residencyTodayProvider));
  }

  /// Saves the profile and resyncs the acknowledged count for its start date so
  /// setting up or editing never triggers a "crossed" banner (D20).
  Future<void> _persistProfile(ResidencyProfile profile) async {
    var seen = profile.seenMilestoneCount;
    final startText = profile.startDate;
    if (startText != null) {
      final start = DateTime.tryParse(startText);
      if (start != null) {
        seen = buildMilestoneWindow(buildMilestones(start), ref.read(residencyTodayProvider))
            .achievedCount;
      }
    }
    final saved = await _saveProfile(profile.copyWith(seenMilestoneCount: seen));
    if (saved && mounted) setState(() { _editing = false; _crossed = null; });
  }

  /// Persists without touching edit/banner state (used by departure edits).
  Future<bool> _saveProfile(ResidencyProfile profile) async {
    try {
      await ref.read(residencyControllerProvider.notifier).save(profile);
      return true;
    } catch (_) {
      _showSaveFailure();
      return false;
    }
  }

  Future<void> _onSubmitted(ResidencyProfile profile, ResidencyStrings strings) async {
    final current = ref.read(residencyControllerProvider).profile;
    if (profile.startDate != current.startDate) {
      final confirmed = await _confirm(strings.changeConfirm, strings.confirm, strings.cancel);
      if (confirmed != true || !mounted) return;
    }
    await _persistProfile(profile);
  }

  Future<void> _clear(ResidencyStrings strings) async {
    final confirmed = await _confirm(strings.clearQuestion, strings.clear, strings.cancel, danger: true);
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(residencyControllerProvider.notifier).clear();
      if (mounted) setState(() { _editing = false; _crossed = null; });
    } catch (_) {
      _showSaveFailure();
    }
  }

  Future<void> _editDeparture(int? index, ResidencyStrings strings) async {
    final profile = ref.read(residencyControllerProvider).profile;
    final initial = index == null ? null : profile.departures[index];
    final result = await showModalBottomSheet<DepartureMark>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      useSafeArea: true, requestFocus: false,
      builder: (sheetContext) => ResidencyDepartureForm(
        initial: initial, today: ref.read(residencyTodayProvider), strings: strings),
    );
    if (result == null || !mounted) return;
    final marks = [...profile.departures];
    if (index == null) {
      marks.add(result);
    } else {
      marks[index] = result;
    }
    await _saveProfile(profile.copyWith(departures: List<DepartureMark>.unmodifiable(marks)));
  }

  Future<void> _removeDeparture(int index, ResidencyStrings strings) async {
    final confirmed = await _confirm(
      strings.departureRemoveQuestion, strings.departureDelete, strings.cancel, danger: true);
    if (confirmed != true || !mounted) return;
    final profile = ref.read(residencyControllerProvider).profile;
    if (index < 0 || index >= profile.departures.length) return;
    final marks = [...profile.departures]..removeAt(index);
    await _saveProfile(profile.copyWith(departures: List<DepartureMark>.unmodifiable(marks)));
  }

  Future<bool?> _confirm(String message, String confirmLabel, String cancelLabel,
      {bool danger = false}) {
    return showDialog<bool>(
      context: context, requestFocus: false,
      builder: (dialogContext) => TDAlertDialog(
        title: message, radius: 24,
        buttonStyle: TDDialogButtonStyle.normal,
        leftBtn: TDDialogButtonOptions(title: cancelLabel,
          action: () => Navigator.of(dialogContext).pop(false)),
        rightBtn: TDDialogButtonOptions(title: confirmLabel,
          theme: danger ? TDButtonTheme.danger : TDButtonTheme.primary,
          action: () => Navigator.of(dialogContext).pop(true)),
      ),
    );
  }

  void _showSaveFailure() {
    if (!mounted) return;
    final strings = ResidencyStrings(ref.read(effectiveLocaleProvider));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(strings.saveFailed)));
  }

  @override
  Widget build(BuildContext context) {
    final strings = ResidencyStrings(ref.watch(effectiveLocaleProvider));
    final state = ref.watch(residencyControllerProvider);
    final today = ref.watch(residencyTodayProvider);
    final profile = state.profile;

    ref.listen(residencyControllerProvider, (previous, next) {
      if (previous?.profile.startDate != next.profile.startDate) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _acknowledgeCrossed());
      }
    });

    return Theme(
      data: ResidencyTheme.apply(Theme.of(context)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(strings.title),
          leading: Navigator.of(context).canPop()
              ? Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white, foregroundColor: ResidencyTheme.ink),
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    icon: const Icon(Icons.arrow_back_rounded, size: 20),
                  ),
                )
              : null,
          actions: [
            if (profile.isConfigured)
              IconButton(
                onPressed: state.busy ? null : () => setState(() {
                  _editing = !_editing;
                  _crossed = null;
                }),
                tooltip: _editing ? strings.cancel : strings.settingsTitle,
                icon: Icon(_editing ? Icons.close_rounded : Icons.tune_rounded, size: 21),
              ),
            if (profile.isConfigured)
              IconButton(
                onPressed: state.busy ? null : () => _clear(strings),
                tooltip: strings.clear,
                icon: const Icon(Icons.delete_outline_rounded, size: 21),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Center(child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: _body(strings, profile, today, state.busy),
          )),
        )),
      ),
    );
  }

  Widget _body(ResidencyStrings strings, ResidencyProfile profile, DateTime today, bool busy) {
    if (!profile.isConfigured || _editing) {
      return ResidencySetupForm(
        key: ValueKey('residency-setup-${profile.startDate}'),
        initialProfile: profile,
        today: today,
        busy: busy,
        strings: strings,
        onSubmit: (value) { _onSubmitted(value, strings); },
        onCancel: _editing ? () => setState(() => _editing = false) : null,
      );
    }

    final start = DateTime.parse(profile.startDate!);
    final progress = computeResidencyProgress(startDate: start, today: today);
    final window = buildMilestoneWindow(buildMilestones(start), today);
    final expiryText = profile.visaExpiryDate;
    final expiry = expiryText == null ? null : DateTime.tryParse(expiryText);
    final renewal = expiry == null ? null : renewalStatus(expiryDate: expiry, today: today);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (_crossed != null) ...[
        _crossedBanner(strings, _crossed!),
        const SizedBox(height: 14),
      ],
      ResidencyProgressCard(
        progress: progress,
        strings: strings,
        showMonths: _showMonths,
        onToggleUnit: () => setState(() => _showMonths = !_showMonths),
        visaExpiry: renewal,
        visaExpiryDate: expiryText,
      ),
      const SizedBox(height: 16),
      ResidencyTimeline(window: window, strings: strings),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () => showResidencyShareSheet(
          context: context,
          strings: strings,
          progress: progress,
          latest: window.achieved.isEmpty ? null : window.achieved.last,
        ),
        icon: const Icon(Icons.ios_share_rounded, size: 19),
        label: Text(strings.shareCard),
      ),
      if (renewal != null && expiryText != null) ...[
        const SizedBox(height: 16),
        ResidencyRenewalSection(status: renewal, visaType: profile.visaType, strings: strings),
      ],
      const SizedBox(height: 16),
      ResidencyDepartureSection(
        departures: profile.departures,
        strings: strings,
        today: today,
        onAdd: () { _editDeparture(null, strings); },
        onEdit: (index) { _editDeparture(index, strings); },
        onRemove: (index) { _removeDeparture(index, strings); },
      ),
      const SizedBox(height: 18),
      _footerNotice(strings),
    ]);
  }

  Widget _crossedBanner(ResidencyStrings strings, Milestone milestone) {
    final label = milestone.kind == MilestoneKind.year
        ? strings.yearLabel(milestone.index)
        : strings.monthLabel(milestone.index);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: ResidencyTheme.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ResidencyTheme.gold.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.celebration_rounded, size: 20, color: ResidencyTheme.gold),
        const SizedBox(width: 10),
        Expanded(child: Text(strings.crossed(label), style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: ResidencyTheme.ink))),
        IconButton(
          onPressed: () => setState(() => _crossed = null),
          tooltip: strings.cancel,
          icon: const Icon(Icons.close_rounded, size: 18, color: ResidencyTheme.muted),
        ),
      ]),
    );
  }

  Widget _footerNotice(ResidencyStrings strings) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: ResidencyTheme.line),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.gavel_rounded, size: 18, color: ResidencyTheme.muted),
        const SizedBox(width: 10),
        Expanded(child: Text(strings.boundaryNotice, style: const TextStyle(
          fontSize: 12, height: 1.6, color: ResidencyTheme.muted))),
      ]),
      const SizedBox(height: 10),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.lock_outline_rounded, size: 18, color: ResidencyTheme.muted),
        const SizedBox(width: 10),
        Expanded(child: Text(strings.localOnlyNotice, style: const TextStyle(
          fontSize: 12, height: 1.6, color: ResidencyTheme.muted))),
      ]),
    ]),
  );
}

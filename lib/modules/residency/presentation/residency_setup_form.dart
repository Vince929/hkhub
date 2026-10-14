import 'package:flutter/material.dart';

import '../../../app/widgets/hk_date_field.dart';
import '../../../app/widgets/hk_selection_field.dart';
import '../data/residency_models.dart';
import '../theme/residency_theme.dart';
import 'residency_strings.dart';

/// First-run setup and profile editing share this form (D16, D20).
class ResidencySetupForm extends StatefulWidget {
  const ResidencySetupForm({
    super.key,
    required this.initialProfile,
    required this.today,
    required this.busy,
    required this.strings,
    required this.onSubmit,
    this.onCancel,
  });

  final ResidencyProfile initialProfile;
  final DateTime today;
  final bool busy;
  final ResidencyStrings strings;
  final ValueChanged<ResidencyProfile> onSubmit;
  final VoidCallback? onCancel;

  @override
  State<ResidencySetupForm> createState() => _ResidencySetupFormState();
}

class _ResidencySetupFormState extends State<ResidencySetupForm> {
  String? _startDate;
  String _visaType = 'none';
  String? _visaExpiry;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialProfile.startDate;
    _visaType = widget.initialProfile.visaType ?? 'none';
    _visaExpiry = widget.initialProfile.visaExpiryDate;
  }

  void _submit() {
    final strings = widget.strings;
    final startText = _startDate;
    if (startText == null) {
      setState(() => _error = strings.dateRequired);
      return;
    }
    final start = DateTime.tryParse(startText);
    if (start == null || start.isAfter(widget.today)) {
      setState(() => _error = strings.dateInFuture);
      return;
    }
    final expiryText = _visaExpiry;
    if (expiryText != null) {
      final expiry = DateTime.tryParse(expiryText);
      if (expiry != null && expiry.isBefore(start)) {
        setState(() => _error = strings.dateOrderError);
        return;
      }
    }
    setState(() => _error = null);
    FocusScope.of(context).unfocus();
    widget.onSubmit(ResidencyProfile(
      startDate: startText,
      visaType: _visaType == 'none' ? null : _visaType,
      visaExpiryDate: expiryText,
      seenMilestoneCount: widget.initialProfile.seenMilestoneCount,
      departures: widget.initialProfile.departures,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.strings;
    final busy = widget.busy;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _hero(strings),
      const SizedBox(height: 22),
      _section(strings, children: [
        _label(strings.startDateLabel, HkDateField(
          label: strings.startDateLabel,
          value: _startDate,
          hint: strings.startDateHint,
          lastDate: widget.today,
          enabled: !busy,
          onChanged: (value) => setState(() { _startDate = value; _error = null; }),
        )),
        _label(strings.visaTypeLabel, HkSelectionField(
          label: strings.visaTypeLabel,
          value: _visaType,
          enabled: !busy,
          items: {for (final key in residencyVisaTypes) key: strings.visaName(key)},
          onChanged: (value) => setState(() => _visaType = value),
        )),
        _label(strings.visaExpiryLabel, HkDateField(
          label: strings.visaExpiryLabel,
          value: _visaExpiry,
          hint: strings.optional,
          enabled: !busy,
          onClear: () => setState(() { _visaExpiry = null; _error = null; }),
          onChanged: (value) => setState(() { _visaExpiry = value; _error = null; }),
        )),
      ]),
      if (_error != null) Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.error_outline_rounded, size: 18, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          Expanded(child: Text(_error!, style: TextStyle(
            color: Theme.of(context).colorScheme.error, fontSize: 13, height: 1.4))),
        ]),
      ),
      FilledButton.icon(
        onPressed: busy ? null : _submit,
        icon: const Icon(Icons.play_arrow_rounded, size: 22),
        label: Text(strings.startAction),
      ),
      if (widget.onCancel != null) ...[
        const SizedBox(height: 6),
        TextButton(onPressed: busy ? null : widget.onCancel, child: Text(strings.cancel)),
      ],
      const SizedBox(height: 18),
      _notice(Icons.lock_outline_rounded, strings.localOnlyNotice),
      const SizedBox(height: 10),
      _notice(Icons.gavel_rounded, strings.boundaryNotice),
    ]);
  }

  Widget _hero(ResidencyStrings strings) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: ResidencyTheme.plum, borderRadius: BorderRadius.circular(28)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.event_note_rounded, color: Colors.white, size: 27),
      ),
      const SizedBox(height: 20),
      Text(strings.setupHeadline, style: const TextStyle(color: Colors.white,
        fontSize: 28, fontWeight: FontWeight.w700, height: 1.3, letterSpacing: -0.6)),
      const SizedBox(height: 12),
      Text(strings.setupSubtitle, style: const TextStyle(
        color: Color(0xFFE4E0F5), fontSize: 14, height: 1.6)),
    ]),
  );

  Widget _section(ResidencyStrings strings, {required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
      border: Border.all(color: ResidencyTheme.line)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
  );

  Widget _label(String text, Widget child) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(text, style: const TextStyle(
        fontSize: 13, fontWeight: FontWeight.w600, color: ResidencyTheme.ink)),
      const SizedBox(height: 8),
      child,
    ]),
  );

  Widget _notice(IconData icon, String text) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
      border: Border.all(color: ResidencyTheme.line)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: ResidencyTheme.muted),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: const TextStyle(
        fontSize: 12, height: 1.6, color: ResidencyTheme.muted))),
    ]),
  );
}

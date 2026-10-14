import 'package:flutter/material.dart';

import '../../../app/widgets/hk_date_field.dart';
import '../data/residency_calculator.dart';
import '../data/residency_models.dart';
import '../theme/residency_theme.dart';
import 'residency_strings.dart';

/// Optional departure marks. They are advisory only: nothing here changes the
/// computed progress (D8).
class ResidencyDepartureSection extends StatelessWidget {
  const ResidencyDepartureSection({
    super.key,
    required this.departures,
    required this.strings,
    required this.today,
    required this.onAdd,
    required this.onEdit,
    required this.onRemove,
  });

  final List<DepartureMark> departures;
  final ResidencyStrings strings;
  final DateTime today;
  final VoidCallback onAdd;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final hasLong = hasLongDeparture(departures, today);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ResidencyTheme.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Icon(Icons.flight_takeoff_rounded, size: 20, color: ResidencyTheme.plum),
          const SizedBox(width: 9),
          Expanded(child: Text(strings.departureTitle, style: const TextStyle(
            fontSize: 17, fontWeight: FontWeight.w700, color: ResidencyTheme.ink))),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(strings.departureAdd, style: const TextStyle(fontSize: 12)),
          ),
        ]),
        if (departures.isEmpty)
          Text(strings.departureEmpty, style: const TextStyle(
            fontSize: 13, color: ResidencyTheme.muted))
        else
          for (var index = 0; index < departures.length; index++)
            _row(index, departures[index]),
        if (hasLong) ...[
          const SizedBox(height: 12),
          _note(strings.departureLongNote, ResidencyTheme.gold, ResidencyTheme.ink),
        ],
        const SizedBox(height: 12),
        _note(strings.departureAdvisory, ResidencyTheme.muted, ResidencyTheme.muted),
      ]),
    );
  }

  Widget _row(int index, DepartureMark mark) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(strings.departurePeriod(mark.startDate, mark.endDate),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ResidencyTheme.ink)),
        if (mark.endDate == null) Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(strings.departureOngoing, style: const TextStyle(
            fontSize: 11.5, fontWeight: FontWeight.w600, color: ResidencyTheme.gold)),
        ),
      ])),
      IconButton(
        onPressed: () => onEdit(index),
        tooltip: strings.departureEdit,
        icon: const Icon(Icons.edit_outlined, size: 19, color: ResidencyTheme.muted),
      ),
      IconButton(
        onPressed: () => onRemove(index),
        tooltip: strings.departureDelete,
        icon: const Icon(Icons.delete_outline_rounded, size: 19, color: ResidencyTheme.muted),
      ),
    ]),
  );

  Widget _note(String text, Color accent, Color textColor) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: accent.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.info_outline_rounded, size: 16, color: accent),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: TextStyle(fontSize: 12, height: 1.6, color: textColor))),
    ]),
  );
}

/// Bottom-sheet form for adding or editing one period away.
class ResidencyDepartureForm extends StatefulWidget {
  const ResidencyDepartureForm({
    super.key,
    required this.initial,
    required this.today,
    required this.strings,
  });

  final DepartureMark? initial;
  final DateTime today;
  final ResidencyStrings strings;

  @override
  State<ResidencyDepartureForm> createState() => _ResidencyDepartureFormState();
}

class _ResidencyDepartureFormState extends State<ResidencyDepartureForm> {
  String? _start;
  String? _end;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start = widget.initial?.startDate;
    _end = widget.initial?.endDate;
  }

  void _submit() {
    final strings = widget.strings;
    final start = _start;
    if (start == null) {
      setState(() => _error = strings.dateRequired);
      return;
    }
    final end = _end;
    if (end != null) {
      final startDate = DateTime.tryParse(start);
      final endDate = DateTime.tryParse(end);
      if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
        setState(() => _error = strings.departureRangeError);
        return;
      }
    }
    Navigator.of(context).pop(DepartureMark(startDate: start, endDate: end));
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.strings;
    return Theme(
      data: ResidencyTheme.apply(Theme.of(context)),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(strings.departureSheetTitle, style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700, color: ResidencyTheme.ink)),
                const SizedBox(height: 16),
                _label(strings.departureStartLabel),
                HkDateField(
                  label: strings.departureStartLabel,
                  value: _start,
                  hint: strings.startDateHint,
                  lastDate: widget.today,
                  onChanged: (value) => setState(() { _start = value; _error = null; }),
                ),
                const SizedBox(height: 16),
                _label(strings.departureEndLabel),
                HkDateField(
                  label: strings.departureEndLabel,
                  value: _end,
                  hint: strings.optional,
                  onClear: () => setState(() { _end = null; _error = null; }),
                  onChanged: (value) => setState(() { _end = value; _error = null; }),
                ),
                if (_error != null) Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error!, style: TextStyle(
                    fontSize: 13, height: 1.4, color: Theme.of(context).colorScheme.error)),
                ),
                const SizedBox(height: 18),
                FilledButton(onPressed: _submit, child: Text(strings.save)),
              ]),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(
      fontSize: 13, fontWeight: FontWeight.w600, color: ResidencyTheme.ink)),
  );
}

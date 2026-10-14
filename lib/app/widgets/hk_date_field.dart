import 'package:flutter/material.dart';

/// A themed date selector matching [HkSelectionField]'s look: it shows the
/// chosen ISO date (or a hint) and opens a Material date picker without
/// raising the software keyboard.
class HkDateField extends StatelessWidget {
  const HkDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.hint,
    this.onClear,
    this.enabled = true,
  });

  final String label;

  /// Chosen date as 'YYYY-MM-DD', or null when unset.
  final String? value;
  final ValueChanged<String> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? hint;

  /// When provided and a date is set, shows a clear affordance.
  final VoidCallback? onClear;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = value ?? hint ?? '';
    final hasValue = value != null;
    final fill = theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface;
    return Semantics(
      label: label,
      value: display,
      button: true,
      enabled: enabled,
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? () => _open(context) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            child: Row(children: [
              Expanded(child: Text(display, style: TextStyle(
                fontSize: 15,
                color: hasValue ? theme.colorScheme.onSurface : theme.hintColor,
              ))),
              if (hasValue && onClear != null)
                GestureDetector(
                  onTap: enabled ? onClear : null,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(Icons.close_rounded, size: 18, color: theme.hintColor),
                  ),
                ),
              Icon(Icons.calendar_today_rounded, size: 18, color: theme.hintColor),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    if (!enabled) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final material = MaterialLocalizations.of(context);
    final now = DateTime.now();
    final first = firstDate ?? DateTime(now.year - 20);
    final last = lastDate ?? DateTime(now.year + 30, 12, 31);
    final initial = value != null ? (DateTime.tryParse(value!) ?? now) : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : (initial.isAfter(last) ? last : initial),
      firstDate: first,
      lastDate: last,
      helpText: label,
      cancelText: material.cancelButtonLabel,
      confirmText: material.okButtonLabel,
    );
    if (picked == null) return;
    onChanged(_format(picked));
  }

  static String _format(DateTime date) => '${date.year.toString().padLeft(4, '0')}'
      '-${date.month.toString().padLeft(2, '0')}'
      '-${date.day.toString().padLeft(2, '0')}';
}

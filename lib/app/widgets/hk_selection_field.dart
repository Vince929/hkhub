import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// A themed TDesign selector with localized actions and no text-field focus.
class HkSelectionField extends StatefulWidget {
  const HkSelectionField({super.key, required this.label, required this.value,
    required this.items, required this.onChanged, this.enabled = true});

  final String label;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  State<HkSelectionField> createState() => _HkSelectionFieldState();
}

class _HkSelectionFieldState extends State<HkSelectionField> {
  bool _opening = false;

  Future<void> _open() async {
    if (!widget.enabled || _opening || widget.items.isEmpty) return;
    _opening = true;
    FocusScope.of(context).unfocus();
    final entries = widget.items.entries.toList();
    final selectedIndex = entries.indexWhere((entry) => entry.key == widget.value);
    final material = MaterialLocalizations.of(context);
    try {
      final next = await showModalBottomSheet<String>(
        context: context, backgroundColor: Colors.transparent,
        isScrollControlled: true, useSafeArea: true, requestFocus: false,
        builder: (sheetContext) => TDMultiPicker(
          title: widget.label, topRadius: 24,
          data: [entries.map((entry) => entry.value).toList()],
          initialIndexes: [selectedIndex < 0 ? 0 : selectedIndex],
          leftText: material.cancelButtonLabel, rightText: material.okButtonLabel,
          onCancel: (_) => Navigator.of(sheetContext).pop(),
          onConfirm: (indexes) => Navigator.of(sheetContext).pop(entries[indexes.first as int].key),
        ),
      );
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      if (next != null && widget.enabled && widget.items.containsKey(next) && next != widget.value) {
        widget.onChanged(next);
      }
    } finally {
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.label, value: widget.items[widget.value] ?? '',
    button: true, enabled: widget.enabled,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: TDCell(
        titleWidget: Text(widget.items[widget.value] ?? '',
          style: TextStyle(fontSize: 15, color: widget.enabled
            ? Theme.of(context).colorScheme.onSurface : Theme.of(context).disabledColor)),
        style: TDCellStyle.cellStyle(context)
          ..backgroundColor = Theme.of(context).inputDecorationTheme.fillColor
            ?? Theme.of(context).colorScheme.surface
          ..rightIconColor = Theme.of(context).hintColor,
        rightIcon: TDIcons.chevron_down, disabled: !widget.enabled,
        onClick: (_) => _open(),
      ),
    ),
  );
}

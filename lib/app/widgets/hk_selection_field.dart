import 'package:flutter/material.dart';

/// A compact inline select: a rounded filled field that opens a menu sized to
/// the field, matching the surrounding inputs without a full-width panel.
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
  final _menu = MenuController();

  void _toggle() {
    if (_menu.isOpen) {
      _menu.close();
      return;
    }
    // Drop any text-field focus so closing the menu cannot restore it and
    // raise the software keyboard.
    FocusManager.instance.primaryFocus?.unfocus();
    _menu.open();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = widget.enabled && widget.items.isNotEmpty;
    final selected = widget.items[widget.value] ?? '';
    return Semantics(
      label: widget.label, value: selected, button: true, enabled: enabled,
      child: LayoutBuilder(builder: (context, constraints) => MenuAnchor(
        controller: _menu, consumeOutsideTap: true,
        style: MenuStyle(
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 6)),
          backgroundColor: WidgetStatePropertyAll(theme.colorScheme.surface),
          elevation: const WidgetStatePropertyAll(4),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.dividerColor))),
        ),
        menuChildren: [SizedBox(width: constraints.maxWidth,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            for (final entry in widget.items.entries) _option(theme, entry),
          ]))],
        builder: (context, controller, child) => InkWell(
          onTap: enabled ? _toggle : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 56, padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Expanded(child: Text(selected, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15,
                  color: enabled ? theme.colorScheme.onSurface : theme.disabledColor))),
              Icon(Icons.keyboard_arrow_down_rounded, size: 22,
                color: enabled ? theme.hintColor : theme.disabledColor),
            ]),
          ),
        ),
      )),
    );
  }

  Widget _option(ThemeData theme, MapEntry<String, String> entry) {
    final isSelected = entry.key == widget.value;
    return InkWell(
      onTap: () {
        _menu.close();
        if (!isSelected) widget.onChanged(entry.key);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Expanded(child: Text(entry.value, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface))),
          if (isSelected)
            Icon(Icons.check_rounded, size: 18, color: theme.colorScheme.primary),
        ]),
      ),
    );
  }
}

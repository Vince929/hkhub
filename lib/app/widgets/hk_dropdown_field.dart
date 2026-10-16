import 'dart:math' as math;

import 'package:flutter/material.dart';

/// An anchored, field-width selector. Unlike DropdownButtonFormField, its menu
/// starts below the field rather than aligning a menu item over the field.
class HkDropdownField extends StatefulWidget {
  const HkDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.showLabel = true,
    this.hint,
    this.selectedLabel,
  });

  final String label;
  final String? value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;
  final bool enabled;

  /// Set to false when the surrounding form already displays the field label.
  final bool showLabel;
  final String? hint;

  /// Optional compact text for the field; menu labels can include more detail.
  final String? selectedLabel;

  @override
  State<HkDropdownField> createState() => _HkDropdownFieldState();
}

class _HkDropdownFieldState extends State<HkDropdownField> {
  static const _gap = 4.0;
  static const _maxMenuHeight = 320.0;
  final _controller = MenuController();
  final _focusNode = FocusNode(debugLabel: 'dropdown-field');
  final _fieldKey = GlobalKey();
  bool _expanded = false;
  bool _focused = false;
  bool _opening = false;
  double _menuHeight = _maxMenuHeight;

  bool get _enabled => widget.enabled && widget.items.isNotEmpty;

  void _toggle() {
    if (!_enabled || _opening) return;
    if (_controller.isOpen) {
      _controller.close();
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    _focusNode.requestFocus();
    final box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final media = MediaQuery.of(context);
    final top = box.localToGlobal(Offset.zero).dy;
    final bottomInset = math.max(media.padding.bottom, media.viewInsets.bottom);
    final below = math.max(0.0,
      media.size.height - bottomInset - top - box.size.height - _gap - 8);
    final above = math.max(0.0, top - media.padding.top - _gap - 8);
    // Keep long lists below the field by making them scroll instead of moving
    // the whole menu upward. Only use the upper space near the screen bottom.
    final available = below >= 96 ? below : math.max(below, above);
    if (available <= 0) return;
    _opening = true;
    setState(() => _menuHeight = math.min(_maxMenuHeight, available));
    // Apply the height constraints before the menu is laid out in the overlay.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _opening = false;
      if (mounted && _enabled && _focusNode.hasFocus) _controller.open();
    });
  }

  void _select(String value) {
    _controller.close();
    if (_enabled && widget.items.containsKey(value) && value != widget.value) {
      widget.onChanged(value);
    }
  }

  @override
  void didUpdateWidget(covariant HkDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled || widget.value != oldWidget.value) _controller.close();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Widget _option(MapEntry<String, String> entry, double width) {
    final theme = Theme.of(context);
    final selected = entry.key == widget.value;
    return Semantics(selected: selected, child: MenuItemButton(
      onPressed: _enabled ? () => _select(entry.key) : null,
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(width, 48)),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        backgroundColor: selected
          ? WidgetStatePropertyAll(theme.colorScheme.primary.withValues(alpha: 0.08)) : null,
        foregroundColor: WidgetStatePropertyAll(selected
          ? theme.colorScheme.primary : theme.colorScheme.onSurface),
      ),
      trailingIcon: selected
        ? const Icon(Icons.check_rounded, size: 20) : const SizedBox(width: 20),
      child: Text(entry.value, maxLines: 2, overflow: TextOverflow.ellipsis),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 280.0;
      return MenuAnchor(
        controller: _controller,
        childFocusNode: _focusNode,
        useRootOverlay: true,
        crossAxisUnconstrained: false,
        consumeOutsideTap: true,
        alignmentOffset: const Offset(0, _gap),
        onOpen: () => setState(() => _expanded = true),
        onClose: () { if (mounted) setState(() => _expanded = false); },
        style: MenuStyle(
          alignment: AlignmentDirectional.bottomStart,
          minimumSize: WidgetStatePropertyAll(Size(width, 0)),
          maximumSize: WidgetStatePropertyAll(Size(width, _menuHeight)),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 4)),
          backgroundColor: WidgetStatePropertyAll(theme.colorScheme.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(6),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          )),
        ),
        menuChildren: [for (final entry in widget.items.entries) _option(entry, width)],
        child: Semantics(label: widget.showLabel ? null : widget.label,
          expanded: _expanded, child: TextButton(
          key: _fieldKey,
          focusNode: _focusNode,
          onFocusChange: (value) => setState(() => _focused = value),
          onPressed: _enabled ? _toggle : null,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size(width, 56),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: InputDecorator(
            isFocused: _expanded || _focused,
            decoration: InputDecoration(
              labelText: widget.showLabel ? widget.label : null,
              enabled: _enabled,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Row(children: [
              Expanded(child: Text(widget.selectedLabel ?? widget.items[widget.value]
                  ?? widget.hint ?? '',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: !_enabled ? theme.disabledColor
                    : widget.value == null ? theme.hintColor : theme.colorScheme.onSurface))),
              const SizedBox(width: 12),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero : const Duration(milliseconds: 160),
                child: Icon(Icons.keyboard_arrow_down_rounded,
                  color: _enabled ? theme.colorScheme.primary : theme.disabledColor),
              ),
            ]),
          ),
        )),
      );
    });
  }
}

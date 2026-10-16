import 'package:flutter/material.dart';

import 'hk_dropdown_field.dart';

/// Compatibility wrapper: all single-selection fields use the anchored menu.
class HkSelectionField extends StatelessWidget {
  const HkSelectionField({super.key, required this.label, required this.value,
    required this.items, required this.onChanged, this.enabled = true});

  final String label;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) => HkDropdownField(
    label: label, showLabel: false, value: value, items: items,
    enabled: enabled, onChanged: onChanged,
  );
}

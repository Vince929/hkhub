import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// Keeps Flutter form validation and draft notifications around a TDesign input.
class HkFormInput extends FormField<String> {
  HkFormInput({super.key, required this.controller, required String label,
    bool enabled = true, int maxLength = 120, int maxLines = 1,
    String? hint, IconData? icon, bool numeric = false,
    FormFieldValidator<String>? validator}) : super(
      initialValue: controller.text, enabled: enabled, validator: validator,
      builder: (field) {
        final context = field.context;
        final theme = Theme.of(context);
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Semantics(label: label, child: TDInput(
            controller: controller, readOnly: !enabled, needClear: enabled && maxLines == 1,
            maxLength: maxLength, maxLines: maxLines, showBottomDivider: false,
            clearIconSize: 20,
            inputType: numeric ? const TextInputType.numberWithOptions(decimal: true)
              : maxLines > 1 ? TextInputType.multiline : TextInputType.text,
            inputAction: maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
            cursorColor: theme.colorScheme.primary,
            textStyle: TextStyle(fontSize: 15, height: 1.4,
              color: enabled ? theme.colorScheme.onSurface : theme.disabledColor),
            inputDecoration: InputDecoration(
              hintText: hint, hintMaxLines: maxLines, isDense: true,
              constraints: const BoxConstraints(minHeight: 56),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: InputBorder.none, enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none, filled: false, counterText: '',
              hintStyle: (theme.inputDecorationTheme.hintStyle ?? TextStyle(color: theme.hintColor))
                .copyWith(fontSize: 15, height: 1.4),
            ),
            leftIcon: icon == null ? null : Icon(icon, size: 20, color: theme.hintColor),
            decoration: BoxDecoration(
              color: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: field.hasError ? Border.all(color: theme.colorScheme.error) : null,
            ),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
          )),
          if (field.hasError) Padding(
            padding: const EdgeInsets.only(left: 12, top: 6),
            child: Text(field.errorText!, style: TextStyle(
              fontSize: 12, height: 1.5, color: theme.colorScheme.error)),
          ),
          if (maxLines > 1) Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('${controller.text.characters.length}/$maxLength', textAlign: TextAlign.end,
              style: TextStyle(fontSize: 12, color: theme.hintColor)),
          ),
        ]);
      },
    );

  final TextEditingController controller;

  @override
  FormFieldState<String> createState() => _HkFormInputState();
}

class _HkFormInputState extends FormFieldState<String> {
  TextEditingController get _controller => (widget as HkFormInput).controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_sync);
  }

  void _sync() {
    if (value != _controller.text) didChange(_controller.text);
  }

  @override
  void didUpdateWidget(covariant HkFormInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != _controller) {
      oldWidget.controller.removeListener(_sync);
      _controller.addListener(_sync);
      setValue(_controller.text);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_sync);
    super.dispose();
  }
}

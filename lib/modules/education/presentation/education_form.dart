import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import 'education_strings.dart';

class EducationForm extends StatefulWidget {
  const EducationForm({super.key, required this.initialValues, required this.busy,
    required this.onSubmit, required this.onChanged, this.onCancel});

  final Map<String, dynamic> initialValues;
  final bool busy;
  final void Function(Map<String, dynamic>) onSubmit;
  final void Function(Map<String, dynamic>) onChanged;
  final VoidCallback? onCancel;

  @override
  State<EducationForm> createState() => _EducationFormState();
}

class _EducationFormState extends State<EducationForm> {
  final _form = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _fields;
  late String _scale;
  late String _tier;
  late String _test;
  bool _consent = false;
  bool _consentError = false;

  @override
  void initState() {
    super.initState();
    final values = widget.initialValues;
    _scale = values['grade_scale'] as String? ?? '100';
    _tier = values['institution_tier'] as String? ?? 'unknown';
    _test = values['language_test'] as String? ?? 'not_provided';
    _fields = {
      for (final key in ['institution', 'major', 'grade', 'direction', 'intake_year',
        'language_score', 'experience', 'preferences'])
        key: TextEditingController(text: values[key]?.toString() ??
            (key == 'intake_year' ? '${DateTime.now().year + 1}' : '')),
    };
  }

  @override
  void dispose() {
    for (final field in _fields.values) { field.dispose(); }
    super.dispose();
  }

  Map<String, dynamic> _values() => {
    for (final entry in _fields.entries) entry.key: entry.value.text.trim(),
    'grade_scale': _scale, 'institution_tier': _tier, 'language_test': _test,
  };

  void _changed() => widget.onChanged(_values());

  String? _score(String? value, String maximum, EducationStrings strings) {
    final number = double.tryParse((value ?? '').trim());
    return number == null || !number.isFinite || number < 0 || number > double.parse(maximum)
        ? strings.scoreError(maximum) : null;
  }

  void _submit() {
    final valid = _form.currentState!.validate();
    setState(() => _consentError = !_consent);
    if (!valid || !_consent) return;
    FocusScope.of(context).unfocus();
    final values = _values();
    values['grade'] = double.parse(_fields['grade']!.text.trim());
    values['intake_year'] = int.parse(_fields['intake_year']!.text.trim());
    values['language_score'] = {'ielts', 'toefl'}.contains(_test)
        ? double.parse(_fields['language_score']!.text.trim()) : null;
    values['consent'] = true;
    widget.onSubmit(values);
  }

  @override
  Widget build(BuildContext context) {
    final strings = EducationStrings(Localizations.localeOf(context));
    return Form(key: _form, onChanged: _changed, child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _introduction(strings),
        const SizedBox(height: 24),
        _academic(strings),
        _plans(strings),
        _additional(strings),
        _submission(strings),
      ],
    ));
  }

  Widget _introduction(EducationStrings strings) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: AppTheme.studyBlue, borderRadius: BorderRadius.circular(28)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 48, height: 48,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.school_rounded, color: Colors.white, size: 28)),
      const SizedBox(height: 20),
      Text(strings.introduction, style: const TextStyle(color: Colors.white,
        fontSize: 29, fontWeight: FontWeight.w700, height: 1.3, letterSpacing: -0.6)),
      const SizedBox(height: 12),
      Text(strings.formSubtitle, style: const TextStyle(color: Color(0xFFEAF0FF),
        fontSize: 14, height: 1.6)),
      const SizedBox(height: 20),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _heroTag(Icons.account_balance_rounded, strings.candidateUniversities),
        _heroTag(Icons.school_outlined, strings.taughtMasters),
      ]),
    ]),
  );

  Widget _heroTag(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 15, color: Colors.white), const SizedBox(width: 6),
      Flexible(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12))),
    ]),
  );

  Widget _academic(EducationStrings strings) => _section(
    strings.academic, Icons.history_edu_rounded, AppTheme.studyBlue, [
      _field('institution', strings.institution, max: 120, icon: Icons.account_balance_outlined),
      _field('major', strings.major, max: 120, icon: Icons.menu_book_rounded),
      _pair(
        _choice(strings.scale, _scale, {
          for (final scale in ['100', '4', '5']) scale: strings.scaleName(scale),
        }, (value) { setState(() => _scale = value); _changed(); }),
        _field('grade', strings.grade, numeric: true, max: 10,
          validator: (value) => _score(value, _scale, strings)),
      ),
      Text(strings.gradeHint, style: const TextStyle(fontSize: 12, color: AppTheme.studyMuted)),
    ],
  );

  Widget _plans(EducationStrings strings) => _section(
    strings.plans, Icons.explore_rounded, AppTheme.studyTeal, [
      _field('direction', strings.direction, max: 150, hint: strings.directionHint,
        icon: Icons.explore_outlined),
      _field('intake_year', strings.year, numeric: true, max: 4,
        icon: Icons.calendar_month_rounded, validator: (value) {
          final year = int.tryParse((value ?? '').trim());
          final now = DateTime.now().year;
          return year == null || year < now - 1 || year > now + 8 ? strings.invalidYear : null;
        }),
    ],
  );

  Widget _additional(EducationStrings strings) => _section(
    strings.optional, Icons.tune_rounded, AppTheme.studyBlue, [
      _choice(strings.institutionTier, _tier, {
        for (final tier in ['unknown', '985', '211', 'other']) tier: strings.tierName(tier),
      }, (value) { setState(() => _tier = value); _changed(); }),
      _choice(strings.languageTest, _test, {
        for (final test in ['not_provided', 'not_taken', 'ielts', 'toefl']) test: strings.languageName(test),
      }, (value) { setState(() { _test = value; _fields['language_score']!.clear(); }); _changed(); }),
      if ({'ielts', 'toefl'}.contains(_test))
        _field('language_score', strings.languageScore, numeric: true, max: 10,
          validator: (value) => _score(value, _test == 'ielts' ? '9' : '120', strings)),
      _field('experience', strings.experience, max: 1200, lines: 3, isRequired: false),
      _field('preferences', strings.preferences, max: 600, lines: 2,
        hint: strings.preferencesHint, isRequired: false),
    ],
  );

  Widget _submission(EducationStrings strings) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        decoration: BoxDecoration(color: const Color(0xFFEAF0FF), borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), child: Row(children: [
            const Icon(Icons.verified_user_outlined, color: AppTheme.studyBlue, size: 19),
            const SizedBox(width: 8),
            Expanded(child: Text(strings.estimateNotice,
              style: const TextStyle(fontSize: 12, height: 1.5, color: AppTheme.studyInk))),
          ])),
          ExpansionTile(tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Text(strings.privacyTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            children: [Text('${strings.privacy}\n\n${strings.disclaimer}',
              style: const TextStyle(fontSize: 12, height: 1.7, color: AppTheme.studyMuted))]),
        ]),
      ),
      const SizedBox(height: 10),
      CheckboxListTile(
        value: _consent, contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: widget.busy ? null : (value) => setState(() {
          _consent = value ?? false; _consentError = false;
        }),
        title: Text(strings.consentLabel,
          style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.studyInk)),
      ),
      if (_consentError) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(
        strings.consentRequired, style: TextStyle(color: Theme.of(context).colorScheme.error))),
      const SizedBox(height: 8),
      FilledButton.icon(onPressed: widget.busy ? null : _submit,
        icon: widget.busy ? const SizedBox(width: 19, height: 19,
          child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome_rounded, size: 21),
        label: Text(strings.generate)),
      if (widget.busy) Container(
        margin: const EdgeInsets.only(top: 14), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(children: [
          Text(strings.generating, textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.studyInk, fontSize: 13, height: 1.5)),
          const SizedBox(height: 6),
          Text(strings.waiting, textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.studyMuted, fontSize: 12, height: 1.5)),
          if (widget.onCancel != null) TextButton.icon(
            onPressed: widget.onCancel, icon: const Icon(Icons.close_rounded, size: 18),
            label: Text(strings.cancel),
          ),
        ]),
      ),
    ],
  );

  Widget _section(String title, IconData icon, Color accent, List<Widget> children) => Container(
    margin: const EdgeInsets.only(bottom: 18), padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppTheme.studyLine)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Container(width: 38, height: 38,
          decoration: BoxDecoration(color: accent.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 21, color: accent)),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 17,
          fontWeight: FontWeight.w700, color: AppTheme.studyInk))),
      ]),
      const SizedBox(height: 22), ...children,
    ]),
  );

  Widget _pair(Widget first, Widget second) => LayoutBuilder(builder: (context, constraints) {
    if (constraints.maxWidth < 480) return Column(children: [first, second]);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: first), const SizedBox(width: 16), Expanded(child: second),
    ]);
  });

  Widget _label(String text, Widget child) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.studyInk)),
      const SizedBox(height: 8), child,
    ]),
  );

  Widget _field(String key, String label, {bool isRequired = true, bool numeric = false,
    int max = 120, int lines = 1, String? hint, IconData? icon, String? Function(String?)? validator}) {
    final strings = EducationStrings(Localizations.localeOf(context));
    return _label(label, TextFormField(
      controller: _fields[key], enabled: !widget.busy, maxLength: max, maxLines: lines,
      style: const TextStyle(fontSize: 15, color: AppTheme.studyInk, height: 1.5),
      keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true)
        : lines > 1 ? TextInputType.multiline : TextInputType.text,
      textInputAction: lines == 1 ? TextInputAction.next : TextInputAction.newline,
      decoration: InputDecoration(hintText: hint, hintMaxLines: 2,
        prefixIcon: icon == null ? null : Icon(icon, size: 20, color: AppTheme.studyMuted),
        counterText: lines > 1 ? null : ''),
      validator: validator ?? (value) =>
          isRequired && (value ?? '').trim().isEmpty ? strings.requiredField : null,
    ));
  }

  Widget _choice(String label, String value, Map<String, String> items, ValueChanged<String> changed) {
    return _label(label, DropdownButtonFormField<String>(
      key: ValueKey('$label:$value'), initialValue: value, isExpanded: true,
      borderRadius: BorderRadius.circular(18), dropdownColor: Colors.white,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.studyMuted),
      style: const TextStyle(fontSize: 15, color: AppTheme.studyInk),
      items: [for (final entry in items.entries) DropdownMenuItem(value: entry.key, child: Text(entry.value))],
      onChanged: widget.busy ? null : (next) { if (next != null) changed(next); },
    ));
  }
}

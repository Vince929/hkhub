import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../../app/localization/locale_controller.dart';
import '../../../app/network/api_client.dart';
import '../../../app/network/api_exception.dart';
import '../../../app/providers.dart';
import '../data/education_models.dart';
import '../data/education_storage.dart';
import '../theme/education_theme.dart';
import 'education_form.dart';
import 'education_report_view.dart';
import 'education_strings.dart';

class EducationScreen extends ConsumerStatefulWidget {
  const EducationScreen({super.key});

  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen> {
  late EducationStorage _storage;
  Map<String, dynamic> _draft = {};
  EducationReport? _report;
  Object? _error;
  bool _busy = false;
  bool _editing = true;
  bool _localWarning = false;
  bool _consent = false;
  int _formVersion = 0;
  int _generation = 0;
  CancelToken? _cancel;
  Timer? _saveTimer;
  Timer? _analysisTimer;
  Future<void> _writes = Future<void>.value();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadRecord(ref.read(activeAppConfigProvider).apiBaseUrl);
  }

  void _loadRecord(String apiBaseUrl) {
    _storage = EducationStorage(ref.read(preferencesProvider), apiBaseUrl);
    final record = _storage.load();
    _consent = _storage.loadConsent();
    _draft = record.form;
    _report = record.report;
    _editing = _report == null;
    _localWarning = false;
    _error = null;
    _formVersion++;
  }

  void _cancelAnalysis() {
    _generation++;
    _analysisTimer?.cancel();
    _analysisTimer = null;
    _cancel?.cancel();
    _cancel = null;
    _busy = false;
  }

  void _changed(Map<String, dynamic> values) {
    _draft = values;
    // An edited background invalidates the previous report, including after restarting.
    _report = null;
    _editing = true;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () { unawaited(_persist()); });
  }

  void _consentChanged(bool consent) {
    _consent = consent;
    final storage = _storage;
    // Serialize with record writes and clearing; do not invalidate the report.
    _writes = _writes.then((_) async {
      try {
        await storage.saveConsent(consent);
      } catch (_) {
        if (mounted && identical(storage, _storage)) setState(() => _localWarning = true);
      }
    });
  }

  Future<void> _persist() {
    _saveTimer?.cancel();
    _saveTimer = null;
    final storage = _storage;
    final form = Map<String, dynamic>.from(_draft);
    final report = _report;
    final done = Completer<void>();
    // Serialize writes so clearing cannot race a late debounce or report save.
    _writes = _writes.then((_) async {
      try {
        await storage.save(form, report);
        done.complete();
      } catch (_) {
        if (mounted && identical(storage, _storage)) setState(() => _localWarning = true);
        done.complete();
      }
    });
    return done.future;
  }

  Future<void> _analyse(Map<String, dynamic> values) async {
    if (_busy) return;
    final token = CancelToken();
    final generation = ++_generation;
    _cancel = token;
    setState(() { _busy = true; _error = null; _draft = values; });
    // A wall-clock deadline also covers storage and responses that keep the socket alive.
    _analysisTimer = Timer(const Duration(seconds: 195), () {
      if (!mounted || generation != _generation) return;
      setState(() {
        _cancelAnalysis();
        _error = const ApiException(code: 'timeout', message: 'Analysis timed out');
      });
      _top();
    });
    try {
      final client = ref.read(apiClientProvider);
      await _persist();
      if (!mounted || generation != _generation) return;
      final report = await client.request(
        'education/analyse', method: 'POST', data: values,
        decode: EducationReport.fromJson, cancelToken: token,
        receiveTimeout: const Duration(seconds: 195),
      );
      if (!mounted || generation != _generation) return;
      _analysisTimer?.cancel();
      _analysisTimer = null;
      setState(() { _report = report; _editing = false; _busy = false; _cancel = null; });
      _top();
      await _persist();
    } catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() { _error = error; _busy = false; _cancel = null; });
      _top();
    } finally {
      if (mounted && generation == _generation) {
        _analysisTimer?.cancel();
        _analysisTimer = null;
        if (_busy) setState(() { _busy = false; _cancel = null; });
      }
    }
  }

  void _edit() {
    setState(() { _editing = true; _error = null; _formVersion++; });
    _top();
  }

  void _top() {
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _clear() async {
    if (_busy) return;
    final strings = EducationStrings(ref.read(effectiveLocaleProvider));
    FocusScope.of(context).unfocus();
    final confirmed = await showDialog<bool>(context: context, requestFocus: false,
      builder: (dialogContext) => TDAlertDialog(
        title: strings.clearQuestion, radius: 24,
        buttonStyle: TDDialogButtonStyle.normal,
        leftBtn: TDDialogButtonOptions(title: strings.cancel,
          action: () => Navigator.of(dialogContext).pop(false)),
        rightBtn: TDDialogButtonOptions(title: strings.clear,
          theme: TDButtonTheme.danger,
          action: () => Navigator.of(dialogContext).pop(true)),
      ),
    );
    if (confirmed != true || !mounted || _busy) return;
    _saveTimer?.cancel();
    _saveTimer = null;
    final storage = _storage;
    final generation = ++_generation;
    setState(() => _busy = true);
    try {
      await _writes;
      await storage.clear();
      if (!mounted || generation != _generation) return;
      setState(() {
        _draft = {}; _report = null; _error = null; _editing = true;
        _consent = false; _localWarning = false; _busy = false; _formVersion++;
      });
      _top();
    } catch (_) {
      if (mounted && generation == _generation) setState(() { _localWarning = true; _busy = false; });
    }
  }

  @override
  void dispose() {
    if (_saveTimer?.isActive ?? false) unawaited(_persist());
    _saveTimer?.cancel();
    _cancelAnalysis();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(effectiveLocaleProvider);
    final strings = EducationStrings(locale);
    ref.listen(activeAppConfigProvider, (previous, next) {
      if (previous?.apiBaseUrl == next.apiBaseUrl) return;
      if (_saveTimer?.isActive ?? false) unawaited(_persist());
      setState(() { _cancelAnalysis(); _loadRecord(next.apiBaseUrl); });
      _top();
    });
    ref.listen(effectiveLocaleProvider, (previous, next) {
      if (previous == next) return;
      setState(() { _cancelAnalysis(); _error = null; _formVersion++; });
    });
    // Cached reports are not translated by changing labels; regenerate in the new language.
    final showReport = !_editing && _report != null && _report!.language == locale.toLanguageTag();
    return Theme(
      data: EducationTheme.apply(Theme.of(context)),
      child: Builder(builder: (context) => _page(context, strings, showReport)),
    );
  }

  Widget _page(BuildContext context, EducationStrings strings, bool showReport) {
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.title),
        leading: Navigator.of(context).canPop() ? Padding(
          padding: const EdgeInsets.all(8),
          child: IconButton.filledTonal(
            style: IconButton.styleFrom(backgroundColor: Colors.white, foregroundColor: EducationTheme.ink),
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
        ) : null,
        actions: [
        IconButton(onPressed: _busy ? null : _clear, tooltip: strings.clear,
          icon: const Icon(Icons.delete_outline_rounded, size: 21)),
        const SizedBox(width: 8),
      ]),
      body: SafeArea(child: SingleChildScrollView(
        controller: _scroll, padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (_error != null) _notice(context, _errorMessage(_error!, strings)),
            if (_localWarning) _notice(context, strings.localFailure),
            if (showReport)
              EducationReportView(key: ValueKey(_report!.generatedAt), report: _report!, onEdit: _edit)
            else EducationForm(
              key: ValueKey(_formVersion), initialValues: _draft, busy: _busy,
              initialConsent: _consent, onConsentChanged: _consentChanged,
              onChanged: _changed, onSubmit: (values) { unawaited(_analyse(values)); },
              onCancel: () => setState(() { _cancelAnalysis(); _error = null; }),
            ),
          ]),
        )),
      )),
    );
  }

  String _errorMessage(Object error, EducationStrings strings) {
    if (error is! ApiException) return strings.failed;
    return switch (error.code) {
      'network_error' || 'invalid_certificate' => strings.networkError,
      'timeout' || 'education_timeout' => strings.timeout,
      'invalid_response' || 'education_invalid_response' => strings.invalidResponse,
      _ => error.isServerMessage && error.message.isNotEmpty ? error.message : strings.failed,
    };
  }

  Widget _notice(BuildContext context, String text) => Container(
    margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(18)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.info_outline_rounded, size: 20, color: Theme.of(context).colorScheme.onErrorContainer),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: TextStyle(height: 1.5,
        color: Theme.of(context).colorScheme.onErrorContainer))),
    ]),
  );
}

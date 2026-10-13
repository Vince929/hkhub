import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'education_models.dart';

class EducationRecord {
  const EducationRecord({required this.form, this.report});
  final Map<String, dynamic> form;
  final EducationReport? report;
}

class EducationStorage {
  EducationStorage(this.preferences, String apiBaseUrl)
      : _key = 'hkhub.education.latest.${Uri.encodeComponent(apiBaseUrl)}';

  final SharedPreferences preferences;
  final String _key;
  // Increment the consent version when the privacy notice materially changes.
  String get _consentKey => '$_key.consent.v1';

  bool loadConsent() => preferences.getBool(_consentKey) ?? false;

  Future<void> saveConsent(bool consent) async {
    if (!await preferences.setBool(_consentKey, consent)) {
      throw StateError('Could not save education consent');
    }
  }

  EducationRecord load() {
    final saved = preferences.getString(_key);
    if (saved == null || saved.length > 200000) return const EducationRecord(form: {});
    try {
      final value = jsonDecode(saved);
      if (value is! Map<String, dynamic> || value['version'] != 1 ||
          value['form'] is! Map<String, dynamic>) {
        return const EducationRecord(form: {});
      }
      final form = value['form'] as Map<String, dynamic>;
      return EducationRecord(
        form: _sanitize(form),
        report: value['report'] == null ? null : EducationReport.fromJson(value['report']),
      );
    } on FormatException {
      return const EducationRecord(form: {});
    }
  }

  // Consent is stored separately from applicant data and cached reports.
  Map<String, dynamic> _sanitize(Map<String, dynamic> form) {
    final result = <String, dynamic>{};
    const textFields = {'institution', 'major', 'direction', 'experience', 'preferences'};
    for (final key in textFields) {
      final value = form[key];
      if (value is String && value.length <= 1200) result[key] = value;
    }
    const choices = {
      'grade_scale': {'100', '4', '5'},
      'institution_tier': {'985', '211', 'other', 'unknown'},
      'language_test': {'not_provided', 'not_taken', 'ielts', 'toefl'},
    };
    for (final entry in choices.entries) {
      if (entry.value.contains(form[entry.key])) result[entry.key] = form[entry.key];
    }
    for (final key in ['grade', 'language_score', 'intake_year']) {
      final value = form[key];
      if (value is num && value.isFinite) result[key] = value;
      if (value is String && value.length <= 12) result[key] = value;
    }
    return result;
  }

  Future<void> save(Map<String, dynamic> form, EducationReport? report) async {
    final success = await preferences.setString(_key, jsonEncode({
      'version': 1, 'form': _sanitize(form), 'report': report?.toJson(),
    }));
    if (!success) throw StateError('Could not save education record');
  }

  Future<void> clear() async {
    if (!await preferences.remove(_key)) throw StateError('Could not clear education record');
    if (!await preferences.remove(_consentKey)) throw StateError('Could not clear education consent');
  }
}

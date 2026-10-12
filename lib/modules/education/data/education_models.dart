const educationSchoolIds = {
  'hku', 'cuhk', 'hkust', 'cityu', 'polyu', 'hkbu', 'lingnan', 'eduhk', 'hkmu', 'hsuhk',
};

String probabilityTier(int probability) => probability < 30 ? 'reach' : probability < 60 ? 'match' : 'safer';

Map<String, dynamic> _object(Object? value) {
  if (value is! Map<String, dynamic>) throw const FormatException('Expected education object');
  return value;
}

String _text(Map<String, dynamic> value, String key, {int max = 1000}) {
  final field = value[key];
  if (field is! String || field.trim().isEmpty || field.length > max) {
    throw FormatException('Invalid education field: $key');
  }
  return field;
}

int _probability(Map<String, dynamic> value, String key) {
  final field = value[key];
  if (field is! int || field < 0 || field > 100) throw const FormatException('Invalid probability');
  return field;
}

List<String> _texts(Map<String, dynamic> value, String key, {int min = 1, int max = 2}) {
  final field = value[key];
  if (field is! List || field.length < min || field.length > max ||
      field.any((item) => item is! String || item.trim().isEmpty || item.length > 350)) {
    throw const FormatException('Invalid education explanations');
  }
  return List<String>.unmodifiable(field.cast<String>());
}

class ProgrammeResult {
  const ProgrammeResult({required this.name, required this.nameEn, required this.probability,
    required this.relevance, required this.strengths, required this.weaknesses, required this.nextSteps});

  factory ProgrammeResult.fromJson(Object? data) {
    final value = _object(data);
    final probability = _probability(value, 'probability');
    if (value['tier'] != probabilityTier(probability)) throw const FormatException('Invalid programme tier');
    return ProgrammeResult(
      name: _text(value, 'name', max: 200), nameEn: _text(value, 'name_en', max: 200),
      probability: probability, relevance: _text(value, 'relevance', max: 350),
      strengths: _texts(value, 'strengths'), weaknesses: _texts(value, 'weaknesses'),
      nextSteps: _texts(value, 'next_steps'),
    );
  }

  final String name;
  final String nameEn;
  final int probability;
  final String relevance;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> nextSteps;
  String get tier => probabilityTier(probability);

  Map<String, dynamic> toJson() => {
    'name': name, 'name_en': nameEn, 'probability': probability, 'tier': tier,
    'relevance': relevance, 'strengths': strengths, 'weaknesses': weaknesses, 'next_steps': nextSteps,
  };
}

class SchoolResult {
  const SchoolResult({required this.id, required this.name, required this.nameEn,
    required this.minimum, required this.maximum, required this.programmes});

  factory SchoolResult.fromJson(Object? data) {
    final value = _object(data);
    final id = _text(value, 'school_id', max: 30);
    final items = value['programmes'];
    if (!educationSchoolIds.contains(id) || items is! List || items.isEmpty || items.length > 3) {
      throw const FormatException('Invalid school programmes');
    }
    final programmes = items.map(ProgrammeResult.fromJson).toList(growable: false);
    final scores = programmes.map((item) => item.probability).toList()..sort();
    final names = programmes.map((item) => item.nameEn.trim().toLowerCase()).toSet();
    if (names.length != programmes.length || value['probability_min'] != scores.first ||
        value['probability_max'] != scores.last || value['tier'] != probabilityTier(scores.last)) {
      throw const FormatException('Inconsistent school probability');
    }
    return SchoolResult(
      id: id, name: _text(value, 'name', max: 200), nameEn: _text(value, 'name_en', max: 200),
      minimum: scores.first, maximum: scores.last,
      programmes: List<ProgrammeResult>.unmodifiable(programmes),
    );
  }

  final String id;
  final String name;
  final String nameEn;
  final int minimum;
  final int maximum;
  final List<ProgrammeResult> programmes;
  String get tier => probabilityTier(maximum);

  Map<String, dynamic> toJson() => {
    'school_id': id, 'name': name, 'name_en': nameEn,
    'probability_min': minimum, 'probability_max': maximum, 'tier': tier,
    'programmes': programmes.map((item) => item.toJson()).toList(),
  };
}

class EducationReport {
  const EducationReport({required this.language, required this.generatedAt, required this.summary,
    required this.assumptions, required this.schools});

  factory EducationReport.fromJson(Object? data) {
    final value = _object(data);
    final language = _text(value, 'language', max: 20);
    final generatedAt = _text(value, 'generated_at', max: 40);
    final items = value['schools'];
    if (value['schema_version'] != 1 || value['source'] != 'ai_estimate' ||
        !{'zh-Hans', 'zh-Hant', 'yue-Hant-HK', 'en'}.contains(language) ||
        DateTime.tryParse(generatedAt) == null || items is! List || items.length > 10) {
      throw const FormatException('Invalid education report');
    }
    final schools = items.map(SchoolResult.fromJson).toList(growable: false);
    if (schools.map((item) => item.id).toSet().length != schools.length) {
      throw const FormatException('Duplicate education school');
    }
    return EducationReport(
      language: language, generatedAt: generatedAt, summary: _text(value, 'summary'),
      assumptions: _texts(value, 'assumptions', min: 0, max: 6),
      schools: List<SchoolResult>.unmodifiable(schools),
    );
  }

  final String language;
  final String generatedAt;
  final String summary;
  final List<String> assumptions;
  final List<SchoolResult> schools;

  Map<String, dynamic> toJson() => {
    'schema_version': 1, 'source': 'ai_estimate', 'language': language,
    'generated_at': generatedAt, 'summary': summary, 'assumptions': assumptions,
    'schools': schools.map((item) => item.toJson()).toList(),
  };
}

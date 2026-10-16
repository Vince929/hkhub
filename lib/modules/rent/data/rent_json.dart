Map rentObject(Object? raw) {
  if (raw is! Map) throw const FormatException('Invalid rental object');
  return raw;
}

String rentText(Map raw, String key) {
  final value = raw[key];
  if (value is! String) throw FormatException('Invalid rental field: $key');
  return value;
}

String rentMonth(Map raw, String key) {
  final value = rentText(raw, key);
  if (!RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(value)) {
    throw const FormatException('Invalid rental month');
  }
  return value;
}

double? rentNumber(Object? raw) {
  if (raw == null) return null;
  if (raw is! num || !raw.isFinite) throw const FormatException('Invalid rental number');
  return raw.toDouble();
}

bool rentBool(Map raw, String key) {
  final value = raw[key];
  if (value is! bool) throw const FormatException('Invalid rental boolean');
  return value;
}

List<T> rentItems<T>(Map raw, String key, T Function(Object?) decode) {
  final value = raw[key];
  if (value is! List || value.length > 100) throw const FormatException('Invalid rental list');
  return List<T>.unmodifiable(value.map(decode));
}

DateTime? rentTime(Object? raw) {
  if (raw == null) return null;
  final result = raw is String ? DateTime.tryParse(raw) : null;
  if (result == null || !result.isUtc) throw const FormatException('Invalid rental UTC time');
  return result;
}

String? rentOptionalText(Object? raw) {
  if (raw == null) return null;
  if (raw is! String) throw const FormatException('Invalid optional rental text');
  return raw;
}

void rentVersion(Map raw) {
  if (raw['schema_version'] != 1) throw const FormatException('Unsupported rental schema');
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'residency_models.dart';

/// Local-only persistence for the residency profile. Keys are isolated per API
/// environment so development data cannot leak into a production build.
///
/// The profile only ever lives on the device: there is no account, no server
/// copy and no upload.
class ResidencyStorage {
  ResidencyStorage(this.preferences, String apiBaseUrl)
      : _key = 'hkhub.residency.${Uri.encodeComponent(apiBaseUrl)}';

  final SharedPreferences preferences;
  final String _key;

  static const _schemaVersion = 1;
  static const _maxLength = 200000;

  ResidencyProfile load() {
    final saved = preferences.getString(_key);
    if (saved == null || saved.length > _maxLength) return ResidencyProfile.empty;
    try {
      final value = jsonDecode(saved);
      if (value is! Map<String, dynamic> || value['version'] != _schemaVersion) {
        return ResidencyProfile.empty;
      }
      return ResidencyProfile.fromJson(value['profile']);
    } on FormatException {
      return ResidencyProfile.empty;
    }
  }

  Future<void> save(ResidencyProfile profile) async {
    final success = await preferences.setString(
      _key,
      jsonEncode({'version': _schemaVersion, 'profile': profile.toJson()}),
    );
    if (!success) throw StateError('Could not save residency profile');
  }

  Future<void> clear() async {
    if (!await preferences.remove(_key)) {
      throw StateError('Could not clear residency profile');
    }
  }
}

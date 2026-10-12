import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/api_client.dart';

String _string(Map value, String key) {
  final result = value[key];
  if (result is! String) throw FormatException('Invalid catalog field: $key');
  return result;
}

class HomeTool {
  const HomeTool({
    required this.id,
    required this.featureId,
    required this.title,
    required this.description,
    required this.icon,
    required this.visible,
    required this.aliases,
  });

  factory HomeTool.fromJson(Object? value) {
    if (value is! Map || value['visible'] is! bool || value['aliases'] is! List) {
      throw const FormatException('Invalid tool entry');
    }
    final aliases = value['aliases'] as List;
    if (aliases.length > 30 || aliases.any((alias) => alias is! String)) {
      throw const FormatException('Invalid tool aliases');
    }
    final id = _string(value, 'id');
    final featureId = _string(value, 'feature_id');
    final title = _string(value, 'title');
    if (id.isEmpty || featureId.isEmpty || title.trim().isEmpty) {
      throw const FormatException('Missing tool identity');
    }
    return HomeTool(
      id: id,
      featureId: featureId,
      title: title,
      description: _string(value, 'description'),
      icon: _string(value, 'icon'),
      visible: value['visible'] as bool,
      aliases: List<String>.unmodifiable(aliases.cast<String>()),
    );
  }

  final String id;
  final String featureId;
  final String title;
  final String description;
  final String icon;
  final bool visible;
  final List<String> aliases;

  bool matches(String query) {
    final fields = [title, description, ...aliases].map((field) => field.toLowerCase()).toList();
    return query.toLowerCase().trim().split(RegExp(r'\s+')).every(
      (word) => fields.any((field) => field.contains(word)),
    );
  }
}

class HomeToolGroup {
  const HomeToolGroup({required this.id, required this.title, required this.items});

  factory HomeToolGroup.fromJson(Object? value) {
    if (value is! Map || value['items'] is! List) {
      throw const FormatException('Invalid tool group');
    }
    final rawItems = value['items'] as List;
    if (rawItems.length > 100) throw const FormatException('Too many tools');
    final id = _string(value, 'id');
    final title = _string(value, 'title');
    if (id.isEmpty || title.trim().isEmpty) throw const FormatException('Invalid group identity');
    return HomeToolGroup(
      id: id, title: title,
      items: List<HomeTool>.unmodifiable(rawItems.map(HomeTool.fromJson)),
    );
  }

  final String id;
  final String title;
  final List<HomeTool> items;
}

class HomeTools {
  const HomeTools({required this.version, required this.language, required this.groups});

  factory HomeTools.fromJson(Object? value) {
    if (value is! Map || value['groups'] is! List) {
      throw const FormatException('Invalid tool catalog');
    }
    final rawGroups = value['groups'] as List;
    if (rawGroups.length > 30) throw const FormatException('Too many groups');
    final groups = rawGroups.map(HomeToolGroup.fromJson).toList(growable: false);
    final items = groups.expand((group) => group.items).toList(growable: false);
    if (items.length > 100 || items.map((item) => item.id).toSet().length != items.length ||
        groups.map((group) => group.id).toSet().length != groups.length) {
      throw const FormatException('Invalid catalog identities');
    }
    return HomeTools(
      version: _string(value, 'version'), language: _string(value, 'language'),
      groups: List<HomeToolGroup>.unmodifiable(groups),
    );
  }

  final String version;
  final String language;
  final List<HomeToolGroup> groups;
}

final homeToolsProvider = AsyncNotifierProvider.autoDispose<HomeToolsController, HomeTools>(
  HomeToolsController.new,
);

class HomeToolsController extends AutoDisposeAsyncNotifier<HomeTools> {
  late ApiClient _client;
  late CancelToken _cancelToken;
  int _generation = 0;
  Future<void>? _refreshing;

  @override
  Future<HomeTools> build() {
    _client = ref.watch(apiClientProvider);
    _cancelToken = CancelToken();
    final token = _cancelToken;
    ref.onDispose(() => token.cancel());
    _generation++;
    _refreshing = null;
    return _client.request('app/tool-catalog', decode: HomeTools.fromJson, cancelToken: token);
  }

  Future<void> refresh() {
    if (_refreshing != null) return _refreshing!;
    if (state.isLoading) return Future<void>.value();
    final request = _reload();
    _refreshing = request;
    return request;
  }

  Future<void> _reload() async {
    final generation = _generation;
    final token = _cancelToken;
    // Keep the grid steady only while updating; an error replaces it, not cached data.
    if (!state.hasValue || state.hasError) state = const AsyncLoading();
    try {
      final result = await _client.request(
        'app/tool-catalog', decode: HomeTools.fromJson, cancelToken: token,
      );
      if (!token.isCancelled && generation == _generation) state = AsyncData(result);
    } catch (error, stack) {
      if (!token.isCancelled && generation == _generation) state = AsyncError(error, stack);
    } finally {
      if (generation == _generation) _refreshing = null;
    }
  }
}

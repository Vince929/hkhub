const borderCodes = {'LWS', 'LSC', 'SBC'};
const audiences = {'resident', 'visitor'};

Map object(Object? value) {
  if (value is! Map) throw const FormatException('Invalid commute object');
  return value;
}

String text(Map value, String key) {
  final result = value[key];
  if (result is! String) throw FormatException('Invalid commute field: $key');
  return result;
}

DateTime? optionalTime(Object? value) {
  if (value == null) return null;
  if (value is! String) throw const FormatException('Invalid commute timestamp');
  final result = DateTime.tryParse(value);
  if (result == null || !result.isUtc) throw const FormatException('Invalid UTC timestamp');
  return result;
}

DateTime requiredTime(Object? value) {
  final result = optionalTime(value);
  if (result == null) throw const FormatException('Missing commute timestamp');
  return result;
}

List<T> items<T>(Map value, String key, T Function(Object?) decode) {
  final result = value[key];
  if (result is! List || result.length > 100) throw const FormatException('Invalid commute list');
  return List<T>.unmodifiable(result.map(decode));
}

class QueueStatus {
  QueueStatus(Object? raw) {
    final value = object(raw);
    reason = text(value, 'reason');
    if (!{'available', 'maintenance', 'closed', 'missing', 'invalid', 'fetch_failed',
          'stale', 'not_collected'}.contains(reason)) {
      throw const FormatException('Invalid queue reason');
    }
    final rawCode = value['code'];
    if (rawCode != null && (rawCode is! int || !{0, 1, 2, 4, 99}.contains(rawCode))) {
      throw const FormatException('Invalid queue code');
    }
    code = rawCode as int?;
    fetchedAt = optionalTime(value['fetched_at']);
    if (reason == 'available' && (!{0, 1, 2}.contains(code) || fetchedAt == null)) {
      throw const FormatException('Invalid available queue');
    }
  }
  late final int? code;
  late final String reason;
  late final DateTime? fetchedAt;

  String reasonAt(DateTime now) => fetchedAt != null &&
      now.difference(fetchedAt!).inSeconds >= 1800 ? 'stale' : reason;
}

class Border {
  Border(Object? raw) {
    final value = object(raw);
    code = text(value, 'code');
    if (!borderCodes.contains(code)) throw const FormatException('Unsupported border');
    name = text(value, 'name');
    counterpart = text(value, 'counterpart');
    modes = items(value, 'modes', (raw) {
      if (raw != 'mtr' && raw != 'bus') throw const FormatException('Invalid transit mode');
      return raw as String;
    });
    final queuesMap = object(value['queues']);
    queues = {for (final audience in audiences) audience: QueueStatus(queuesMap[audience])};
  }
  late final String code;
  late final String name;
  late final String counterpart;
  late final List<String> modes;
  late final Map<String, QueueStatus> queues;
}

class BordersData {
  BordersData(Object? raw) {
    final value = object(raw);
    serverTime = requiredTime(value['server_time']);
    borders = items(value, 'items', Border.new);
    if (borders.length != 3 || borders.map((item) => item.code).toSet().length != 3) {
      throw const FormatException('Invalid border catalog');
    }
  }
  late final DateTime serverTime;
  late final List<Border> borders;
  final Stopwatch _age = Stopwatch()..start();
  DateTime get now => serverTime.add(_age.elapsed);
}

class HistoryDay {
  HistoryDay(Object? raw) {
    final value = object(raw);
    date = text(value, 'date');
    queue = QueueStatus(value['queue']);
  }
  late final String date;
  late final QueueStatus queue;
}

class HistoryData {
  HistoryData(Object? raw) {
    final value = object(raw);
    serverTime = requiredTime(value['server_time']);
    slotStart = text(value, 'slot_start');
    slotEnd = text(value, 'slot_end');
    current = QueueStatus(value['current']);
    days = items(value, 'days', HistoryDay.new);
    final count = value['valid_count'];
    if (count is! int || count < 0 || count > 7 || days.length != 7) {
      throw const FormatException('Invalid history count');
    }
    validCount = count;
    comparison = value['comparison'] == null ? null : Comparison(value['comparison']);
  }
  late final DateTime serverTime;
  late final String slotStart;
  late final String slotEnd;
  late final QueueStatus current;
  late final List<HistoryDay> days;
  late final int validCount;
  late final Comparison? comparison;
  final Stopwatch _age = Stopwatch()..start();
  bool get inCurrentSlot {
    final now = serverTime.add(_age.elapsed).toUtc().add(const Duration(hours: 8));
    final original = serverTime.toUtc().add(const Duration(hours: 8));
    return now.year == original.year && now.month == original.month && now.day == original.day &&
        (now.hour * 60 + now.minute) ~/ 15 == (original.hour * 60 + original.minute) ~/ 15;
  }
}

class Comparison {
  Comparison(Object? raw) {
    final value = object(raw);
    int count(String key) {
      final result = value[key];
      if (result is! int || result < 0 || result > 7) throw const FormatException('Invalid comparison');
      return result;
    }
    lower = count('lower');
    same = count('same');
    higher = count('higher');
    if (value['whole_week'] is! bool) throw const FormatException('Invalid whole-week flag');
    wholeWeek = value['whole_week'] as bool;
    position = text(value, 'position');
  }
  late final int lower;
  late final int same;
  late final int higher;
  late final bool wholeWeek;
  late final String position;
}

class TransitDeparture {
  TransitDeparture(Object? raw) {
    final value = object(raw);
    time = requiredTime(value['time']);
    kind = text(value, 'kind');
    if (!{'departure', 'estimated_arrival', 'scheduled_arrival'}.contains(kind)) {
      throw const FormatException('Invalid departure type');
    }
    platform = text(value, 'platform');
    destination = text(value, 'destination');
    remark = text(value, 'remark');
    dataTime = optionalTime(value['data_time']);
  }
  late final DateTime time;
  late final String kind;
  late final String platform;
  late final String destination;
  late final String remark;
  late final DateTime? dataTime;
}

class TransitRoute {
  TransitRoute(Object? raw) {
    final value = object(raw);
    id = text(value, 'id');
    mode = text(value, 'mode');
    operatorCode = text(value, 'operator');
    route = text(value, 'route');
    stop = text(value, 'stop');
    destination = text(value, 'destination');
    state = text(value, 'state');
    fetchedAt = optionalTime(value['fetched_at']);
    delayed = value['delayed'] == true;
    if (value['map_url'] != null) {
      final uri = Uri.tryParse(text(value, 'map_url'));
      if (uri == null || uri.scheme != 'https' || uri.host != 'www.google.com' ||
          uri.path != '/maps/search/' || uri.userInfo.isNotEmpty) {
        throw const FormatException('Invalid stop map');
      }
      mapUrl = uri;
    }
    departures = items(value, 'departures', TransitDeparture.new);
  }
  late final String id, mode, operatorCode, route, stop, destination, state;
  late final DateTime? fetchedAt;
  late final bool delayed;
  Uri? mapUrl;
  late final List<TransitDeparture> departures;
}

class TransitData {
  TransitData(Object? raw) {
    final value = object(raw);
    serverTime = requiredTime(value['server_time']);
    routes = items(value, 'items', TransitRoute.new);
  }
  late final DateTime serverTime;
  late final List<TransitRoute> routes;
  final Stopwatch _age = Stopwatch()..start();
  DateTime get now => serverTime.add(_age.elapsed);
  bool fresh(TransitRoute route) => route.fetchedAt != null &&
      now.difference(route.fetchedAt!).inSeconds < 120;
}

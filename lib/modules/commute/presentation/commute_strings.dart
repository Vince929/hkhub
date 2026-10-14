import 'package:flutter/material.dart';

import '../data/commute_models.dart';

/// Cantonese follows the app's Traditional Chinese written copy convention.
class CommuteStrings {
  CommuteStrings(Locale locale) : _index = locale.languageCode == 'en' ? 2
      : locale.languageCode == 'zh' && locale.scriptCode != 'Hant' ? 0 : 1;
  final int _index;
  String _text(String hans, String hant, String en) => [hans, hant, en][_index];

  String get title => _text('港深通勤', '港深通勤', 'HK–Shenzhen commute');
  String get direction => _text('深圳 ↔ 香港', '深圳 ↔ 香港', 'Shenzhen ↔ Hong Kong');
  String get selectPort => _text('从哪个口岸过关？', '從哪個口岸過關？', 'Which crossing today?');
  String ports(int count) => _text('$count 个口岸', '$count 個口岸', '$count crossings');
  String get updateInterval => _text('每 15 分钟更新', '每 15 分鐘更新', 'Updates every 15 minutes');
  String get queueTitle => _text('口岸等候情况', '口岸等候情況', 'Border waiting conditions');
  String directionName(String value) => value == 'arrival'
      ? _text('入境', '入境', 'Arrival')
      : _text('出境', '出境', 'Departure');
  String get notice => _text('仅供参考，分别显示香港入境与出境轮候情况，不代表全程过关时长。', '僅供參考，分別顯示香港入境與出境輪候情況，不代表全程過關時長。', 'Reference only. Shows Hong Kong arrival and departure queues, not total crossing time.');
  String get source => _text('来源：香港入境事务处 · 标称每 15 分钟更新', '來源：香港入境事務處 · 標稱每 15 分鐘更新', 'Source: HK Immigration Department. Published update interval: 15 minutes.');
  String get refresh => _text('刷新', '重新整理', 'Refresh');
  String get retry => _text('重试', '重試', 'Retry');
  String get loadFailed => _text('暂时无法获取资料，请检查连接后重试。', '暫時無法取得資料，請檢查連線後重試。', 'Cannot load this data. Check your connection and retry.');
  String get saveFailed => _text('本机偏好保存失败，请重试。', '本機偏好保存失敗，請重試。', 'Could not save this device preference. Please retry.');
  String get favorite => _text('收藏', '收藏', 'Save');
  String get unfavorite => _text('取消收藏', '取消收藏', 'Unsave');
  String mode(String mode) => mode == 'mtr' ? _text('港铁', '港鐵', 'MTR') : _text('巴士', '巴士', 'Bus');
  String get transitTitle => _text('香港侧主要接驳', '香港側主要接駁', 'Connections on the Hong Kong side');
  String get transitNotice => _text('港铁为本站开出时间；巴士为本站到站预报或原定班次。不是抵达目的地时间，也不保证赶得上。', '港鐵為本站開出時間；巴士為本站到站預報或原定班次。不是抵達目的地時間，也不保證趕得上。', 'MTR times are departures from this station. Bus times are arrivals here or scheduled services, not arrival at your destination. Connections are not guaranteed.');
  String get noDepartures => _text('暂无班次资料，不代表线路停运。', '暫無班次資料，不代表路線停運。', 'No departure information. This does not mean the route is suspended.');
  String get transitUnavailable => _text('接驳资料暂不可用', '接駁資料暫不可用', 'Connection data unavailable');
  String get delay => _text('港铁报告班次延误', '港鐵報告班次延誤', 'MTR reports delays');
  String get map => _text('查看上车位置', '查看上車位置', 'Boarding location');
  String get mapFailed => _text('无法打开地图，请按上车站名查询。', '無法開啟地圖，請按上車站名查詢。', 'Could not open the map. Search for the boarding stop name.');
  String get historyTitle => _text('近一周同时段参考', '近一週同時段參考', 'Same time, previous seven days');
  String get historyNotice => _text('前七个自然日同一香港时间窗。只比较等级，不比较精确分钟；节假日差异不作预测。', '前七個自然日同一香港時間窗。只比較等級，不比較精確分鐘；節假日差異不作預測。', 'The same Hong Kong time slot on the previous seven calendar days. Levels, not exact minutes; holiday differences are not forecasts.');
  String get noCurrentSlot => _text('当前时间窗暂无有效观测，暂不生成对比结论。', '目前時間窗暫無有效觀測，暫不生成對比結論。', 'No valid observation for the current slot. No comparison is made.');
  String get refreshHistory => _text('时间窗已切换，请刷新比较。', '時間窗已切換，請重新整理比較。', 'The time slot changed. Refresh the comparison.');
  String coverage(int count) => _text('有效观测 $count/7 天', '有效觀測 $count/7 天', '$count/7 valid days');
  String comparison(Comparison value) => _text(
    '在 ${value.lower + value.same + value.higher} 个有效日中，比 ${value.lower} 天等级低，与 ${value.same} 天相同，比 ${value.higher} 天等级高。',
    '在 ${value.lower + value.same + value.higher} 個有效日中，比 ${value.lower} 天等級低，與 ${value.same} 天相同，比 ${value.higher} 天等級高。',
    'Of ${value.lower + value.same + value.higher} valid days: lower than ${value.lower}, same as ${value.same}, higher than ${value.higher}.');
  String weekly(String position, int? code) => switch (position) {
    'lowest' => _text('近一周最低等级', '近一週最低等級', 'Lowest level in the comparison week'),
    'joint_lowest' => _text('近一周并列最低等级', '近一週並列最低等級', 'Joint-lowest level in the comparison week'),
    'highest' => _text('近一周最高等级', '近一週最高等級', 'Highest level in the comparison week'),
    'joint_highest' => _text('近一周并列最高等级', '近一週並列最高等級', 'Joint-highest level in the comparison week'),
    'same' => code == 0 ? _text('均为正常等级', '均為正常等級', 'All observations are normal')
        : _text('与前七天等级均相同', '與前七天等級均相同', 'Same level as all seven previous days'),
    _ => '',
  };
  String queueLabel(QueueStatus queue, {String? reason}) => switch (reason ?? queue.reason) {
    'available' => switch (queue.code) {
      0 => _text('正常', '正常', 'Normal'),
      1 => _text('繁忙', '繁忙', 'Busy'),
      _ => _text('非常繁忙', '非常繁忙', 'Very busy'),
    },
    'maintenance' => _text('系统维护', '系統維護', 'System maintenance'),
    'closed' => _text('非服务时段', '非服務時段', 'Outside service hours'),
    'stale' => _text('资料已过期', '資料已過期', 'Data is stale'),
    'fetch_failed' => _text('获取失败', '取得失敗', 'Fetch failed'),
    'invalid' => _text('资料异常', '資料異常', 'Invalid data'),
    'missing' => _text('暂无数据', '暫無數據', 'No data'),
    _ => _text('尚未采集', '尚未採集', 'Not yet collected'),
  };
  String wait(int code) {
    final minutes = code == 0 ? 30 : 45;
    return code == 2 ? _text('$minutes 分钟或以上', '$minutes 分鐘或以上', '$minutes minutes or more')
        : _text('少于 $minutes 分钟', '少於 $minutes 分鐘', 'Under $minutes minutes');
  }
  String operatorName(String value) => switch (value) {
    'MTR' => mode('mtr'),
    'KMB' => _text('九巴', '九巴', 'KMB'),
    'CTB' => _text('城巴', '城巴', 'Citybus'),
    _ => value,
  };
  String departureKind(String kind) => switch (kind) {
    'departure' => _text('开出', '開出', 'Departs'),
    'scheduled_arrival' => _text('原定班次', '原定班次', 'Scheduled service'),
    _ => _text('预计到站', '預計到站', 'Estimated arrival'),
  };
  String platform(String number) => _text('$number 站台', '$number 月台', 'Platform $number');
  String destination(String name) => _text('往 $name', '往 $name', 'To $name');
  String fetched(DateTime value) => _text('最近更新 ${clock(value)}', '最近更新 ${clock(value)}', 'Updated ${clock(value)}');
  String clock(DateTime value) {
    final local = value.toUtc().add(const Duration(hours: 8));
    String two(int number) => '$number'.padLeft(2, '0');
    return '${two(local.month)}/${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
  }
  String timeOnly(DateTime value) => clock(value).split(' ').last;

  // Single-direction nudge to the residency planner (D22); not a commute metric.
  String get residencyHint => _text(
    '通勤久了，别忘了永居进度',
    '通勤久了，別忘了永居進度',
    'Commuting a lot? Check your residency progress',
  );
}

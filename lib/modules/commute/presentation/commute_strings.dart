import 'package:flutter/material.dart';

import '../../../app/network/api_exception.dart';
import '../data/commute_models.dart';

/// Module copy is kept together; Cantonese uses Traditional written Chinese.
///
/// The official "usually under N minutes" ranges are presentation copy, so updating a
/// published threshold only needs an app release and never a server contract change.
class CommuteStrings {
  CommuteStrings(Locale locale)
      : _index = locale.languageCode == 'en' ? 2
            : locale.languageCode == 'zh' && locale.scriptCode != 'Hant' ? 0 : 1;

  final int _index;
  String _text(String hans, String hant, String en) => [hans, hant, en][_index];

  String get title => _text('港深跨境通勤', '港深跨境通勤', 'Cross-border commute');
  String get subtitle => _text('口岸轮候与出关接驳', '口岸輪候與出關接駁', 'Queue status and onwards connections');
  String get listDisclaimer => _text(
    '轮候情况来自香港入境事务处开放数据，仅反映港方出入境手续，不代表全程过关时间。',
    '輪候情況來自香港入境事務處開放數據，僅反映港方出入境手續，不代表全程過關時間。',
    'Queue status comes from Immigration Department open data. It covers Hong Kong clearance only, not the whole crossing.',
  );

  String get audienceLabel => _text('你的身份', '你的身分', 'Your status');
  String get audienceResident => _text('香港居民', '香港居民', 'Hong Kong resident');
  String get audienceVisitor => _text('访港旅客', '訪港旅客', 'Visitor');
  String get audienceUnselected => _text(
    '尚未选择身份，已并列显示两类轮候情况。',
    '尚未選擇身分，已並列顯示兩類輪候情況。',
    'No status chosen yet, so both queue estimates are shown.',
  );

  String get sortByLevel => _text('按轮候等级排序', '按輪候等級排序', 'Sort by queue level');
  String get refresh => _text('刷新', '重新整理', 'Refresh');
  String get retry => _text('重试', '重試', 'Retry');
  String get loadFailed => _text('无法获取口岸信息，请稍后重试。', '無法取得口岸資訊，請稍後重試。', 'Port information is unavailable. Please try again later.');
  String get networkError => _text('网络连接失败，请检查网络后重试。', '網絡連線失敗，請檢查網絡後重試。', 'Connection failed. Check your network and try again.');
  String get invalidResponse => _text('服务器返回了非预期的数据。', '伺服器回傳了非預期的數據。', 'The server returned unexpected data.');
  String get notFound => _text('找不到这个口岸。', '搵唔到這個口岸。', 'This control point was not found.');
  String get preferenceSaveFailed => _text('偏好未能保存，请重试。', '偏好未能儲存，請重試。', 'Your preference could not be saved. Please try again.');

  /// Maps a client-side failure to copy the traveller can act on. A localized server
  /// message is preferred when the server already explained the problem.
  String errorMessage(Object error) {
    if (error is ApiException) {
      return switch (error.code) {
        'network_error' || 'invalid_certificate' || 'timeout' => networkError,
        'invalid_response' => invalidResponse,
        _ => error.isServerMessage && error.message.isNotEmpty ? error.message : loadFailed,
      };
    }
    return loadFailed;
  }

  String portName(String portCode) => switch (portCode) {
    'LWS' => _text('罗湖口岸', '羅湖口岸', 'Lo Wu Port'),
    'LSC' => _text('福田口岸', '福田口岸', 'Futian Port'),
    'SBC' => _text('深圳湾口岸', '深圳灣口岸', 'Shenzhen Bay Port'),
    _ => portCode,
  };

  String? stationName(String portCode) => switch (portCode) {
    'LWS' => _text('罗湖站', '羅湖站', 'Lo Wu Station'),
    'LSC' => _text('落马洲站', '落馬洲站', 'Lok Ma Chau Station'),
    _ => null,
  };

  /// Paired naming, because the Hong Kong side of a crossing has its own name.
  String connectionLabel(String portCode) {
    final station = stationName(portCode);
    return station == null ? portName(portCode) : '${portName(portCode)} ↔ $station';
  }

  String get favouriteAdd => _text('收藏口岸', '收藏口岸', 'Favourite port');
  String get favouriteRemove => _text('取消收藏', '取消收藏', 'Remove favourite');
  String get favouriteRoute => _text('收藏路线', '收藏路線', 'Favourite route');

  String statusLabel(QueueStatus status) => switch (status) {
    QueueStatus.normal => _text('正常', '正常', 'Normal'),
    QueueStatus.busy => _text('繁忙', '繁忙', 'Busy'),
    QueueStatus.veryBusy => _text('非常繁忙', '非常繁忙', 'Very busy'),
    QueueStatus.maintenance => _text('数据系统维护中', '數據系統維護中', 'Data system under maintenance'),
    QueueStatus.nonService => _text('非服务时段', '非服務時段', 'Outside service hours'),
    QueueStatus.unknown => _text('暂无数据', '暫無數據', 'No data'),
  };

  /// Official ranges differ per audience for the same code; never shown as a countdown.
  String? statusDetail(QueueStatus status, CommuteAudience audience) {
    final resident = audience == CommuteAudience.resident;
    return switch (status) {
      QueueStatus.normal => resident
          ? _text('通常少于 15 分钟', '通常少於 15 分鐘', 'Usually under 15 minutes')
          : _text('通常少于 30 分钟', '通常少於 30 分鐘', 'Usually under 30 minutes'),
      QueueStatus.busy => resident
          ? _text('通常少于 30 分钟', '通常少於 30 分鐘', 'Usually under 30 minutes')
          : _text('通常少于 45 分钟', '通常少於 45 分鐘', 'Usually under 45 minutes'),
      QueueStatus.veryBusy => resident
          ? _text('通常 30 分钟或以上', '通常 30 分鐘或以上', 'Usually 30 minutes or more')
          : _text('通常 45 分钟或以上', '通常 45 分鐘或以上', 'Usually 45 minutes or more'),
      _ => null,
    };
  }

  String get queueScope => _text('港方入境轮候', '港方入境輪候', 'Hong Kong inbound queue');
  String get queueNotWholeTrip => _text(
    '仅指港方出入境手续轮候，不含深圳侧流程。',
    '僅指港方出入境手續輪候，不含深圳側流程。',
    'Hong Kong clearance only; it excludes the Shenzhen side.',
  );
  String get systemMaintenanceNote => _text(
    '只是官方数据系统维护，不代表口岸停止通关。',
    '只是官方數據系統維護，不代表口岸停止通關。',
    'This is the official data system, not the control point, being under maintenance.',
  );
  String get nonServiceNote => _text(
    '当前为非服务时段，不代表口岸永久关闭。',
    '目前為非服務時段，不代表口岸永久關閉。',
    'Outside service hours does not mean the control point has closed permanently.',
  );

  String freshnessLabel(QueueFreshness freshness) => switch (freshness) {
    QueueFreshness.fresh => _text('刚刚更新', '剛剛更新', 'Recently updated'),
    QueueFreshness.stale => _text('数据已过时', '數據已過時', 'Data is out of date'),
    QueueFreshness.missing => _text('暂无数据', '暫無數據', 'No data'),
  };

  String fetchedAt(DateTime? time) => time == null
      ? _text('暂无获取记录', '暫無獲取記錄', 'No fetch recorded')
      : _text('最近获取：${hkClock(time)}', '最近獲取：${hkClock(time)}', 'Last fetched: ${hkClock(time)}');

  /// Hong Kong keeps UTC+8 all year, so times are rendered in Hong Kong time and never
  /// depend on the device time zone.
  String hkClock(DateTime time) {
    final local = time.toUtc().add(const Duration(hours: 8));
    return hhmm(local.hour * 60 + local.minute);
  }

  String hhmm(int minutesOfDay) {
    final hour = (minutesOfDay ~/ 60).toString().padLeft(2, '0');
    final minute = (minutesOfDay % 60).toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String shortDate(String hkDate) => hkDate.length >= 10 ? hkDate.substring(5) : hkDate;

  String get historyTitle => _text('近一周同时段参考', '近一週同時段參考', 'Same time on the past week');
  String get historyIntro => _text(
    '与过去 7 个自然日的同一 15 分钟时段比较，只比官方轮候等级，不换算成分钟。自然日不等于工作日，假期可能不可比。',
    '與過去 7 個自然日的同一 15 分鐘時段比較，只比官方輪候等級，不換算成分鐘。自然日不等於工作日，假期可能不可比。',
    'Compared with the same 15-minute window on the past seven calendar days. Only official queue levels are compared, never converted to minutes. Calendar days are not working days, so holidays may not be comparable.',
  );
  String historySlot(int slot) {
    final start = slot * 15;
    return _text(
      '香港时间 ${hhmm(start)}–${hhmm(start + 14)}',
      '香港時間 ${hhmm(start)}–${hhmm(start + 14)}',
      'Hong Kong time ${hhmm(start)}–${hhmm(start + 14)}',
    );
  }

  String get historyAccumulating => _text(
    '数据积累中，暂无可对比的历史记录。',
    '數據累積中，暫無可對比的歷史記錄。',
    'Still collecting data, so there is no history to compare yet.',
  );
  String get historyNoComparison => _text(
    '当前没有可比较的轮候等级，暂不作对比。',
    '目前沒有可比較的輪候等級，暫不作對比。',
    'The current level cannot be compared, so no comparison is shown.',
  );
  String get historyAllNormal => _text(
    '与过去同一时段均为正常等级。',
    '與過去同一時段均為正常等級。',
    'Every compared day was normal at this time.',
  );
  String get historyNoRecord => _text('无记录', '無記錄', 'No record');
  String get historyUnrecognised => _text('未识别的状态', '未識別的狀態', 'Unrecognised status');

  String historyDayStatus(QueueStatus status, int? statusCode) {
    if (statusCode == null) return historyNoRecord;
    if (status == QueueStatus.unknown) return historyUnrecognised;
    return statusLabel(status);
  }

  String historyValidDays(int valid, int total) => _text(
    '有效记录 $valid/$total 天',
    '有效記錄 $valid/$total 天',
    '$valid of $total days recorded',
  );
  String historyRelative(int lower, int same, int higher) => _text(
    '比 $lower 天轮候等级低，与 $same 天相同，比 $higher 天高。',
    '比 $lower 天輪候等級低，與 $same 天相同，比 $higher 天高。',
    'Lower than $lower days, the same as $same, higher than $higher.',
  );
  String get historyLowest => _text('处于并列最低轮候等级。', '處於並列最低輪候等級。', 'This is the joint lowest level in the week.');
  String get historyHighest => _text('处于并列最高轮候等级。', '處於並列最高輪候等級。', 'This is the joint highest level in the week.');
  String get historyCurrent => _text('当前', '目前', 'Now');
  String get historyNeedsAudience => _text(
    '先选择身份，才能查看与你对应的近一周对比。',
    '先選擇身分，才能查看與你對應的近一週對比。',
    'Choose your status to see the past-week comparison for it.',
  );

  String get transitTitle => _text('香港侧主要接驳', '香港側主要接駁', 'Hong Kong-side connections');
  String get transitEstimatedNote => _text(
    '只列出已核实的香港侧主要接驳，且不代表排完队一定赶得上这一班。',
    '只列出已核實的香港側主要接駁，且不代表排完隊一定趕得上這一班。',
    'Only verified Hong Kong-side connections are listed, and clearing the queue in time for one is not guaranteed.',
  );
  String get transitPlatform => _text('站台', '月台', 'Platform');
  String get transitTo => _text('往', '往', 'To');

  /// Display aid for the station codes the MTR returns as a destination. Unknown codes
  /// are shown verbatim rather than guessed, so an unmapped code is never mislabelled.
  static const _stationNames = {
    'ADM': ('金钟', '金鐘', 'Admiralty'),
    'EXC': ('会展', '會展', 'Exhibition Centre'),
    'HUH': ('红磡', '紅磡', 'Hung Hom'),
    'MKK': ('旺角东', '旺角東', 'Mong Kok East'),
    'KOT': ('九龙塘', '九龍塘', 'Kowloon Tong'),
    'TAW': ('大围', '大圍', 'Tai Wai'),
    'SHT': ('沙田', '沙田', 'Sha Tin'),
    'FOT': ('火炭', '火炭', 'Fo Tan'),
    'RAC': ('马场', '馬場', 'Racecourse'),
    'UNI': ('大学', '大學', 'University'),
    'TAP': ('大埔墟', '大埔墟', 'Tai Po Market'),
    'TWO': ('太和', '太和', 'Tai Wo'),
    'FAN': ('粉岭', '粉嶺', 'Fanling'),
    'SHS': ('上水', '上水', 'Sheung Shui'),
    'LOW': ('罗湖', '羅湖', 'Lo Wu'),
    'LMC': ('落马洲', '落馬洲', 'Lok Ma Chau'),
  };

  String destinationName(String code) {
    final names = _stationNames[code.toUpperCase()];
    return names == null ? code : _text(names.$1, names.$2, names.$3);
  }

  String transitMinutes(int minutes) => _text('$minutes 分钟后开出', '$minutes 分鐘後開出', 'Departs in $minutes min');

  /// The official schedule time is reported in Hong Kong local time. Only the clock
  /// part is shown, and an unexpected format falls back to the reported value.
  String reportedClock(String reported) {
    final parts = reported.split(' ');
    return parts.length == 2 ? parts[1] : reported;
  }

  String get transitNoMinutes => _text('已公布时间', '已公布時間', 'Published time');
  String transitTimeTypeLabel(String timeType) => switch (timeType) {
    'D' => _text('开出', '開出', 'Departure'),
    'A' => _text('到达', '到達', 'Arrival'),
    _ => transitNoMinutes,
  };
  String get transitLoading => _text('正在获取班次…', '正在取得班次…', 'Loading connections…');
  String get transitUnavailable => _text('实时班次暂时无法获取，请稍后重试。', '實時班次暫時無法取得，請稍後重試。', 'Live connections are unavailable right now. Please try again later.');
  String get transitUnverified => _text('此口岸暂未核实可用的香港侧接驳。', '此口岸暫未核實可用的香港側接駁。', 'No verified Hong Kong-side connection for this control point yet.');
  String get transitEmpty => _text('暂时没有已公布的班次。', '暫時沒有已公布的班次。', 'No upcoming connections are published right now.');
  String transitObservedAt(DateTime time) => _text(
    '班次时间：${hkClock(time)}',
    '班次時間：${hkClock(time)}',
    'Schedule time: ${hkClock(time)}',
  );
}

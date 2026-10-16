import 'package:flutter/material.dart';

import '../data/rent_models.dart';

class RentStrings {
  RentStrings(Locale locale) : _index = locale.languageCode == 'en' ? 2
      : locale.languageCode == 'zh' && locale.scriptCode != 'Hant' ? 0 : 1;
  final int _index;
  String _text(String hans, String hant, String en) => [hans, hant, en][_index];

  String get title => _text('租金趋势', '租金趨勢', 'Rental trends');
  String get scope => _text('私人住宅 · 月度统计参考', '私人住宅 · 月度統計參考', 'Private domestic · monthly statistics');
  String get refresh => _text('刷新', '重新整理', 'Refresh');
  String get retry => _text('重试', '重試', 'Retry');
  String get loadFailed => _text('无法读取租金数据，请检查连接后重试。', '無法讀取租金數據，請檢查連線後重試。', 'Cannot load rental data. Check your connection and retry.');
  String get seriesUnavailable => _text('该系列不可用，请刷新或重新选择。', '此系列無法使用，請重新整理或選擇。', 'This series is unavailable. Refresh or select again.');
  String get baselineUnavailable => _text('共同起点缺少数据，请改用原值或更换区间。', '共同起點缺少數據，請改用原值或更換區間。', 'No common starting value. Use original values or another interval.');
  String get incompatible => _text('这些系列的统计口径不同，无法比较。', '這些系列的統計口徑不同，無法比較。', 'These statistical definitions are incompatible.');
  String get selectionReset => _text('新指标没有对应系列，已切换至该指标默认系列。', '新指標沒有對應系列，已切換至該指標預設系列。', 'No matching series for this metric. Its default series is selected.');
  String get notReady => _text('租金数据尚未就绪', '租金數據尚未就緒', 'Rental data is not ready');
  String get notReadyDetail => _text('首次采集完成后即可查看。刷新只读取服务端数据，不触发官方抓取。', '首次採集完成後即可查看。重新整理只讀取伺服器數據，不觸發官方擷取。', 'Available after the first collection. Refresh reads our server; it does not fetch the official source.');
  String metric(String value) => value == 'rental_index'
      ? _text('租金指数', '租金指數', 'Rental index') : _text('平均租金', '平均租金', 'Average rent');
  String get mainSeries => _text('主系列', '主系列', 'Primary series');
  String get addComparison => _text('添加比较', '加入比較', 'Add comparison');
  String get comparisonHint => _text('最多三条；仅列出口径兼容系列', '最多三條；只列出口徑兼容系列', 'Up to three series with compatible definitions');
  String get remove => _text('移除比较', '移除比較', 'Remove comparison');
  String get original => _text('官方原值', '官方原值', 'Original values');
  String get relative => _text('起点＝100', '起點＝100', 'Start = 100');
  String get relativeNotice => _text('相对变化按所选区间起点归一化，不是官方指数基期。', '相對變化按所選區間起點歸一化，不是官方指數基期。', 'Relative values use the interval start as 100, not the official index base.');
  String get relativeUnit => _text('相对值（起点＝100）', '相對值（起點＝100）', 'Relative value (start = 100)');
  String years(int value) => _text('近 $value 年', '近 $value 年', '$value year${value == 1 ? '' : 's'}');
  String through(String month) => _text('统计截至 $month', '統計截至 $month', 'Statistics through $month');
  String get mom => _text('较上月', '較上月', 'Month on month');
  String get yoy => _text('较去年同月', '較去年同月', 'Year on year');
  String get period => _text('区间变化', '區間變化', 'Interval change');
  String get unavailable => _text('暂无数据', '暫無數據', 'No data');
  String get partial => _text('区间内有缺值，曲线已断开；不会补零或缩短端点。', '區間內有缺值，曲線已斷開；不會補零或縮短端點。', 'Missing months create gaps. No zero filling or substituted endpoints.');
  String historyStarts(String month) => _text('历史数据始于 $month，早于覆盖范围的月份不补值。', '歷史數據始於 $month，早於覆蓋範圍的月份不補值。', 'History starts at $month. Earlier months are not filled.');
  String get syncFailed => _text('最近同步失败，正在展示最近有效快照。', '最近同步失敗，正在顯示最近有效快照。', 'Last sync failed. Showing the last valid snapshot.');
  String get staleResponse => _text('刷新失败，以下为本次会话上一次结果，并非新响应。请重试。', '重新整理失敗，以下為本次工作階段上一次結果，並非新回應。請重試。', 'Refresh failed. The result below is from earlier in this session, not a new response. Please retry.');
  String get refreshing => _text('正在刷新，保留当前结果', '正在重新整理，保留目前結果', 'Refreshing; retaining the current result');
  String get selectedMonth => _text('查看月份', '查看月份', 'Inspect month');
  String get table => _text('月度数据', '月度數據', 'Monthly data');
  String get month => _text('月份', '月份', 'Month');
  String get sourceTitle => _text('数据与统计口径', '數據與統計口徑', 'Data and definitions');
  String get checked => _text('最近成功检查', '最近成功檢查', 'Last successful check');
  String get changed => _text('最近快照变化', '最近快照變更', 'Last snapshot change');
  String get attempted => _text('最近尝试', '最近嘗試', 'Last attempt');
  String get sourceUpdated => _text('源更新时间', '來源更新時間', 'Source update time');
  String get sourceUnknown => _text('源未提供', '來源未提供', 'Not provided by source');
  String get official => _text('官方数据目录', '官方數據目錄', 'Official dataset');
  String get dictionary => _text('官方数据字典', '官方數據字典', 'Official dictionary');
  String get terms => _text('数据使用条款', '數據使用條款', 'Data terms of use');
  String get linkFailed => _text('无法打开来源链接，请稍后重试。', '無法開啟來源連結，請稍後重試。', 'Cannot open the source link. Please retry later.');
  String get averageWarning => _text('平均租金会受各期成交物业特征影响，不一定代表市场租金普遍变化。衡量趋势请优先看租金指数。', '平均租金會受各期成交物業特徵影響，不一定代表市場租金普遍變化。衡量趨勢請優先看租金指數。', 'Average rents vary with the properties analysed in each period, not necessarily general market changes. Use rental indices to measure trends.');
  String get areaBasis => _text('面积类别按实用面积划分，不对应卧室数。', '面積類別按實用面積劃分，不對應睡房數。', 'Classes use saleable area, not bedroom count.');
  String get valuationNotice => _text('仅限私人住宅统计，不覆盖所有租赁市场，也不是屋苑、片区或单套单位估价；不预测或提供租赁建议。', '只限私人住宅統計，不涵蓋所有租賃市場，亦非屋苑、片區或單一單位估價；不預測或提供租賃建議。', 'Private domestic statistics only, not the entire rental market or valuations of estates, neighbourhoods or individual homes. No predictions or rental advice.');
  String get attribution => _text('来源：香港特别行政区政府差饷物业估价署，经 DATA.GOV.HK 提供。数据知识产权归政府及有关机构所有；本应用非官方产品。', '來源：香港特別行政區政府差餉物業估價署，經 DATA.GOV.HK 提供。數據知識產權屬政府及有關機構所有；本應用並非官方產品。', 'Source: HKSAR Government, Rating and Valuation Department, via DATA.GOV.HK. Intellectual property belongs to the Government and relevant organisations. This is not an official app.');
  String get flagsNotice => _text('P：暂定数字；Z：少于 20 宗交易；「—」：未接获交易记录。保留源标记，历史值可能修订。', 'P：暫定數字；Z：少於 20 宗交易；「—」：未接獲交易記錄。保留來源標記，歷史值可能修訂。', 'P: provisional. Z: fewer than 20 transactions. “—”: no transaction records received. Source flags are retained; history may be revised.');

  String region(String code) => switch (code) {
    'hk' => _text('港岛', '港島', 'Hong Kong Island'),
    'kowloon' => _text('九龙', '九龍', 'Kowloon'),
    'nt' => _text('新界', '新界', 'New Territories'),
    _ => _text('全港', '全港', 'Territory-wide'),
  };
  String area(String code) => switch (code) {
    'A' => 'A · <40 m²', 'B' => 'B · 40–69.9 m²', 'C' => 'C · 70–99.9 m²',
    'D' => 'D · 100–159.9 m²', 'E' => 'E · ≥160 m²',
    'ABC' => 'A–C · <100 m²', 'DE' => 'D–E · ≥100 m²',
    _ => _text('所有类别', '所有類別', 'All classes'),
  };
  String seriesName(RentDefinition definition) => '${region(definition.region)} / ${area(definition.classCode)}';
  String unit(RentDefinition definition) => definition.unit == 'index'
      ? _text('指数（${definition.base}）', '指數（${definition.base}）', 'Index (${definition.base})')
      : _text('港币 / m²', '港幣 / m²', 'HKD / m²');
  String flag(String raw) => [
    if (raw.contains('P')) _text('暂定 P', '暫定 P', 'Provisional P'),
    if (raw.contains('Z')) _text('少于 20 宗 Z', '少於 20 宗 Z', 'Under 20 transactions Z'),
  ].join(' · ');
  String number(double? value, {bool index = true}) => value == null ? '—' : value.toStringAsFixed(index ? 1 : 0);
  String percent(double? value) {
    if (value == null) return '—';
    if (value == 0) return '0.00%';
    final sign = value > 0 ? '+' : '−';
    return value.abs() < 0.01 ? '$sign<0.01%' : '$sign${value.abs().toStringAsFixed(2)}%';
  }
  String direction(double value) => value > 0 ? _text('上涨', '上升', 'Up')
      : value < 0 ? _text('下降', '下降', 'Down') : _text('持平', '持平', 'Unchanged');
  String insight(RentSeries series) => series.yoy.percent == null ? through(series.latestMonth)
      : _text('较去年同月${direction(series.yoy.percent!)} ${percent(series.yoy.percent)}。',
          '較去年同月${direction(series.yoy.percent!)} ${percent(series.yoy.percent)}。',
          '${direction(series.yoy.percent!)} ${percent(series.yoy.percent)} versus the same month last year.');
  String missing(String? reason) => reason == 'no_transactions'
      ? _text('未接获交易记录', '未接獲交易記錄', 'No transaction records') : unavailable;
  String time(DateTime? value) {
    if (value == null) return '—';
    final hk = value.toUtc().add(const Duration(hours: 8));
    String two(int n) => '$n'.padLeft(2, '0');
    return '${hk.year}-${two(hk.month)}-${two(hk.day)} ${two(hk.hour)}:${two(hk.minute)} HKT';
  }
}

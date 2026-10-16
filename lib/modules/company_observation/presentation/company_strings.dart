import 'package:flutter/material.dart';

class CompanyStrings {
  CompanyStrings(Locale locale) : _index = locale.languageCode == 'en' ? 2
      : locale.languageCode == 'zh' && locale.scriptCode != 'Hant' ? 0 : 1;
  final int _index;
  String _text(String hans, String hant, String en) => [hans, hant, en][_index];

  String get title => _text('香港新增登记观察', '香港新增登記觀察', 'Hong Kong registration watch');
  String get shortTitle => _text('新增登记观察', '新增登記觀察', 'Registration watch');
  String get description => _text('本期成立／迁册公司名单', '本期成立／遷冊公司名單', 'Incorporated or re-domiciled companies in this period');
  String get intro => _text('看看香港本期新登记的公司', '看看香港本期新登記的公司', 'See companies newly registered in Hong Kong');
  String get allCompanies => _text('查看公司名单', '查看公司名單', 'Browse company names');
  String get source => _text('官方周报来源', '官方週報來源', 'Official weekly source');
  String get sourceFailed => _text('无法打开来源链接，请稍后重试。', '無法開啟來源連結，請稍後重試。', 'Could not open the source link. Please retry.');
  String get search => _text('搜索本期中英文公司名称', '搜尋本期中英文公司名稱', 'Search names in this period');
  String get searchNotice => _text('仅搜索本站本期已核实资料，不代表查遍香港全部公司。', '僅搜尋本站本期已核實資料，不代表查遍香港全部公司。', 'Searches verified records for this period, not all Hong Kong companies.');
  String get noResults => _text('没有匹配记录，请尝试其他名称。', '沒有匹配記錄，請嘗試其他名稱。', 'No matching records. Try another name.');
  String get noCompanies => _text('本期暂无可展示的成立／迁册记录，不代表本期没有此类登记。', '本期暫無可展示的成立／遷冊記錄，不代表本期沒有此類登記。', 'No incorporation or re-domiciliation records are available here. This does not imply none occurred.');
  String get noPeriods => _text('官方资料尚未接入，请稍后刷新。', '官方資料尚未接入，請稍後重新整理。', 'Official records have not been collected yet. Refresh later.');
  String get retry => _text('重试', '重試', 'Retry');
  String get refresh => _text('刷新', '重新整理', 'Refresh');
  String get failed => _text('资料加载失败，请检查连接后重试。', '資料載入失敗，請檢查連線後重試。', 'Could not load records. Check your connection and retry.');
  String get superseded => _text('资料或统计口径已更新，请返回概览刷新后查看新版本。', '資料或統計口徑已更新，請返回概覽重新整理後查看新版本。', 'The data or counting scope has changed. Return to the overview and refresh.');
  String get more => _text('加载更多', '載入更多', 'Load more');
  String get back => _text('返回概览', '返回概覽', 'Back to overview');
  String get earlierPeriod => _text('最近结束周期资料未齐；当前显示以下较早周期。', '最近結束週期資料未齊；目前顯示以下較早週期。', 'The latest ended period is not complete. An earlier period is shown below.');
  String get stale => _text('最近获取失败，保留此前已核实资料及获取时间。', '最近取得失敗，保留此前已核實資料及取得時間。', 'The latest fetch failed. Previously verified records and their fetch times are retained.');
  String get populationNotice => _text(
    '包括本期新成立及迁册到香港的公司，不包括仅更名的记录。官方合并日期列无法区分成立与迁册；迁册不代表公司新成立或刚开始经营。',
    '包括本期新成立及遷冊到香港的公司，不包括僅更名的記錄。官方合併日期欄無法區分成立與遷冊；遷冊不代表公司新成立或剛開始經營。',
    'Includes companies incorporated or re-domiciled to Hong Kong in this period, excluding name-only changes. The combined official date column cannot separate the two. Re-domiciliation is not a new company or business birth.');
  String get legacyPopulationNotice => _text('当前仍为旧版纯新成立口径，尚未包含迁册；等待后台重建后刷新查看。', '目前仍為舊版純新成立口徑，尚未包含遷冊；等候後台重建後重新整理查看。', 'This is a legacy incorporation-only snapshot. Refresh after the worker rebuilds it to include re-domiciliation.');
  String get combinedDate => _text('旧版口径因成立与迁册日期合并而排除这些记录；后台将从已保存的 CSV 按成立／迁册合并口径重建。', '舊版口徑因成立與遷冊日期合併而排除這些記錄；後台將從已儲存的 CSV 按成立／遷冊合併口徑重建。', 'The legacy scope excluded combined-date records. The worker will rebuild the incorporation/re-domiciliation population from stored CSV files.');
  String get partial => _text('资料未齐，仅展示已核实记录，完整总量待资料齐全。', '資料未齊，僅展示已核實記錄，完整總量待資料齊全。', 'Incomplete sources. Only verified records are shown; full totals await complete sources.');
  String get attribution => _text('资料来源：香港特别行政区政府公司注册处及 DATA.GOV.HK；资料知识产权归原提供方所有。本站与政府无隶属关系。', '資料來源：香港特別行政區政府公司註冊處及 DATA.GOV.HK；資料知識產權歸原提供方所有。本站與政府無隸屬關係。', 'Source: HKSAR Government Companies Registry and DATA.GOV.HK. Data intellectual property belongs to its providers. This app is not affiliated with the Government.');
  String get liquidationTitle => _text('独立清盘观察', '獨立清盤觀察', 'Voluntary winding-up');
  String get liquidationNotice => _text('仅统计股东及债权人自愿清盘，不含强制清盘，不是倒闭率；进行中为存量，不与成立／迁册公司数相减。', '僅統計股東及債權人自願清盤，不含強制清盤，不是倒閉率；進行中為存量，不與成立／遷冊公司數相減。', 'Members’ and creditors’ voluntary winding-up only, excluding compulsory liquidation. Not a business failure rate. In-progress cases are stock, not subtracted from incorporation/re-domiciliation company counts.');
  String get liquidationUnavailable => _text('清盘统计暂不可用，不代表清盘数为零。', '清盤統計暫不可用，不代表清盤數為零。', 'Winding-up statistics unavailable; this does not mean zero cases.');
  String get members => _text('股东自愿清盘', '股東自願清盤', 'Members’ voluntary');
  String get creditors => _text('债权人自愿清盘', '債權人自願清盤', 'Creditors’ voluntary');
  String get commenced => _text('当月开始（宗）', '當月開始（宗）', 'Commenced in month (cases)');
  String get inProgress => _text('进行中（宗）', '進行中（宗）', 'In progress (cases)');
  String get independentlyDated => _text('清盘周期独立于上方成立／迁册观察周期。', '清盤週期獨立於上方成立／遷冊觀察週期。', 'These months are independent of the incorporation/re-domiciliation period above.');

  String periodType(String type) => switch (type) {
    'week' => _text('完整周', '完整週', 'Week'),
    'year' => _text('完整年', '完整年', 'Year'),
    _ => _text('完整月', '完整月', 'Month'),
  };
  String status(String value) => switch (value) {
    'complete' => _text('资料完整', '資料完整', 'Complete sources'),
    'partial' => _text('资料不足', '資料不足', 'Partial sources'),
    _ => _text('暂无资料', '暫無資料', 'Unavailable'),
  };
  String total(int value, {bool includesRedomiciliation = true}) => includesRedomiciliation
      ? _text('本期成立／迁册公司 $value 家', '本期成立／遷冊公司 $value 家', '$value companies incorporated or re-domiciled in this period')
      : _text('本期新成立公司 $value 家（旧口径）', '本期新成立公司 $value 家（舊口徑）', '$value new incorporations (legacy scope)');
  String observed(int value) => _text('已核实记录涉及 $value 家公司', '已核實記錄涉及 $value 家公司', '$value companies in verified records');
  String dateRange(String start, String end) {
    final last = DateTime.parse(end).subtract(const Duration(days: 1));
    return '$start – ${last.toIso8601String().substring(0, 10)}';
  }
  String registered(String date, {bool includesRedomiciliation = true}) => includesRedomiciliation
      ? _text('成立／迁册日期 $date', '成立／遷冊日期 $date', 'Incorporated or re-domiciled $date')
      : _text('成立日期 $date', '成立日期 $date', 'Incorporated $date');
  String fetched(String value) {
    final time = DateTime.tryParse(value)?.toUtc().add(const Duration(hours: 8));
    final label = time == null ? value : time.toIso8601String().substring(0, 16).replaceFirst('T', ' ');
    return _text('获取于 $label（香港时间）', '取得於 $label（香港時間）', 'Fetched $label (Hong Kong time)');
  }
}

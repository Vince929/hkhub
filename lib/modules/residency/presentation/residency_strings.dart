import 'package:flutter/material.dart';

/// Residency module copy. Cantonese follows the app's Traditional Chinese
/// written copy convention (index 1), matching `EducationStrings`/`CommuteStrings`.
class ResidencyStrings {
  ResidencyStrings(Locale locale)
      : _index = locale.languageCode == 'en'
            ? 2
            : locale.languageCode == 'zh' && locale.scriptCode != 'Hant'
                ? 0
                : 1;

  final int _index;

  String _text(String hans, String hant, String en) => [hans, hant, en][_index];

  String get title => _text('永居规划', '永居規劃', 'Residency planning');

  // --- Setup / first run -----------------------------------------------------
  String get setupHeadline =>
      _text('记录留港日子\n见证七年历程', '記錄留港日子\n見證七年歷程', 'Track your stay,\none year at a time');
  String get setupSubtitle => _text(
        '填写开始累积居港的日期，之后由 App 帮你计算进度与里程碑。',
        '填寫開始累積居港的日期，之後由 App 幫你計算進度與里程碑。',
        'Enter the date your seven-year count begins. The app then tracks progress and milestones.',
      );
  String get startDateLabel => _text('开始累积日期', '開始累積日期', 'Start date');
  String get startDateHint => _text('选择日期', '選擇日期', 'Choose a date');
  String get visaTypeLabel => _text('签证类型（选填）', '簽證類型（選填）', 'Visa type (optional)');
  String get visaExpiryLabel => _text('签证到期日（选填）', '簽證到期日（選填）', 'Visa expiry (optional)');
  String get optional => _text('选填', '選填', 'Optional');
  String get notSet => _text('未设置', '未設置', 'Not set');
  String get startAction => _text('开始记录', '開始記錄', 'Start tracking');
  String get dateRequired => _text('请选择开始日期', '請選擇開始日期', 'Please choose a start date');
  String get dateInFuture =>
      _text('开始日期不能晚于今天', '開始日期不能晚於今天', 'The start date cannot be after today');
  String get dateOrderError =>
      _text('到期日不能早于开始日期', '到期日不能早於開始日期', 'The expiry date cannot be before the start date');

  String visaName(String key) => switch (key) {
        'ttps' => _text('高才通', '高才通', 'Top Talent Pass'),
        'qmas' => _text('优才', '優才', 'Quality Migrant'),
        'asmtp' => _text('专才', '專才', 'Mainland talents (ASMTP)'),
        'iang' => 'IANG',
        'other' => _text('其他', '其他', 'Other'),
        _ => _text('未提供', '未提供', 'Not specified'),
      };

  // --- Shared notices --------------------------------------------------------
  String get localOnlyNotice => _text(
        '数据只保存在本机，可随时清除。',
        '數據只保存在本機，可隨時清除。',
        'Data is stored only on this device and can be cleared at any time.',
      );
  String get boundaryNotice => _text(
        '本工具帮助你记录与规划，不判定永居资格；请以入境事务处官方指引为准。',
        '本工具幫助你記錄與規劃，不判定永居資格；請以入境事務處官方指引為準。',
        'This tool helps you keep track and plan. It does not decide eligibility; refer to official Immigration Department guidance.',
      );
  String get saveFailed =>
      _text('本机保存失败，请重试。', '本機保存失敗，請重試。', 'Could not save on this device. Please retry.');
  String get savedOk => _text('已保存', '已保存', 'Saved');

  // --- Progress --------------------------------------------------------------
  String elapsed(int years, int months) => _text(
        '已过 $years 年 $months 月',
        '已過 $years 年 $months 月',
        '$years yr $months mo',
      );
  String get elapsedPrefix => _text('已过', '已過', 'Elapsed');
  String get remainingPrefix => _text('还剩', '還剩', 'Left');
  String remainingDays(int days) => _text('$days 天', '$days 天', '$days days');
  String remainingMonths(int months) => _text('$months 个月', '$months 個月', '$months months');
  String get showMonths => _text('按月', '按月', 'Months');
  String get showDays => _text('按天', '按天', 'Days');
  String startedOn(String date) => _text('开始日期 $date', '開始日期 $date', 'Started $date');
  String targetOn(String date) => _text('预计满七年 $date', '預計滿七年 $date', 'Seven years on $date');
  String get reachedNotice => _text(
        '已满七年，请以官方流程为准。',
        '已滿七年，請以官方流程為準。',
        'Seven years reached. Follow the official process.',
      );
  String visaExpiry(String date, int days) => days >= 0
      ? _text('签证到期 $date · 还剩 $days 天', '簽證到期 $date · 還剩 $days 天', 'Visa expires $date - $days days left')
      : _text('签证已于 $date 到期', '簽證已於 $date 到期', 'Visa expired on $date');

  // --- Milestones ------------------------------------------------------------
  String get nextMilestone => _text('下一个里程碑', '下一個里程碑', 'Next milestone');
  String get timelineTitle => _text('里程碑', '里程碑', 'Milestones');
  String get timelineHint =>
      _text('已达成节点与下一个目标', '已達成節點與下一個目標', 'Nodes reached and the next one');
  String timelineCount(int achieved, int total) =>
      _text('已达成 $achieved / $total 个节点', '已達成 $achieved / $total 個節點', '$achieved of $total nodes reached');
  String monthLabel(int months) => _text('第 $months 个月', '第 $months 個月', 'Month $months');
  String yearLabel(int years) => _text('第 $years 年', '第 $years 年', 'Year $years');
  String get milestoneDone => _text('已达成', '已達成', 'Reached');
  String get milestonePending => _text('等待中', '等待中', 'Upcoming');
  String get allMilestonesDone =>
      _text('七年里程碑已全部达成。', '七年里程碑已全部達成。', 'All seven-year milestones are reached.');
  String crossed(String label) => _text('你已跨过 $label', '你已跨過 $label', 'You reached $label');

  // --- Settings / editing ----------------------------------------------------
  String get settingsTitle => _text('设置', '設定', 'Settings');
  String get editStartDate => _text('修改开始日期', '修改開始日期', 'Change start date');
  String get editVisaType => _text('修改签证类型', '修改簽證類型', 'Change visa type');
  String get editVisaExpiry => _text('修改签证到期日', '修改簽證到期日', 'Change visa expiry');
  String get changeConfirm => _text(
        '修改开始日期会重新计算进度与里程碑，确定继续？',
        '修改開始日期會重新計算進度與里程碑，確定繼續？',
        'Changing the start date recalculates progress and milestones. Continue?',
      );
  String get clear => _text('清空本机数据', '清空本機數據', 'Clear device data');
  String get clearQuestion =>
      _text('清除本机的永居记录？', '清除本機的永居記錄？', 'Clear the residency record on this device?');
  String get cancel => _text('取消', '取消', 'Cancel');
  String get confirm => _text('确定', '確定', 'Confirm');
  String get save => _text('保存', '保存', 'Save');

  // --- Time away (departure marks) -------------------------------------------
  String get departureTitle => _text('离港记录', '離港記錄', 'Time away');
  String get departureAdd => _text('添加离港时段', '新增離港時段', 'Add a period away');
  String get departureEmpty =>
      _text('尚未记录离港时段。', '尚未記錄離港時段。', 'No periods away recorded yet.');
  String get departureOngoing => _text('仍在离港', '仍在離港', 'Ongoing');
  String departurePeriod(String start, String? end) => end == null
      ? _text('$start 起', '$start 起', 'From $start')
      : '$start – $end';
  String get departureDelete => _text('删除', '刪除', 'Delete');
  String get departureEdit => _text('编辑', '編輯', 'Edit');
  String get departureSheetTitle => _text('离港时段', '離港時段', 'Period away');
  String get departureStartLabel => _text('离港日期', '離港日期', 'Left Hong Kong');
  String get departureEndLabel => _text('返港日期（选填）', '返港日期（選填）', 'Returned (optional)');
  String get departureRangeError =>
      _text('返港日期不能早于离港日期', '返港日期不能早於離港日期', 'The return date cannot be before the departure date');
  String get departureRemoveQuestion =>
      _text('删除这段离港记录？', '刪除這段離港記錄？', 'Delete this period away?');
  String get departureAdvisory => _text(
        '官方要求「通常居住香港连续七年」。短期离港一般不影响连续性；长期或频繁离港是否构成中断，由入境处按个案判断，请以官方指引为准。',
        '官方要求「通常居住香港連續七年」。短期離港一般不影響連續性；長期或頻繁離港是否構成中斷，由入境處按個案判斷，請以官方指引為準。',
        'Official guidance requires seven years of continuous ordinary residence. Short absences generally do not affect continuity; whether long or frequent absences break it is decided case by case. Refer to official guidance.',
      );
  String get departureLongNote => _text(
        '你标记了一段较长的离港，建议留意连续性并以官方指引核实。',
        '你標記了一段較長的離港，建議留意連續性並以官方指引核實。',
        'You marked a longer period away. Consider checking continuity against official guidance.',
      );

  // --- Renewal ---------------------------------------------------------------
  String get renewalTitle => _text('续签提示', '續簽提示', 'Renewal');
  String renewalDaysLeft(int days) =>
      _text('距签证到期还有 $days 天', '距簽證到期還有 $days 天', '$days days until your visa expires');
  String get renewalExpired =>
      _text('签证已到期，请尽快处理。', '簽證已到期，請盡快處理。', 'Your visa has expired. Act as soon as possible.');
  String renewalLevelName(String level) => switch (level) {
        'urgent' => _text('需尽快处理', '需盡快處理', 'Act soon'),
        'soon' => _text('临近到期', '臨近到期', 'Due soon'),
        'upcoming' => _text('已进入提醒期', '已進入提醒期', 'Reminder period'),
        _ => _text('暂未到期', '暫未到期', 'Not due yet'),
      };
  String get renewalChecklistTitle =>
      _text('通用准备清单', '通用準備清單', 'General checklist');
  String get renewalNotice => _text(
        '以上为通用建议，不构成承诺；请以入境事务处要求为准。',
        '以上為通用建議，不構成承諾；請以入境事務處要求為準。',
        'General guidance only, not a guarantee. Refer to official Immigration Department requirements.',
      );
  List<String> renewalChecklist(String? visaType) {
    final items = <String>[
      _text('确认签证到期日与逗留条件', '確認簽證到期日與逗留條件', 'Confirm the expiry date and conditions of stay'),
      _text('准备在港住址证明与在港生活证明', '準備在港住址證明與在港生活證明', 'Prepare proof of address and life in Hong Kong'),
      _text('保留出入境记录', '保留出入境記錄', 'Keep your travel records'),
    ];
    final extra = switch (visaType) {
      'ttps' => [
          _text('核对高才通的薪酬与在港工作证明要求', '核對高才通的薪酬與在港工作證明要求', 'Check the salary and employment evidence for the Top Talent Pass'),
        ],
      'qmas' => [
          _text('核对优才计划的在港贡献与综合计分材料', '核對優才計劃的在港貢獻與綜合計分材料', 'Check the contribution and points-based evidence for the Quality Migrant scheme'),
        ],
      'asmtp' => [
          _text('核对专才计划的雇主担保与职位证明', '核對專才計劃的僱主擔保與職位證明', 'Check the employer sponsorship and job evidence for the ASMTP'),
        ],
      'iang' => [
          _text('核对 IANG 的雇佣关系与学历证明', '核對 IANG 的僱傭關係與學歷證明', 'Check the employment and qualification evidence for IANG'),
        ],
      _ => const <String>[],
    };
    return [...items, ...extra];
  }

  // --- Share card (v3) -------------------------------------------------------
  String get shareCard => _text('生成旅程卡片', '生成旅程卡片', 'Create a journey card');
  String get sharePreviewTitle => _text('旅程卡片', '旅程卡片', 'Journey card');
  String get shareAction => _text('分享', '分享', 'Share');
  String get shareFailed => _text('分享失败，请重试。', '分享失敗，請重試。', 'Could not share. Please retry.');
  String get shareTitle => _text('我的永居历程', '我的永居歷程', 'My residency journey');
  String get shareTagline =>
      _text('记录留港日子，见证七年历程', '記錄留港日子，見證七年歷程', 'Track your stay and the seven-year journey');
}

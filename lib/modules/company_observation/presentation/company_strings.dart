import 'package:flutter/material.dart';

class CompanyStrings {
  CompanyStrings(Locale locale) : _index = locale.languageCode == 'en' ? 2
      : locale.languageCode == 'zh' && locale.scriptCode != 'Hant' ? 0 : 1;
  final int _index;
  String _text(String hans, String hant, String en) => [hans, hant, en][_index];

  String get title => _text('香港新增登记观察', '香港新增登記觀察', 'Hong Kong registration watch');
  String get shortTitle => _text('新增登记观察', '新增登記觀察', 'Registration watch');
  String get description => _text('本期成立／迁册公司名单与名称关键词观察', '本期成立／遷冊公司名單與名稱關鍵詞觀察', 'Incorporated or re-domiciled companies and clues in their names');
  String get intro => _text('从公司名称，看看香港的商业方向', '從公司名稱，看看香港的商業方向', 'Explore business clues in Hong Kong company names');
  String get notice => _text('AI 仅根据名称推测，不是官方行业分类或实际经营证明。', 'AI 僅根據名稱推測，不是官方行業分類或實際經營證明。', 'AI infers clues from names only, not official industries or proof of actual business.');
  String get overlap => _text('按涉及公司数排列，不是热度排名；同一公司可涉及多个关键词。', '按涉及公司數排列，不是熱度排名；同一公司可涉及多個關鍵詞。', 'Ordered by company count, not popularity. A company may match several keywords.');
  String get summaryTitle => _text('AI 当期概览', 'AI 當期概覽', 'AI period overview');
  String get keywords => _text('名称中的业务关键词', '名稱中的業務關鍵詞', 'Business keywords in names');
  String get allCompanies => _text('查看公司名单', '查看公司名單', 'Browse company names');
  String get evidence => _text('名称依据', '名稱依據', 'Name evidence');
  String get synonyms => _text('原始匹配词', '原始匹配詞', 'Literal matching terms');
  String get source => _text('官方周报来源', '官方週報來源', 'Official weekly source');
  String get sourceFailed => _text('无法打开来源链接，请稍后重试。', '無法開啟來源連結，請稍後重試。', 'Could not open the source link. Please retry.');
  String get search => _text('搜索本期中英文公司名称', '搜尋本期中英文公司名稱', 'Search names in this period');
  String get searchNotice => _text('仅搜索本站本期已核实资料，不代表查遍香港全部公司。', '僅搜尋本站本期已核實資料，不代表查遍香港全部公司。', 'Searches verified records for this period, not all Hong Kong companies.');
  String get noResults => _text('没有匹配记录，请尝试其他名称。', '沒有匹配記錄，請嘗試其他名稱。', 'No matching records. Try another name.');
  String get noCompanies => _text('本期暂无可展示的成立／迁册记录，不代表本期没有此类登记。', '本期暫無可展示的成立／遷冊記錄，不代表本期沒有此類登記。', 'No incorporation or re-domiciliation records are available here. This does not imply none occurred.');
  String get noPeriods => _text('官方资料尚未接入，请稍后刷新。', '官方資料尚未接入，請稍後重新整理。', 'Official records have not been collected yet. Refresh later.');
  String get noThemes => _text('名称中未识别出明确业务关键词。', '名稱中未識別出明確業務關鍵詞。', 'No clear business keywords were identified in these names.');
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
  String get partial => _text('资料未齐，仅展示已核实记录，暂停完整总量和 AI 分析。', '資料未齊，僅展示已核實記錄，暫停完整總量和 AI 分析。', 'Incomplete sources. Only verified records are shown; full totals and AI are paused.');
  String get attribution => _text('资料来源：香港特别行政区政府公司注册处及 DATA.GOV.HK；资料知识产权归原提供方所有。本站与政府无隶属关系。', '資料來源：香港特別行政區政府公司註冊處及 DATA.GOV.HK；資料知識產權歸原提供方所有。本站與政府無隸屬關係。', 'Source: HKSAR Government Companies Registry and DATA.GOV.HK. Data intellectual property belongs to its providers. This app is not affiliated with the Government.');
  String get languageFallback => _text('以下 AI 正文采用繁体书面中文。', '以下 AI 正文採用繁體書面中文。', 'AI content below is in written Traditional Chinese.');
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
  String analysis(String value) => switch (value) {
    'running' => _text('AI 正在分析，名单可先浏览。', 'AI 正在分析，名單可先瀏覽。', 'AI analysis is running. Company names are available.'),
    'not_configured' => _text('AI 尚未配置，名单可正常浏览。', 'AI 尚未設定，名單可正常瀏覽。', 'AI is not configured. Company names remain available.'),
    'failed' => _text('AI 概览暂不可用，名单仍可浏览。', 'AI 概覽暫不可用，名單仍可瀏覽。', 'AI overview is unavailable. Company names remain available.'),
    'not_needed' => _text('本期无需生成 AI 报告。', '本期無需生成 AI 報告。', 'No AI report is needed for this period.'),
    _ => _text('AI 报告等待后台生成，浏览不会触发付费分析。', 'AI 報告等候後台生成，瀏覽不會觸發付費分析。', 'The AI report is queued. Browsing does not trigger paid analysis.'),
  };
  String analysisReason(String? code) => switch (code) {
    'analysis_daily_budget_exceeded' => _text('本站今日 AI 调用额度已用完，后台已暂停分析。', '本站今日 AI 呼叫額度已用完，後台已暫停分析。', 'The daily AI call budget is exhausted; analysis is paused.'),
    'analysis_report_budget_exceeded' => _text('本期报告已达到 AI 调用次数上限。', '本期報告已達到 AI 呼叫次數上限。', 'This report has reached its AI call budget.'),
    'budget_exceeded' => _text('AI 调用额度已用完；旧记录未区分每日与本期额度。', 'AI 呼叫額度已用完；舊記錄未區分每日與本期額度。', 'An AI call budget was exhausted. This older record does not identify which budget.'),
    'analysis_timeout' => _text('AI 服务响应超时。', 'AI 服務回應逾時。', 'The AI service response timed out.'),
    'analysis_auth_failed' => _text('AI 服务鉴权失败，需管理员检查服务端密钥。', 'AI 服務驗證失敗，需管理員檢查伺服器金鑰。', 'AI authentication failed. An administrator must check the server API key.'),
    'analysis_access_denied' => _text('AI 服务拒绝访问，需检查账号权限。', 'AI 服務拒絕存取，需檢查帳號權限。', 'AI access was denied. Account permissions need checking.'),
    'analysis_balance_insufficient' => _text('AI 服务账号余额不足。', 'AI 服務帳號餘額不足。', 'The AI service account has insufficient balance.'),
    'analysis_rate_limited' => _text('AI 服务请求受到限流。', 'AI 服務請求受到限流。', 'The AI service rate limit was reached.'),
    'analysis_request_invalid' => _text('AI 服务拒绝请求参数，需检查模型及调用配置。', 'AI 服務拒絕請求參數，需檢查模型及呼叫設定。', 'The AI service rejected request parameters. Check the model and call configuration.'),
    'analysis_model_unavailable' => _text('AI 请求地址或模型不可用。', 'AI 請求地址或模型不可用。', 'The AI endpoint or model was not found.'),
    'analysis_connection_failed' => _text('后台无法连接 AI 服务。', '後台無法連接 AI 服務。', 'The worker could not connect to the AI service.'),
    'analysis_upstream_failed' => _text('AI 服务返回异常状态。', 'AI 服務傳回異常狀態。', 'The AI service returned an error status.'),
    'analysis_truncated' => _text('AI 输出被截断，未发布报告；旧记录也可能表示其他非正常结束。', 'AI 輸出被截斷，未發佈報告；舊記錄也可能表示其他非正常結束。', 'AI output was truncated; the report was not published. Older records may also indicate other incomplete completions.'),
    'analysis_incomplete_completion' => _text('AI 未正常结束或返回空内容，未发布报告。', 'AI 未正常結束或傳回空內容，未發佈報告。', 'AI did not finish normally or returned empty content; the report was not published.'),
    'analysis_invalid_envelope' => _text('AI 服务返回的数据格式异常，未发布报告。', 'AI 服務傳回的資料格式異常，未發佈報告。', 'The AI service returned an invalid response envelope; the report was not published.'),
    'analysis_schema_invalid' => _text('AI 返回内容未通过 JSON 结构校验。', 'AI 傳回內容未通過 JSON 結構驗證。', 'AI output failed JSON schema validation.'),
    'analysis_batch_incomplete' => _text('AI 未完整处理本批公司名单。', 'AI 未完整處理本批公司名單。', 'AI did not process every company in the batch.'),
    'analysis_evidence_invalid' => _text('AI 关键词无法对应公司名称中的原文依据。', 'AI 關鍵詞無法對應公司名稱中的原文依據。', 'AI keywords could not be verified against literal company-name evidence.'),
    'analysis_merge_invalid' => _text('AI 关键词合并结果未通过一致性校验。', 'AI 關鍵詞合併結果未通過一致性驗證。', 'Merged AI keywords failed consistency validation.'),
    'analysis_merge_limit' => _text('AI 关键词归并超过处理上限。', 'AI 關鍵詞歸併超過處理上限。', 'AI keyword merging exceeded the processing limit.'),
    'analysis_metric_invalid' => _text('AI 概览包含无法核实的统计占位符。', 'AI 概覽包含無法核實的統計預留位置。', 'The AI overview contained invalid metric placeholders.'),
    'analysis_population_invalid' => _text('本期分析名单与快照数量不一致。', '本期分析名單與快照數量不一致。', 'The analysis population did not match the snapshot count.'),
    'analysis_response_too_large' => _text('AI 返回内容超过安全大小上限。', 'AI 傳回內容超過安全大小上限。', 'The AI response exceeded the safe size limit.'),
    'analysis_lease_lost' => _text('后台分析租约已失效，未发布报告。', '後台分析租約已失效，未發佈報告。', 'The worker lost its analysis lease; the report was not published.'),
    _ => _text('后台记录为分析或校验失败，未保存更细原因；需结合 worker 日志排查。', '後台記錄為分析或驗證失敗，未儲存更細原因；需結合 worker 日誌排查。', 'Analysis or validation failed without a more specific stored reason. Check the worker logs.'),
  };
  String analysisDiagnostic(String reportId, String? code) => _text(
    '报告 ID：$reportId\n错误码：${code ?? 'unknown'}',
    '報告 ID：$reportId\n錯誤碼：${code ?? 'unknown'}',
    'Report ID: $reportId\nError code: ${code ?? 'unknown'}');
  String analysisAttempts(int count, int max) => _text(
    '已尝试 $count / $max 次', '已嘗試 $count / $max 次', 'Attempts: $count / $max');
  String get analysisStopped => _text('后台不会自动重试；需管理员处理。', '後台不會自動重試；需管理員處理。', 'No automatic retry is scheduled; administrator action is required.');
  String get analysisQueuedRetry => _text('等待后台重试；刷新页面不会触发新的 AI 调用。', '等候後台重試；重新整理頁面不會觸發新的 AI 呼叫。', 'Waiting for a worker retry. Refreshing does not trigger a new AI call.');
  String analysisRetryAt(String value) {
    final time = DateTime.tryParse(value)?.toUtc().add(const Duration(hours: 8));
    final label = time == null ? value : time.toIso8601String().substring(0, 16).replaceFirst('T', ' ');
    return _text('后台最早于 $label（香港时间）重试，不保证届时完成。',
      '後台最早於 $label（香港時間）重試，不保證屆時完成。',
      'The worker may retry from $label (Hong Kong time); completion is not guaranteed then.');
  }
  String count(int value) => _text('涉及 $value 家公司', '涉及 $value 家公司', '$value companies');
  String total(int value, {bool includesRedomiciliation = true}) => includesRedomiciliation
      ? _text('本期成立／迁册公司 $value 家', '本期成立／遷冊公司 $value 家', '$value companies incorporated or re-domiciled in this period')
      : _text('本期新成立公司 $value 家（旧口径）', '本期新成立公司 $value 家（舊口徑）', '$value new incorporations (legacy scope)');
  String observed(int value) => _text('已核实记录涉及 $value 家公司', '已核實記錄涉及 $value 家公司', '$value companies in verified records');
  String unknown(int value) => _text('$value 家名称信息不足／未识别业务关键词', '$value 家名稱資訊不足／未識別業務關鍵詞', '$value names with insufficient information or no identified business keywords');
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

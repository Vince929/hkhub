import 'package:flutter/material.dart';

/// Module copy is kept together; Cantonese uses Traditional written Chinese.
class EducationStrings {
  EducationStrings(Locale locale)
      : _index = locale.languageCode == 'en' ? 2
            : locale.languageCode == 'zh' && locale.scriptCode != 'Hant' ? 0 : 1;

  final int _index;
  String _text(String hans, String hant, String en) => [hans, hant, en][_index];

  String get title => _text('香港升学', '香港升學', 'Study in Hong Kong');
  String get introduction => _text('找到适合你的\n港校硕士方向', '找到適合你的\n港校碩士方向', 'Find your path to\na Hong Kong master’s');
  String get formSubtitle => _text('填写学术背景，获得相关专业推荐与申请定位。', '填寫學術背景，獲得相關課程推薦與申請定位。', 'Share your academic background for relevant programmes and application guidance.');
  String get candidateUniversities => _text('10 所候选院校', '10 所候選院校', '10 candidate universities');
  String get taughtMasters => _text('授课型硕士', '授課型碩士', 'Taught master’s');
  String get privacyTitle => _text('数据与隐私说明', '數據與私隱說明', 'Data and privacy');
  String get consentLabel => _text('我同意将填写背景发送给 DeepSeek 进行分析', '我同意將填寫背景傳送給 DeepSeek 進行分析', 'I consent to sending my background to DeepSeek for analysis');
  String get estimateNotice => _text('AI 估算仅供参考，不构成录取承诺。', 'AI 估算僅供參考，不構成錄取承諾。', 'AI estimates are guidance, not admission guarantees.');
  String get analysisNotes => _text('估算边界与注意事项', '估算邊界與注意事項', 'Estimate limitations and notes');
  String get reportTitle => _text('你的选校参考', '你的選校參考', 'Your university shortlist');
  String get reportOverview => _text('背景分析', '背景分析', 'Background overview');
  String get programmeLabel => _text('相关专业', '相關課程', 'Relevant programmes');
  String programmeCount(int count) => _text('$count 个相关专业', '$count 個相關課程', '$count relevant programmes');
  String get probabilityRange => _text('专业估算范围', '課程估算範圍', 'Programme estimate range');
  String get singleProbabilityExplanation => _text('唯一推荐专业的 AI 估算，非学校整体录取概率。', '唯一推薦課程的 AI 估算，非學校整體錄取概率。', 'AI estimate for the single recommended programme, not the university’s overall admission probability.');
  String get scope => _text('大陆本科背景 · 香港授课型硕士 · 十所候选院校', '內地本科背景 · 香港授課型碩士 · 十所候選院校', 'Mainland undergraduate background · Taught master’s · Ten candidate universities');
  String get academic => _text('学术背景', '學術背景', 'Academic background');
  String get institution => _text('本科院校', '本科院校', 'Undergraduate institution');
  String get major => _text('本科专业', '本科專業', 'Undergraduate major');
  String get scale => _text('成绩量表', '成績量表', 'Grade scale');
  String get grade => _text('原始 GPA / 均分', '原始 GPA / 均分', 'Original GPA / average grade');
  String get gradeHint => _text('使用学校原始量表，不自行换算', '使用學校原始量表，不自行換算', 'Use your institution’s original scale, without conversion');
  String scaleName(String scale) => _text('$scale 分制', '$scale 分制', 'Out of $scale');
  String get direction => _text('意向申请方向', '意向申請方向', 'Intended study direction');
  String get directionHint => _text('例如：数据科学、金融、传媒', '例如：數據科學、金融、傳媒', 'For example: data science, finance, media');
  String get year => _text('计划入学年份', '計劃入學年份', 'Intake year');
  String get plans => _text('申请计划', '申請計劃', 'Study plans');
  String get optional => _text('补充背景（选填）', '補充背景（選填）', 'Additional background (optional)');
  String get institutionTier => _text('院校层级', '院校層級', 'Institution category');
  String tierName(String tier) => switch (tier) {
    '985' => '985', '211' => '211',
    'other' => _text('双非 / 其他', '雙非 / 其他', 'Other institution'),
    _ => _text('不确定 / 未提供', '不確定 / 未提供', 'Unknown / not provided'),
  };
  String get languageTest => _text('语言考试', '語言考試', 'Language test');
  String languageName(String test) => switch (test) {
    'ielts' => _text('雅思', '雅思', 'IELTS'),
    'toefl' => _text('托福', '托福', 'TOEFL'),
    'not_taken' => _text('未考', '未考', 'Not taken'),
    _ => _text('未提供', '未提供', 'Not provided'),
  };
  String get languageScore => _text('语言总分', '語言總分', 'Overall test score');
  String get experience => _text('实习 / 工作 / 科研经历', '實習 / 工作 / 科研經歷', 'Internship / work / research experience');
  String get preferences => _text('补充诉求', '補充訴求', 'Additional preferences');
  String get preferencesHint => _text('例如：希望转专业、偏好就业导向', '例如：希望轉專業、偏好就業導向', 'For example: changing field or a career-focused programme');
  String get privacy => _text('我同意将填写的背景发送给 DeepSeek 生成建议。服务端不保存完整资料与报告；第三方按其政策处理数据。本机保留最近一次记录，可随时清除。请勿填写姓名、电话等身份信息。', '我同意將填寫的背景傳送給 DeepSeek 生成建議。伺服器不保存完整資料與報告；第三方按其政策處理數據。本機保留最近一次紀錄，可隨時清除。請勿填寫姓名、電話等身分資料。', 'I consent to sending this background to DeepSeek for suggestions. The server does not persist the full input or report; third-party processing follows its policies. The latest record is saved on this device and can be cleared. Do not enter names, phone numbers or other identifying details.');
  String get consentRequired => _text('请先同意第三方 AI 数据处理说明', '請先同意第三方 AI 數據處理說明', 'Please consent to third-party AI processing first');
  String get generate => _text('分析并推荐', '分析並推薦', 'Analyse and recommend');
  String get generating => _text('正在分析背景与相关项目，请稍候…', '正在分析背景與相關課程，請稍候…', 'Analysing your background and relevant programmes. Please wait…');
  String get waiting => _text('结果格式异常时会自动重试一次；等待最多 3 分 15 秒。可取消等待，填写内容会保留。', '結果格式異常時會自動重試一次；等候最多 3 分 15 秒。可取消等候，填寫內容會保留。', 'Invalid results are retried once. Waiting is limited to 3 minutes 15 seconds. You can cancel; your form is kept.');
  String get requiredField => _text('请填写此项', '請填寫此項', 'This field is required');
  String scoreError(String max) => _text('请输入 0～$max 之间的分数', '請輸入 0～$max 之間的分數', 'Enter a score between 0 and $max');
  String get invalidYear => _text('请输入有效的入学年份', '請輸入有效的入學年份', 'Enter a valid intake year');
  String get all => _text('全部', '全部', 'All');
  String band(String tier) => switch (tier) {
    'reach' => _text('冲刺', '衝刺', 'Reach'),
    'match' => _text('匹配', '匹配', 'Match'),
    _ => _text('相对稳妥', '相對穩妥', 'Relatively safer'),
  };
  String positioning(String tier) => switch (tier) {
    'reach' => _text('申请难度较高', '申請難度較高', 'Higher application difficulty'),
    'match' => _text('具备一定竞争力', '具備一定競爭力', 'Some competitive strengths'),
    _ => _text('仍需准备备选', '仍需準備備選', 'Keep alternative options'),
  };
  String get disclaimer => _text('AI 估算，非录取承诺。百分比是模型主观判断，并非经过录取数据验证的统计概率。项目名称、当年招生与要求均未联网核验，请以学校官网为准。', 'AI 估算，非錄取承諾。百分比是模型主觀判斷，並非經過錄取數據驗證的統計概率。課程名稱、當年招生與要求均未聯網核驗，請以學校官網為準。', 'AI estimates, not admission guarantees. Percentages are subjective model judgments, not statistically validated admission probabilities. Programme names, current availability and requirements have not been verified online; check official university websites.');
  String get rangeExplanation => _text('本校推荐专业的估算范围；颜色取最高值，不代表至少获得一次录取的概率。', '本校推薦課程的估算範圍；顏色取最高值，不代表至少獲得一次錄取的概率。', 'Range across this university’s recommended programmes; colour uses the highest value, not the combined chance of any admission.');
  String get aiEstimate => _text('AI 估算', 'AI 估算', 'AI estimate');
  String get aiJudgment => _text('预测依据 · AI 判断', '預測依據 · AI 判斷', 'Prediction basis · AI judgment');
  String get relevance => _text('方向相关性', '方向相關性', 'Relevance to your direction');
  String get strengths => _text('匹配优势', '匹配優勢', 'Strengths');
  String get weaknesses => _text('主要短板', '主要短板', 'Weaknesses');
  String get nextSteps => _text('下一步建议', '下一步建議', 'Next steps');
  String get assumptions => _text('估算前提与未知信息', '估算前提與未知資料', 'Assumptions and unknowns');
  String get edit => _text('修改背景重新分析', '修改背景重新分析', 'Edit background and analyse again');
  String get clear => _text('清除本机记录', '清除本機紀錄', 'Clear device record');
  String get clearQuestion => _text('清除填写内容与最近一次报告？', '清除填寫內容與最近一次報告？', 'Clear your form and latest report?');
  String get cancel => _text('取消', '取消', 'Cancel');
  String get noResults => _text('没有符合当前筛选的专业。试试“全部”，或修改申请方向。', '沒有符合目前篩選的課程。試試「全部」，或修改申請方向。', 'No programmes match this filter. Try All or edit your study direction.');
  String get noSchools => _text('没有找到足够相关的项目，请调整申请方向后重新分析。', '沒有找到足夠相關的課程，請調整申請方向後重新分析。', 'No sufficiently relevant programmes were found. Adjust your study direction and analyse again.');
  String schoolCount(int count) => _text('十所候选院校中找到 $count 所相关院校', '十所候選院校中找到 $count 所相關院校', '$count relevant universities among ten candidates');
  String get saved => _text('最近一次报告 · 保存在本机', '最近一次報告 · 保存在本機', 'Latest report · Saved on this device');
  String get localFailure => _text('本机记录未能保存或清除，请重试；当前分析结果仍可查看。', '本機紀錄未能保存或清除，請重試；目前分析結果仍可查看。', 'The device record could not be saved or cleared. Please retry; the current report remains available.');
  String get networkError => _text('网络连接失败，填写内容已保留，请重试。', '網絡連線失敗，填寫內容已保留，請重試。', 'Connection failed. Your form is kept; please retry.');
  String get timeout => _text('分析等待超时，填写内容已保留，请稍后重试。', '分析等候逾時，填寫內容已保留，請稍後重試。', 'Analysis timed out. Your form is kept; please retry later.');
  String get invalidResponse => _text('分析结果格式异常，请重新分析。', '分析結果格式異常，請重新分析。', 'The analysis response was invalid. Please analyse again.');
  String get failed => _text('暂时无法完成分析，填写内容已保留，请重试。', '暫時無法完成分析，填寫內容已保留，請重試。', 'Analysis could not complete. Your form is kept; please retry.');
}

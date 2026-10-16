import 'package:flutter/material.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../company_observation/presentation/company_strings.dart';

class HomeTool {
  const HomeTool({
    required this.id,
    required this.featureId,
    required this.title,
    required this.description,
    required this.icon,
    this.visible = true,
    this.aliases = const [],
  });

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

  final String id;
  final String title;
  final List<HomeTool> items;
}

class HomeTools {
  const HomeTools({required this.groups});

  // Entry identities, grouping and ordering ship with the app, not the API.
  factory HomeTools.localized(AppLocalizations strings) {
    final english = strings.localeName == 'en';
    final companyCopy = CompanyStrings(english ? const Locale('en')
        : strings.localeName.startsWith('yue') || strings.localeName == 'zh_Hant'
            ? const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
            : const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'));
    final simplified = strings.localeName == 'zh_Hans' || strings.localeName == 'zh';
    return HomeTools(groups: [
      HomeToolGroup(
        id: 'new_hongkongers',
        title: english ? 'New Hongkongers' : '新港人',
        items: [
          HomeTool(
            id: 'commute',
            featureId: 'commute',
            title: english ? 'HK-Shenzhen commute' : '港深通勤',
            description: english
                ? 'Hong Kong immigration queues, seven-day reference and connections'
                : simplified
                    ? '港方入境轮候、七天同时段参考与香港侧接驳'
                    : '港方入境輪候、七天同時段參考與香港側接駁',
            icon: 'train',
          ),
          HomeTool(
            id: 'residency',
            featureId: 'residency',
            title: strings.residencyTitle,
            description: strings.residencyDescription,
            icon: 'event_note',
          ),
          HomeTool(
            id: 'education',
            featureId: 'education',
            title: strings.educationTitle,
            description: strings.educationDescription,
            icon: 'school',
          ),
        ],
      ),
      HomeToolGroup(
        id: 'utilities',
        title: english ? 'Utilities' : simplified ? '实用工具' : '實用工具',
        items: [
          HomeTool(
            id: 'rent',
            featureId: 'rent',
            title: english ? 'Rental trends' : simplified ? '租金趋势' : '租金趨勢',
            description: english
                ? 'Private domestic rental indices and average rents by area class'
                : simplified ? '私人住宅租金指数、分面积类别平均租金与历史变化'
                    : '私人住宅租金指數、分面積類別平均租金與歷史變化',
            icon: 'rent',
            aliases: ['RVD', '租房', '租屋', 'rent'],
          ),
          HomeTool(
            id: 'business',
            featureId: 'business',
            title: companyCopy.shortTitle,
            description: companyCopy.description,
            icon: 'storefront',
          ),
        ],
      ),
    ]);
  }

  final List<HomeToolGroup> groups;
}

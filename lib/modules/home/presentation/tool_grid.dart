import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tool_accents.dart';
import '../data/home_tools.dart';

// Add an ID only when its native page actually exists. Unknown IDs are not executable.
const nativeToolRoutes = <String, String>{
  'education': '/education', 'commute': '/commute', 'residency': '/residency',
};

bool supportsNativeTool(HomeTool tool) => nativeToolRoutes.containsKey(tool.featureId);

const _toolTitleStyle = TextStyle(fontSize: 14, height: 1.3, fontWeight: FontWeight.w600);

class ToolGroupGrid extends StatelessWidget {
  const ToolGroupGrid({super.key, required this.group});

  final HomeToolGroup group;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Semantics(
          header: true,
          child: Text(group.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700, color: AppTheme.ink,
          )),
        ),
      ),
      LayoutBuilder(builder: (context, constraints) {
        final height = math.max(150.0, 110 + textScaler.scale(14) * 1.3 + textScaler.scale(10) * 1.3);
        return GridView.builder(
          shrinkWrap: true,
          primary: false,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            mainAxisExtent: height,
          ),
          itemCount: group.items.length,
          itemBuilder: (context, index) => _ToolTile(
            key: ValueKey(group.items[index].id),
            tool: group.items[index], groupId: group.id,
          ),
        );
      }),
    ]);
  }
}

class _ToolTile extends ConsumerWidget {
  const _ToolTile({super.key, required this.tool, required this.groupId});

  final HomeTool tool;

  /// Colour encodes the group, not the tool, so growing the catalogue never
  /// runs out of distinguishable colours (see `docs/UI风格规范.md` §4).
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final supported = supportsNativeTool(tool);
    final icon = _toolIcon(tool.icon);
    final color = ToolAccents.forGroup(groupId);
    return Semantics(
      button: true,
      label: tool.title,
      hint: supported ? null : strings.comingSoon,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () async {
            final route = nativeToolRoutes[tool.featureId];
            if (route != null) {
              // Drop the search field's focus before leaving home. Otherwise the
              // home route's focus scope remembers it, and returning via the
              // AppBar back button restores focus (and pops the keyboard);
              // a back gesture happens to skip that restoration, a button does not.
              FocusManager.instance.primaryFocus?.unfocus();
              // Native feature routes are compiled into the app, never supplied by the server.
              await context.push(route);
              if (context.mounted) await ref.read(homeToolsProvider.notifier).refresh();
            } else {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(strings.toolUnavailable)));
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
            child: Column(children: [
              ExcludeSemantics(child: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: color, size: 34),
              )),
              const SizedBox(height: 14),
              Expanded(child: Align(
                alignment: Alignment.topCenter,
                child: ExcludeSemantics(child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    tool.title, textAlign: TextAlign.center, maxLines: 1,
                    softWrap: false, style: _toolTitleStyle,
                  ),
                )),
              )),
              if (!supported) Text(strings.comingSoon, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: AppTheme.signalAmber)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Maps a catalog icon token to a line icon. Colour comes from
/// [ToolAccents.forGroup], never from the icon itself.
IconData _toolIcon(String icon) => switch (icon) {
  'train' => Icons.train_outlined,
  'event_note' => Icons.event_note_outlined,
  'school' => Icons.school_outlined,
  'storefront' => Icons.storefront_outlined,
  'travel' => Icons.travel_explore_outlined,
  'article' => Icons.article_outlined,
  'calculate' => Icons.calculate_outlined,
  _ => Icons.apps_outlined,
};

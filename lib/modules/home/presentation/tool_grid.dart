import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../data/home_tools.dart';

// Add an ID only when its native page actually exists. Unknown IDs are not executable.
const nativeToolRoutes = <String, String>{'education': '/education'};

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
            key: ValueKey(group.items[index].id), tool: group.items[index],
          ),
        );
      }),
    ]);
  }
}

class _ToolTile extends ConsumerWidget {
  const _ToolTile({super.key, required this.tool});

  final HomeTool tool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final supported = supportsNativeTool(tool);
    final (icon, color) = _toolVisual(tool.icon);
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

(IconData, Color) _toolVisual(String icon) => switch (icon) {
  'train' => (Icons.train_outlined, AppTheme.harborBlue),
  'event_note' => (Icons.event_note_outlined, AppTheme.ferryGreen),
  'school' => (Icons.school_outlined, const Color(0xFF6855A0)),
  'storefront' => (Icons.storefront_outlined, AppTheme.signalAmber),
  'travel' => (Icons.travel_explore_outlined, AppTheme.harborBlue),
  'article' => (Icons.article_outlined, AppTheme.ferryGreen),
  'calculate' => (Icons.calculate_outlined, AppTheme.ferryGreen),
  _ => (Icons.apps_outlined, AppTheme.harborBlue),
};

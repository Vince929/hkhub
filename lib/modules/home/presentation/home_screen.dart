import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../data/home_tools.dart';
import 'tool_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
        // Keyboard appearance must not shrink the fixed brand header.
        final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
        final available = constraints.maxHeight;
        final headerHeight = math.min(
          available * 0.35,
          math.max(96.0, (available * 0.15).clamp(96.0, 144.0)) * math.min(scale, 1.5),
        ).toDouble();
        final keyboardPadding = math.min(
          MediaQuery.viewInsetsOf(context).bottom,
          math.max(0.0, available - headerHeight - 180.0),
        );
        return Column(children: [
          SizedBox(height: headerHeight, child: const _BrandHeader()),
          Expanded(child: Padding(
            padding: EdgeInsets.only(bottom: keyboardPadding),
            child: const ToolList(),
          )),
        ]);
      })),
    );
  }
}

class _BrandHeader extends ConsumerWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    return ColoredBox(
      color: AppTheme.harborBlue,
      child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(children: [
            const ExcludeSemantics(child: Icon(Icons.sailing_outlined, color: Colors.white, size: 32)),
            const SizedBox(width: 14),
            Expanded(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(child: Text(strings.appName, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w700))),
                const SizedBox(height: 4),
                Flexible(child: Text(strings.brandTagline, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFDCECF3), fontSize: 13, height: 1.3))),
              ],
            )),
            const SizedBox(width: 8),
            IconButton(
              tooltip: strings.settingsTitle,
              onPressed: () async {
                await context.push('/settings');
                if (context.mounted) await ref.read(homeToolsProvider.notifier).refresh();
              },
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
            ),
          ]),
        ),
      )),
    );
  }
}

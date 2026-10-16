import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/hk_sail_mark.dart';
import 'tool_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Paint the status bar band harbor-blue so the top of the home page reads as
    // one continuous strip with the brand header (no white seam).
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: AppTheme.ferryGreen,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Stack(children: [
          // Keeps the status bar deep blue even under Android's edge-to-edge mode
          // where statusBarColor is ignored and the system bar turns transparent.
          if (statusBarHeight > 0) Positioned(
            top: 0, left: 0, right: 0, height: statusBarHeight,
            child: const ColoredBox(color: AppTheme.ferryGreen),
          ),
          SafeArea(child: LayoutBuilder(builder: (context, constraints) {
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
        ]),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ColoredBox(
      color: AppTheme.ferryGreen,
      child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(children: [
            const ExcludeSemantics(child: HkSailMark(size: 48, color: Colors.white)),
            const SizedBox(width: 14),
            Expanded(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(child: Text(strings.appName, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w700))),
                const SizedBox(height: 4),
                Flexible(child: Text(strings.brandTagline, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFCDE7E3), fontSize: 13, height: 1.3))),
              ],
            )),
            const SizedBox(width: 8),
            IconButton(
              tooltip: strings.settingsTitle,
              iconSize: 28,
              onPressed: () {
                // Same as the tool tiles: leaving home must not leave the search
                // field as the route's remembered focus, or the back button would
                // restore it on return.
                FocusManager.instance.primaryFocus?.unfocus();
                context.push('/settings');
              },
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
            ),
          ]),
        ),
      )),
    );
  }
}

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Distributes the brand icon to every platform asset the app ships.
///
/// The icon is an **external asset**: `assets/images/app_icon.png` — a 1024px
/// square, brand field + white sail mark. This tool never draws it. It reads
/// that one file and emits each platform size as a pure downscale, so Android
/// and iOS are literally the same image at different resolutions.
///
/// Re-branding therefore means: replace the PNG, then run
///
/// ```bash
/// ./cmd.sh icons
/// # or: flutter test tool/generate_icons.dart
/// ```
const _source = 'assets/images/app_icon.png';

/// iOS launch-screen image box, as declared in `LaunchScreen.storyboard`.
const _iosLaunchWidth = 168.0;
const _iosLaunchHeight = 185.0;

Future<ui.Image> _loadSource() async {
  if (!File(_source).existsSync()) {
    fail('Missing icon master: $_source — drop the design asset there first.');
  }
  final codec = await ui.instantiateImageCodec(File(_source).readAsBytesSync());
  return (await codec.getNextFrame()).image;
}

/// Downscales [source] to [width]x[height], preserving aspect ratio and centring
/// with transparent bars. No drawing: every pixel comes from the master.
Future<Uint8List> _scale(ui.Image source, int width, int height) async {
  final scale = math.min(width / source.width, height / source.height);
  final w = source.width * scale;
  final h = source.height * scale;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawImageRect(
    source,
    Rect.fromLTWH(0, 0, source.width.toDouble(), source.height.toDouble()),
    Rect.fromLTWH((width - w) / 2, (height - h) / 2, w, h),
    Paint()..filterQuality = FilterQuality.high,
  );

  final image = await recorder.endRecording().toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

void _write(String path, Uint8List bytes) {
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes);
  // ignore: avoid_print
  print('wrote $path (${bytes.lengthInBytes} bytes)');
}

/// The masks the common launchers apply to the adaptive icon, purely for
/// eyeballing: the shipped master, shown as each mask would crop it.
const _previewMasks = ['square', 'rounded', 'circle'];

Future<void> _renderMaskSheet(ui.Image source) async {
  const cell = 176.0;
  const gap = 14.0;

  final width = gap + _previewMasks.length * (cell + gap);
  final height = gap + cell + gap;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(Rect.fromLTWH(0, 0, width, height),
      Paint()..color = const Color(0xFFE9EEF3));

  for (var c = 0; c < _previewMasks.length; c++) {
    final rect = Rect.fromLTWH(gap + c * (cell + gap), gap, cell, cell);
    // Cell backing so the region a mask crops away stays visible.
    canvas.drawRect(rect, Paint()..color = const Color(0xFFC7D3DE));

    canvas.save();
    canvas.clipPath(_maskPath(_previewMasks[c], rect));
    canvas.drawImageRect(
      source,
      Rect.fromLTWH(0, 0, source.width.toDouble(), source.height.toDouble()),
      rect,
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.restore();
  }

  final image =
      await recorder.endRecording().toImage(width.toInt(), height.toInt());
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  _write('build/icon_preview/launcher_masks.png', data!.buffer.asUint8List());
}

Path _maskPath(String mask, Rect rect) => switch (mask) {
  'circle' => Path()..addOval(rect),
  'rounded' => Path()
    ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.22))),
  _ => Path()..addRect(rect),
};

void main() {
  test('distribute the brand icon to every platform asset', () async {
    final source = await _loadSource();

    // iOS app-icon set. Opaque — the platform rejects alpha, and the master is
    // a full-bleed square, so this holds.
    const ios = {
      'Icon-App-20x20@1x.png': 20,
      'Icon-App-20x20@2x.png': 40,
      'Icon-App-20x20@3x.png': 60,
      'Icon-App-29x29@1x.png': 29,
      'Icon-App-29x29@2x.png': 58,
      'Icon-App-29x29@3x.png': 87,
      'Icon-App-40x40@1x.png': 40,
      'Icon-App-40x40@2x.png': 80,
      'Icon-App-40x40@3x.png': 120,
      'Icon-App-60x60@2x.png': 120,
      'Icon-App-60x60@3x.png': 180,
      'Icon-App-76x76@1x.png': 76,
      'Icon-App-76x76@2x.png': 152,
      'Icon-App-83.5x83.5@2x.png': 167,
      'Icon-App-1024x1024@1x.png': 1024,
    };
    for (final entry in ios.entries) {
      _write('ios/Runner/Assets.xcassets/AppIcon.appiconset/${entry.key}',
          await _scale(source, entry.value, entry.value));
    }

    // Android legacy launcher icons.
    const launcher = {
      'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192,
    };
    for (final entry in launcher.entries) {
      _write('android/app/src/main/res/mipmap-${entry.key}/ic_launcher.png',
          await _scale(source, entry.value, entry.value));
    }

    // Android adaptive-icon foreground layers (108dp canvas per density). The
    // background layer is the same brand colour (see res/values/colors.xml), so
    // feeding this full-bleed square here is seamless.
    const foreground = {
      'mdpi': 108, 'hdpi': 162, 'xhdpi': 216, 'xxhdpi': 324, 'xxxhdpi': 432,
    };
    for (final entry in foreground.entries) {
      _write(
        'android/app/src/main/res/drawable-${entry.key}/ic_launcher_foreground.png',
        await _scale(source, entry.value, entry.value),
      );
    }

    // Android splash logo, centred by launch_background.xml on the brand field.
    const splash = {
      'mdpi': 128, 'hdpi': 192, 'xhdpi': 256, 'xxhdpi': 384, 'xxxhdpi': 512,
    };
    for (final entry in splash.entries) {
      _write(
        'android/app/src/main/res/drawable-${entry.key}/launch_image.png',
        await _scale(source, entry.value, entry.value),
      );
    }

    // iOS launch-screen logo, in the storyboard's declared image box.
    for (final scale in const [1, 2, 3]) {
      final name = scale == 1 ? 'LaunchImage.png' : 'LaunchImage@${scale}x.png';
      _write(
        'ios/Runner/Assets.xcassets/LaunchImage.imageset/$name',
        await _scale(source, (_iosLaunchWidth * scale).round(),
            (_iosLaunchHeight * scale).round()),
      );
    }

    // Mask sheet, for eyeballing what the common launchers do to the master.
    await _renderMaskSheet(source);
  });
}

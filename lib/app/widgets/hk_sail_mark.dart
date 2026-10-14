import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The HK Hub brand symbol: a junk sailboat on the harbour.
///
/// One mark, two roles (see `docs/UI风格规范.md` §5):
///
///  * **logo** — `animate: false`; used in the brand header, splash and cards;
///  * **loading** — `animate: true`; the hull bobs and rolls on moving water,
///    so the same shape doubles as the app-wide progress indicator.
///
/// The mark is drawn in code (no image assets), so it scales cleanly from an
/// inline 24px spinner to a full-bleed splash and always follows the palette it
/// is handed. Colour defaults to the theme's primary, which is the brand teal.
class HkSailMark extends StatefulWidget {
  const HkSailMark({
    super.key,
    this.size = 72,
    this.color,
    this.waveColor,
    this.animate = false,
    this.showWaves = true,
  });

  /// Rendered inside a [size] x [size] box.
  final double size;

  /// Hull, mast and sails. Defaults to `Theme.colorScheme.primary`.
  final Color? color;

  /// Water lines under the hull. Defaults to [color] at 45% opacity.
  final Color? waveColor;

  /// When true the boat bobs and the water drifts. Honours the platform's
  /// "reduce motion" setting: motion is suppressed when it is on.
  final bool animate;

  /// Draw the water lines. Turn off for a compact inline mark.
  final bool showWaves;

  @override
  State<HkSailMark> createState() => _HkSailMarkState();
}

class _HkSailMarkState extends State<HkSailMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final shouldRun = widget.animate && !reduceMotion;
    if (shouldRun && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldRun && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void didUpdateWidget(HkSailMark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        size: Size.square(widget.size),
        painter: _SailPainter(
          phase: _controller.value,
          hull: color,
          wave: widget.waveColor ?? color.withValues(alpha: 0.45),
          showWaves: widget.showWaves,
        ),
      ),
    );
  }
}

/// A centred [HkSailMark] sized for a loading slot, with an optional caption.
class HkSailLoader extends StatelessWidget {
  const HkSailLoader({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) => Center(
    child: ExcludeSemantics(
      child: HkSailMark(size: size, animate: true),
    ),
  );
}

/// Paints the mark into [canvas], filling [size]. Exposed so the offline icon
/// generator (`tool/generate_icons.dart`) renders the exact same shape instead
/// of a hand-copied duplicate.
void paintSailMark(
  Canvas canvas,
  Size size, {
  required Color color,
  Color? waveColor,
  bool showWaves = true,
  double phase = 0,
}) {
  _SailPainter(
    phase: phase,
    hull: color,
    wave: waveColor ?? color.withValues(alpha: 0.45),
    showWaves: showWaves,
  ).paint(canvas, size);
}

class _SailPainter extends CustomPainter {
  const _SailPainter({
    required this.phase,
    required this.hull,
    required this.wave,
    required this.showWaves,
  });

  /// 0..1 animation clock. A fixed value renders the static logo.
  final double phase;
  final Color hull;
  final Color wave;
  final bool showWaves;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final angle = phase * 2 * math.pi;

    if (showWaves) {
      _paintWater(canvas, s, angle);
    }

    // Boat bobs vertically and rolls gently around the waterline.
    canvas.save();
    // Without the water lines the boat's mass sits above centre; nudge it back
    // down so the mark stays optically centred wherever waves are hidden.
    if (!showWaves) canvas.translate(0, s * 0.035);
    canvas.translate(0, math.sin(angle) * s * 0.014);
    canvas.translate(s * 0.5, s * 0.72);
    canvas.rotate(math.sin(angle + 0.7) * 0.05);
    canvas.translate(-s * 0.5, -s * 0.72);

    final fill = Paint()..color = hull;

    // Hull: a trapezoid tapering towards the keel.
    canvas.drawPath(
      Path()
        ..moveTo(s * 0.15, s * 0.655)
        ..lineTo(s * 0.85, s * 0.655)
        ..lineTo(s * 0.70, s * 0.80)
        ..lineTo(s * 0.30, s * 0.80)
        ..close(),
      fill,
    );

    // Mast.
    canvas.drawRect(
      Rect.fromLTRB(s * 0.475, s * 0.13, s * 0.515, s * 0.665), fill);

    // Main sail, aft of the mast.
    canvas.drawPath(
      Path()
        ..moveTo(s * 0.545, s * 0.19)
        ..lineTo(s * 0.545, s * 0.615)
        ..lineTo(s * 0.855, s * 0.615)
        ..close(),
      fill,
    );

    // Jib, forward of the mast.
    canvas.drawPath(
      Path()
        ..moveTo(s * 0.455, s * 0.24)
        ..lineTo(s * 0.455, s * 0.615)
        ..lineTo(s * 0.175, s * 0.615)
        ..close(),
      fill,
    );

    canvas.restore();
  }

  /// Two drifting sine lines that stand in for the harbour surface. Drawn after
  /// the boat so the water sits in front of the keel.
  void _paintWater(Canvas canvas, double s, double angle) {
    final stroke = Paint()
      ..color = wave
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.038
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(_wave(s, s * 0.818, s * 0.020, angle), stroke);
    canvas.drawPath(_wave(s, s * 0.902, s * 0.015, -angle * 0.8), stroke);
  }

  Path _wave(double s, double y, double amplitude, double shift) {
    const steps = 28;
    final path = Path();
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      // Water sits just wider than the hull — never running off to the edge,
      // which would read as "cut off" (especially under an icon mask).
      final x = s * (0.12 + 0.76 * t);
      final dy = math.sin(t * 4 * math.pi + shift) * amplitude;
      if (i == 0) {
        path.moveTo(x, y + dy);
      } else {
        path.lineTo(x, y + dy);
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(_SailPainter old) =>
      old.phase != phase ||
      old.hull != hull ||
      old.wave != wave ||
      old.showWaves != showWaves;
}

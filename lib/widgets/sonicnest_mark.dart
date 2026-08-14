import 'dart:math' as math;

import 'package:flutter/material.dart';

class SonicNestMark extends StatelessWidget {
  const SonicNestMark({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'SonicNest logo',
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: _SonicNestMarkPainter(
          primary: scheme.primary,
          secondary: scheme.tertiary,
          foreground: scheme.onPrimary,
        ),
      ),
    );
  }
}

class _SonicNestMarkPainter extends CustomPainter {
  const _SonicNestMarkPainter({
    required this.primary,
    required this.secondary,
    required this.foreground,
  });

  final Color primary;
  final Color secondary;
  final Color foreground;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = Radius.circular(size.width * .22);
    final bg = Paint()
      ..shader = LinearGradient(colors: [primary, secondary])
          .createShader(rect);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), bg);

    final stroke = Paint()
      ..color = foreground
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .055
      ..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    final micRect = Rect.fromCenter(
      center: Offset(cx, size.height * .43),
      width: size.width * .28,
      height: size.height * .42,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(micRect, Radius.circular(size.width * .14)),
      stroke,
    );
    final arcRect = Rect.fromCenter(
      center: Offset(cx, size.height * .50),
      width: size.width * .52,
      height: size.height * .46,
    );
    canvas.drawArc(arcRect, 0, math.pi, false, stroke);
    canvas.drawLine(
      Offset(cx, size.height * .72),
      Offset(cx, size.height * .84),
      stroke,
    );
    canvas.drawLine(
      Offset(cx - size.width * .13, size.height * .84),
      Offset(cx + size.width * .13, size.height * .84),
      stroke,
    );
    final wave = Paint()
      ..color = foreground.withValues(alpha: .68)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .035
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(cx, size.height * .45),
        radius: size.width * .34,
      ),
      math.pi * 1.16,
      math.pi * .68,
      false,
      wave,
    );
  }

  @override
  bool shouldRepaint(_SonicNestMarkPainter oldDelegate) =>
      oldDelegate.primary != primary ||
      oldDelegate.secondary != secondary ||
      oldDelegate.foreground != foreground;
}

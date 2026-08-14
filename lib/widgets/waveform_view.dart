import 'dart:math' as math;

import 'package:flutter/material.dart';

class WaveformView extends StatelessWidget {
  const WaveformView({
    super.key,
    required this.samples,
    this.height = 112,
    this.progress,
    this.compact = false,
  });

  final List<double> samples;
  final double height;
  final double? progress;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Audio waveform',
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _WaveformPainter(
            samples: samples,
            baseColor: scheme.primary.withValues(alpha: .45),
            playedColor: scheme.primary,
            progress: progress,
            compact: compact,
          ),
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({
    required this.samples,
    required this.baseColor,
    required this.playedColor,
    required this.progress,
    required this.compact,
  });

  final List<double> samples;
  final Color baseColor;
  final Color playedColor;
  final double? progress;
  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    if (samples.isEmpty) {
      final paint = Paint()
        ..color = baseColor
        ..strokeWidth = 2;
      canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), paint);
      return;
    }
    final targetBars = math.max(8, (size.width / (compact ? 4 : 6)).floor());
    final step = math.max(1, (samples.length / targetBars).ceil());
    final barWidth = compact ? 2.2 : 3.2;
    var bar = 0;
    for (var start = 0; start < samples.length; start += step) {
      final end = math.min(start + step, samples.length);
      var amplitude = 0.0;
      for (var i = start; i < end; i++) {
        amplitude = math.max(amplitude, samples[i].clamp(0.0, 1.0).toDouble());
      }
      final x = (bar / math.max(1, (samples.length / step).ceil() - 1)) * size.width;
      final normalizedProgress = progress?.clamp(0.0, 1.0).toDouble();
      final played = normalizedProgress != null && x <= size.width * normalizedProgress;
      final paint = Paint()
        ..color = played ? playedColor : baseColor
        ..strokeWidth = barWidth
        ..strokeCap = StrokeCap.round;
      final barHeight = math.max(3.0, amplitude * size.height * .88);
      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
      bar++;
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) =>
      oldDelegate.samples != samples ||
      oldDelegate.progress != progress ||
      oldDelegate.baseColor != baseColor ||
      oldDelegate.playedColor != playedColor;
}

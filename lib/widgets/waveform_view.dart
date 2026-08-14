import 'dart:math' as math;

import 'package:flutter/material.dart';

class WaveformView extends StatefulWidget {
  const WaveformView({
    super.key,
    required this.samples,
    this.height = 112,
    this.progress,
    this.compact = false,
    this.selection,
    this.onSelectionChanged,
  });

  final List<double> samples;
  final double height;
  final double? progress;
  final bool compact;
  final RangeValues? selection;
  final ValueChanged<RangeValues>? onSelectionChanged;

  @override
  State<WaveformView> createState() => _WaveformViewState();
}

class _WaveformViewState extends State<WaveformView> {
  bool? _draggingStart;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final interactive = widget.selection != null && widget.onSelectionChanged != null;
    return Semantics(
      label: interactive ? 'Audio waveform with draggable selection handles' : 'Audio waveform',
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = math.max(1.0, constraints.maxWidth);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: interactive
                  ? (details) => _startSelectionDrag(details.localPosition.dx, width)
                  : null,
              onPanUpdate: interactive
                  ? (details) => _updateSelectionDrag(details.localPosition.dx, width)
                  : null,
              onPanEnd: interactive ? (_) => _draggingStart = null : null,
              onPanCancel: interactive ? () => _draggingStart = null : null,
              child: CustomPaint(
                painter: _WaveformPainter(
                  samples: widget.samples,
                  baseColor: scheme.primary.withValues(alpha: .45),
                  playedColor: scheme.primary,
                  selectionColor: scheme.secondaryContainer.withValues(alpha: .55),
                  handleColor: scheme.secondary,
                  progress: widget.progress,
                  compact: widget.compact,
                  selection: widget.selection,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _startSelectionDrag(double dx, double width) {
    final selection = widget.selection!;
    final position = (dx / width).clamp(0.0, 1.0).toDouble();
    _draggingStart = (position - selection.start).abs() <=
        (position - selection.end).abs();
    _updateSelection(position);
  }

  void _updateSelectionDrag(double dx, double width) {
    _updateSelection((dx / width).clamp(0.0, 1.0).toDouble());
  }

  void _updateSelection(double position) {
    final selection = widget.selection!;
    const minimumSpan = .001;
    if (_draggingStart == true) {
      widget.onSelectionChanged!(
        RangeValues(
          position.clamp(0.0, math.max(0.0, selection.end - minimumSpan)).toDouble(),
          selection.end,
        ),
      );
    } else {
      widget.onSelectionChanged!(
        RangeValues(
          selection.start,
          position.clamp(math.min(1.0, selection.start + minimumSpan), 1.0).toDouble(),
        ),
      );
    }
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({
    required this.samples,
    required this.baseColor,
    required this.playedColor,
    required this.selectionColor,
    required this.handleColor,
    required this.progress,
    required this.compact,
    required this.selection,
  });

  final List<double> samples;
  final Color baseColor;
  final Color playedColor;
  final Color selectionColor;
  final Color handleColor;
  final double? progress;
  final bool compact;
  final RangeValues? selection;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final selected = selection;
    if (selected != null) {
      final startX = selected.start.clamp(0.0, 1.0).toDouble() * size.width;
      final endX = selected.end.clamp(0.0, 1.0).toDouble() * size.width;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(startX, 0, endX, size.height),
          const Radius.circular(8),
        ),
        Paint()..color = selectionColor,
      );
    }

    if (samples.isEmpty) {
      final paint = Paint()
        ..color = baseColor
        ..strokeWidth = 2;
      canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), paint);
    } else {
      final targetBars = math.max(8, (size.width / (compact ? 4 : 6)).floor());
      final step = math.max(1, (samples.length / targetBars).ceil());
      final barWidth = compact ? 2.2 : 3.2;
      var bar = 0;
      for (var start = 0; start < samples.length; start += step) {
        final end = math.min(start + step, samples.length);
        var amplitude = 0.0;
        for (var i = start; i < end; i++) {
          amplitude = math.max(
            amplitude,
            samples[i].clamp(0.0, 1.0).toDouble(),
          );
        }
        final x =
            (bar / math.max(1, (samples.length / step).ceil() - 1)) * size.width;
        final normalizedProgress = progress?.clamp(0.0, 1.0).toDouble();
        final played =
            normalizedProgress != null && x <= size.width * normalizedProgress;
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

    if (selected != null) {
      final startX = selected.start.clamp(0.0, 1.0).toDouble() * size.width;
      final endX = selected.end.clamp(0.0, 1.0).toDouble() * size.width;
      final handlePaint = Paint()
        ..color = handleColor
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(startX, 4),
        Offset(startX, size.height - 4),
        handlePaint,
      );
      canvas.drawLine(
        Offset(endX, 4),
        Offset(endX, size.height - 4),
        handlePaint,
      );
      canvas.drawCircle(Offset(startX, centerY), 6, handlePaint);
      canvas.drawCircle(Offset(endX, centerY), 6, handlePaint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) =>
      oldDelegate.samples != samples ||
      oldDelegate.progress != progress ||
      oldDelegate.baseColor != baseColor ||
      oldDelegate.playedColor != playedColor ||
      oldDelegate.selectionColor != selectionColor ||
      oldDelegate.handleColor != handleColor ||
      oldDelegate.selection != selection ||
      oldDelegate.compact != compact;
}

import 'package:flutter/material.dart';

import '../domain/scanned_device.dart';

/// RSSI over the last [ScannedDevice.historyWindow], drawn with a
/// [CustomPainter] rather than a chart package: it is one line, and
/// painting it by hand shows how little a chart really needs.
class RssiChart extends StatelessWidget {
  const RssiChart({required this.samples, this.compact = false, super.key});

  final List<RssiSample> samples;

  /// A bare sparkline for list tiles: no grid and no labels.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomPaint(
      size: Size.infinite,
      painter: _RssiPainter(
        samples: samples,
        now: DateTime.now(),
        compact: compact,
        line: theme.colorScheme.primary,
        grid: theme.colorScheme.outlineVariant,
        label: theme.textTheme.labelSmall!.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _RssiPainter extends CustomPainter {
  _RssiPainter({
    required this.samples,
    required this.now,
    required this.compact,
    required this.line,
    required this.grid,
    required this.label,
  });

  static const _strongest = -30;
  static const _weakest = -100;
  static const _gridLines = [-40, -60, -80, -100];

  final List<RssiSample> samples;
  final DateTime now;
  final bool compact;
  final Color line;
  final Color grid;
  final TextStyle label;

  @override
  void paint(Canvas canvas, Size size) {
    final leftPad = compact ? 0.0 : 36.0;
    final bottomPad = compact ? 0.0 : 16.0;
    final plot = Rect.fromLTRB(leftPad, 4, size.width, size.height - bottomPad);
    final windowMs = ScannedDevice.historyWindow.inMilliseconds;

    double y(int rssi) {
      final clamped = rssi.clamp(_weakest, _strongest);
      return plot.top +
          (_strongest - clamped) / (_strongest - _weakest) * plot.height;
    }

    double x(DateTime time) {
      final age = now.difference(time).inMilliseconds.clamp(0, windowMs);
      return plot.right - age / windowMs * plot.width;
    }

    if (!compact) _paintGrid(canvas, plot, y);
    if (samples.isEmpty) return;

    final path = Path()..moveTo(x(samples.first.time), y(samples.first.rssi));
    for (final sample in samples.skip(1)) {
      path.lineTo(x(sample.time), y(sample.rssi));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = compact ? 1.5 : 2
        ..strokeJoin = StrokeJoin.round,
    );

    final last = samples.last;
    canvas.drawCircle(
      Offset(x(last.time), y(last.rssi)),
      compact ? 2 : 3.5,
      Paint()..color = line,
    );
  }

  void _paintGrid(Canvas canvas, Rect plot, double Function(int) y) {
    final paint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (final rssi in _gridLines) {
      final dy = y(rssi);
      canvas.drawLine(Offset(plot.left, dy), Offset(plot.right, dy), paint);
      _text(canvas, '$rssi', Offset(0, dy - 7));
    }
    final seconds = ScannedDevice.historyWindow.inSeconds;
    _text(canvas, '-$seconds s', Offset(plot.left, plot.bottom + 2));
    _text(canvas, 'now', Offset(plot.right - 20, plot.bottom + 2));
  }

  void _text(Canvas canvas, String text, Offset offset) {
    (TextPainter(
      text: TextSpan(text: text, style: label),
      textDirection: TextDirection.ltr,
    )..layout()).paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_RssiPainter old) =>
      !identical(old.samples, samples) ||
      old.now != now ||
      old.line != line ||
      old.compact != compact;
}

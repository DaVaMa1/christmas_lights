import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ChristmasLights extends StatefulWidget {
  const ChristmasLights(
      {required this.enabled, required this.child, super.key});

  final Widget child;
  final bool enabled;

  @override
  State<ChristmasLights> createState() => _ChristmasLightsState();
}

class _ChristmasLightsState extends State<ChristmasLights> {
  late Timer timer;

  @override
  void initState() {
    if (widget.enabled) {
      timer =
          Timer.periodic(const Duration(seconds: 2), (_) => setState(() {}));
    }
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }
    return CustomPaint(
      foregroundPainter: ChristmaslightPainter(),
      child: widget.child,
    );
  }
}

class ChristmaslightPainter extends CustomPainter {
  static const int widthCount = 5;
  static const int heightCount = 3;
  static const double _lightInterval = 25;
  final Random _random = Random();

  static const _colors = [
    Colors.red,
    Colors.blue,
    Colors.yellow,
    Colors.green,
    Colors.purple
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final widthInterval = size.width / widthCount;
    final heightInterval = size.height / heightCount;

    final Path path = Path()..moveTo(0, heightInterval);

    for (var i = 1; i < widthCount; i++) {
      path.cubicTo(
        widthInterval * (i - 1 + 0.2),
        heightInterval,
        widthInterval * (i - 1 + 0.75),
        heightInterval,
        widthInterval * i,
        0,
      );
    }
    path.cubicTo(
      widthInterval * (widthCount - 1 + 0.2),
      heightInterval,
      widthInterval * (widthCount - 1 + 0.75),
      heightInterval,
      size.width,
      heightInterval,
    );
    canvas.drawPath(path, paint);
    _paintLights(path, canvas);
  }

  Paint _singleLight(Rect rect, Color color) {
    return Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          HSLColor.fromColor(color).withLightness(0.9).toColor(),
          color,
        ],
        stops: const [
          0.3,
          1,
        ],
        center: const Alignment(0, 0),
        radius: 0.6,
      ).createShader(Rect.fromLTWH(rect.left - 2.5, rect.top, 5, 10));
  }

  Paint _lightFlare(Rect rect, Color color) {
    return Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..shader = RadialGradient(
        colors: [
          HSLColor.fromColor(color).withLightness(0.9).toColor().withAlpha(100),
          color.withAlpha(100),
          color.withAlpha(0),
        ],
        stops: const [
          0.3,
          0.6,
          1,
        ],
        center: const Alignment(0, 0.1),
        radius: 0.6,
      ).createShader(_lightFlarePath(rect));
  }

  Rect _lightFlarePath(Rect rect) {
    return Rect.fromLTWH(rect.left - 7.5, rect.top - 5, 15, 25);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void _paintLights(Path source, Canvas canvas) {
    final metrics = source.computeMetrics().toList();
    for (final ui.PathMetric metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final metricPath = metric.extractPath(distance, distance);
        final pathRect = metricPath.getBounds();
        metricPath.addOval(
            Rect.fromLTWH(pathRect.left - 2.5, pathRect.top + 2.5, 5, 10));
        final color = _colors[_random.nextInt(_colors.length)];
        canvas.drawPath(metricPath, _lightFlare(pathRect, color));
        canvas.drawPath(metricPath, _singleLight(pathRect, color));
        distance += _lightInterval;
      }
    }
  }
}

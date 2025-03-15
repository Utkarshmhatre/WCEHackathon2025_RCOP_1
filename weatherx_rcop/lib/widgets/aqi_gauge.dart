import 'package:flutter/material.dart';
import 'dart:math' as math;

class AqiGauge extends StatelessWidget {
  final int aqi;

  const AqiGauge({super.key, required this.aqi});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      width: 140,
      child: CustomPaint(
        painter: _AqiGaugePainter(aqi: aqi),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                aqi.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'AQI',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AqiGaugePainter extends CustomPainter {
  final int aqi;

  _AqiGaugePainter({required this.aqi});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw background arc
    final bgPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 8),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    // Draw progress arc
    final progress = math.min((aqi / 5.0), 1.0); // Ensure double division
    final progressColor = _getColorForAqi(aqi);
    final progressPaint =
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 8),
      math.pi * 0.75,
      math.pi * 1.5 * progress,
      false,
      progressPaint,
    );

    // Draw small circles for levels
    final smallCirclePaint = Paint()..style = PaintingStyle.fill;
    final smallCircleRadius = 4.0;

    for (int i = 1; i <= 5; i++) {
      final angle =
          math.pi * 0.75 + (math.pi * 1.5 * i / 5.0); // Ensure double division
      final circlePos = Offset(
        center.dx + (radius - 8) * math.cos(angle),
        center.dy + (radius - 8) * math.sin(angle),
      );

      if (i <= aqi) {
        smallCirclePaint.color = _getColorForAqi(i);
      } else {
        smallCirclePaint.color = Colors.white.withOpacity(0.3);
      }

      canvas.drawCircle(circlePos, smallCircleRadius, smallCirclePaint);
    }
  }

  Color _getColorForAqi(int aqi) {
    switch (aqi) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(_AqiGaugePainter oldDelegate) => oldDelegate.aqi != aqi;
}

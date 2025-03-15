import 'package:flutter/material.dart';
import '../models/air_quality_model.dart';

// Line Chart Painter
class LineChartPainter extends CustomPainter {
  final List<AirQuality> data;
  final String pollutant;
  final double minValue;
  final double maxValue;
  final bool isDarkMode;
  final double animationValue;

  LineChartPainter({
    required this.data,
    required this.pollutant,
    required this.minValue,
    required this.maxValue,
    required this.isDarkMode,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final height = size.height;
    final width = size.width;
    final effectiveHeight = height - 25; // Leave space for date labels

    final Paint linePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = _getBaseColor();

    // Draw grid lines
    _drawGrid(canvas, size);

    // Calculate points
    List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final value = _getPollutantValue(data[i], pollutant);
      final percentage = ((value - minValue) / (maxValue - minValue)).clamp(
        0.0,
        1.0,
      );
      final x = (i + 0.5) * (width / data.length);
      final y = effectiveHeight - (percentage * (effectiveHeight - 20));

      points.add(Offset(x, y));
    }

    // Draw the animated line
    if (points.isNotEmpty) {
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);

      for (int i = 1; i < points.length; i++) {
        // Only draw up to the animation progress
        if (i / points.length <= animationValue) {
          // Use straight lines instead of curves if animation is causing issues
          path.lineTo(points[i].dx, points[i].dy);
        }
      }

      canvas.drawPath(path, linePaint);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final height = size.height - 25; // Exclude date label space
    final width = size.width;

    final Paint gridPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..color = isDarkMode ? Colors.white24 : Colors.black12;

    // Draw horizontal grid lines
    for (int i = 1; i < 5; i++) {
      final y = height - (i * height / 5);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Draw vertical grid lines
    final pointWidth = width / data.length;
    for (int i = 1; i < data.length; i++) {
      final x = i * pointWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }
  }

  Color _getBaseColor() {
    switch (pollutant) {
      case 'PM2.5':
        return Colors.purple;
      case 'PM10':
        return Colors.red;
      case 'O₃':
        return Colors.blue;
      case 'NO₂':
        return Colors.amber;
      case 'SO₂':
        return Colors.green;
      case 'CO':
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  double _getPollutantValue(AirQuality item, String pollutant) {
    switch (pollutant) {
      case 'PM2.5':
        return item.pm2_5;
      case 'PM10':
        return item.pm10;
      case 'O₃':
        return item.o3;
      case 'NO₂':
        return item.no2;
      case 'SO₂':
        return item.so2;
      case 'CO':
        return item.co;
      default:
        return 0;
    }
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.pollutant != pollutant ||
        oldDelegate.data != data ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}

// Area Chart Painter
class AreaChartPainter extends CustomPainter {
  final List<AirQuality> data;
  final String pollutant;
  final double minValue;
  final double maxValue;
  final bool isDarkMode;
  final double animationValue;

  AreaChartPainter({
    required this.data,
    required this.pollutant,
    required this.minValue,
    required this.maxValue,
    required this.isDarkMode,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final height = size.height;
    final width = size.width;
    final effectiveHeight = height - 25; // Leave space for date labels

    final Color baseColor = _getBaseColor();
    final Paint linePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = baseColor;

    final Paint fillPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [baseColor.withOpacity(0.5), baseColor.withOpacity(0.1)],
          ).createShader(Rect.fromLTWH(0, 0, width, effectiveHeight));

    // Draw grid lines
    _drawGrid(canvas, size);

    // Calculate points for the line
    List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final value = _getPollutantValue(data[i], pollutant);
      final percentage = ((value - minValue) / (maxValue - minValue)).clamp(
        0.0,
        1.0,
      );
      final x = (i + 0.5) * (width / data.length);
      final y = effectiveHeight - (percentage * (effectiveHeight - 20));

      points.add(Offset(x, y));
    }

    // Draw the animated area and line
    if (points.isNotEmpty) {
      // Create paths for both the line and area
      final linePath = Path();
      final areaPath = Path();

      // Start points
      linePath.moveTo(points[0].dx, points[0].dy);
      areaPath.moveTo(points[0].dx, effectiveHeight); // Start at bottom
      areaPath.lineTo(points[0].dx, points[0].dy); // Go up to first point

      int lastDrawnIndex = 0;
      for (int i = 1; i < points.length; i++) {
        // Only draw up to animation progress
        if (i / points.length <= animationValue) {
          // Use straight lines for stability
          linePath.lineTo(points[i].dx, points[i].dy);
          areaPath.lineTo(points[i].dx, points[i].dy);
          lastDrawnIndex = i;
        } else {
          break;
        }
      }

      // Close the area path to the bottom of the chart
      areaPath.lineTo(points[lastDrawnIndex].dx, effectiveHeight);
      areaPath.close();

      // Draw the paths
      canvas.drawPath(areaPath, fillPaint);
      canvas.drawPath(linePath, linePaint);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final height = size.height - 25; // Exclude date label space
    final width = size.width;

    final Paint gridPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..color = isDarkMode ? Colors.white24 : Colors.black12;

    // Draw horizontal grid lines
    for (int i = 1; i < 5; i++) {
      final y = height - (i * height / 5);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Draw vertical grid lines
    final pointWidth = width / data.length;
    for (int i = 1; i < data.length; i++) {
      final x = i * pointWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }
  }

  Color _getBaseColor() {
    switch (pollutant) {
      case 'PM2.5':
        return Colors.purple;
      case 'PM10':
        return Colors.red;
      case 'O₃':
        return Colors.blue;
      case 'NO₂':
        return Colors.amber;
      case 'SO₂':
        return Colors.green;
      case 'CO':
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  double _getPollutantValue(AirQuality item, String pollutant) {
    switch (pollutant) {
      case 'PM2.5':
        return item.pm2_5;
      case 'PM10':
        return item.pm10;
      case 'O₃':
        return item.o3;
      case 'NO₂':
        return item.no2;
      case 'SO₂':
        return item.so2;
      case 'CO':
        return item.co;
      default:
        return 0;
    }
  }

  @override
  bool shouldRepaint(AreaChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.pollutant != pollutant ||
        oldDelegate.data != data ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}

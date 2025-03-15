import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/air_quality_model.dart';

class AirQualityChart extends StatelessWidget {
  final List<AirQuality> data;
  final String pollutant;
  final bool isDarkMode;

  const AirQualityChart({
    super.key,
    required this.data,
    required this.pollutant,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
        ),
      );
    }

    // Sort data by date
    final sortedData = List<AirQuality>.from(data)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // Get value by pollutant type
    double getValue(AirQuality item) {
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
          return item.co / 100; // Scale down CO for better visualization
        default:
          return 0;
      }
    }

    // Create spots for the chart
    final spots =
        sortedData.asMap().entries.map((entry) {
          final index = entry.key.toDouble();
          final value = getValue(entry.value);
          return FlSpot(index, value);
        }).toList();

    // Find min and max for better scaling
    double minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    minY = minY * 0.8; // Add some padding
    maxY = maxY * 1.2;

    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.only(
          right: 18,
          left: 12,
          top: 24,
          bottom: 12,
        ),
        child: LineChart(
          LineChartData(
            backgroundColor:
                isDarkMode
                    ? Colors.black.withOpacity(0.2)
                    : Colors.white.withOpacity(0.2),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: maxY / 5,
              verticalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: isDarkMode ? Colors.white10 : Colors.black12,
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: isDarkMode ? Colors.white10 : Colors.black12,
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: sortedData.length > 5 ? 2 : 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < sortedData.length) {
                      final date = sortedData[index].dateTime;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('E\nHH:mm').format(date),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                axisNameWidget: Text(
                  '$pollutant (μg/m³)',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: maxY / 5,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toStringAsFixed(1),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                  reservedSize: 42,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: isDarkMode ? Colors.white24 : Colors.black26,
              ),
            ),
            minX: 0.0,
            maxX: (sortedData.length - 1).toDouble(),
            minY: minY,
            maxY: maxY,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                gradient: LinearGradient(colors: _getGradientColors(pollutant)),
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 5,
                      color: _getDotColor(getValue(sortedData[index])),
                      strokeWidth: 2,
                      strokeColor: isDarkMode ? Colors.white : Colors.black,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors:
                        _getGradientColors(
                          pollutant,
                        ).map((color) => color.withOpacity(0.3)).toList(),
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor:
                    isDarkMode
                        ? Colors.white.withOpacity(0.8)
                        : Colors.black.withOpacity(0.8),
                tooltipRoundedRadius: 8,
                getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                  return lineBarsSpot.map((lineBarSpot) {
                    final index = lineBarSpot.x.toInt();
                    if (index >= 0 && index < sortedData.length) {
                      final item = sortedData[index];
                      final value = getValue(item);

                      // Make this more kid-friendly
                      String quality = "Good";
                      if (value > 100) {
                        quality = "Very Bad";
                      } else if (value > 50)
                        quality = "Bad";
                      else if (value > 25)
                        quality = "Okay";

                      return LineTooltipItem(
                        '${DateFormat('E, MMM d').format(item.dateTime)} at ${DateFormat('h:mm a').format(item.dateTime)}\n',
                        TextStyle(
                          color: isDarkMode ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text:
                                '$pollutant: ${value.toStringAsFixed(1)} $quality',
                            style: TextStyle(
                              color: _getDotColor(value),
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    }
                    return null;
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors(String pollutant) {
    switch (pollutant) {
      case 'PM2.5':
        return [Colors.purple, Colors.deepPurple];
      case 'PM10':
        return [Colors.red, Colors.redAccent];
      case 'O₃':
        return [Colors.blue, Colors.blueAccent];
      case 'NO₂':
        return [Colors.amber, Colors.orange];
      case 'SO₂':
        return [Colors.green, Colors.lightGreen];
      case 'CO':
        return [Colors.brown, Colors.brown.shade300];
      default:
        return [Colors.blue, Colors.blueAccent];
    }
  }

  Color _getDotColor(double value) {
    // Based on generic pollutant thresholds
    if (value < 20) return Colors.green;
    if (value < 50) return Colors.lightGreen;
    if (value < 100) return Colors.yellow;
    if (value < 200) return Colors.orange;
    return Colors.red;
  }
}

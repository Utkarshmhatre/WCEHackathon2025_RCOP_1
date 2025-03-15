import 'package:flutter/material.dart';

class AirQuality {
  final DateTime dateTime;
  final int aqi;
  final double co;
  final double no;
  final double no2;
  final double o3;
  final double so2;
  final double pm2_5;
  final double pm10;
  final double nh3;
  final double lat;
  final double lon;

  AirQuality({
    required this.dateTime,
    required this.aqi,
    required this.co,
    required this.no,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.pm2_5,
    required this.pm10,
    required this.nh3,
    required this.lat,
    required this.lon,
  });

  // Updated factory to handle both list and map coord formats
  factory AirQuality.fromJson(Map<String, dynamic> json, List<double> coord) {
    final components = json['components'];
    return AirQuality(
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      aqi: json['main']['aqi'],
      co: components['co']?.toDouble() ?? 0.0,
      no: components['no']?.toDouble() ?? 0.0,
      no2: components['no2']?.toDouble() ?? 0.0,
      o3: components['o3']?.toDouble() ?? 0.0,
      so2: components['so2']?.toDouble() ?? 0.0,
      pm2_5: components['pm2_5']?.toDouble() ?? 0.0,
      pm10: components['pm10']?.toDouble() ?? 0.0,
      nh3: components['nh3']?.toDouble() ?? 0.0,
      lat: coord[0],
      lon: coord[1],
    );
  }

  String getAqiDescription() {
    switch (aqi) {
      case 1:
        return 'Good';
      case 2:
        return 'Fair';
      case 3:
        return 'Moderate';
      case 4:
        return 'Poor';
      case 5:
        return 'Very Poor';
      default:
        return 'Unknown';
    }
  }

  Color getAqiColor() {
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
}

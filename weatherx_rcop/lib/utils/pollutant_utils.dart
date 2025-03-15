import 'package:flutter/material.dart';

class PollutantUtils {
  static Color getColorForValue(String pollutant, double value) {
    // Based on WHO guidelines and AQI scale
    switch (pollutant) {
      case 'PM2.5':
        if (value < 10) return Colors.green;
        if (value < 25) return Colors.lightGreen;
        if (value < 50) return Colors.yellow;
        if (value < 75) return Colors.orange;
        return Colors.red;
      case 'PM10':
        if (value < 20) return Colors.green;
        if (value < 50) return Colors.lightGreen;
        if (value < 100) return Colors.yellow;
        if (value < 200) return Colors.orange;
        return Colors.red;
      case 'O₃':
        if (value < 60) return Colors.blue;
        if (value < 100) return Colors.lightGreen;
        if (value < 140) return Colors.yellow;
        if (value < 180) return Colors.orange;
        return Colors.red;
      case 'NO₂':
        if (value < 40) return Colors.green;
        if (value < 70) return Colors.lightGreen;
        if (value < 150) return Colors.yellow;
        if (value < 200) return Colors.orange;
        return Colors.red;
      case 'SO₂':
        if (value < 20) return Colors.green;
        if (value < 80) return Colors.lightGreen;
        if (value < 250) return Colors.yellow;
        if (value < 350) return Colors.orange;
        return Colors.red;
      case 'CO':
        if (value < 4400) return Colors.green;
        if (value < 9400) return Colors.lightGreen;
        if (value < 12400) return Colors.yellow;
        if (value < 15400) return Colors.orange;
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  static String getLevelText(String pollutant, double value) {
    // Simplified text for levels
    switch (pollutant) {
      case 'PM2.5':
        if (value < 10) return 'Good';
        if (value < 25) return 'Okay';
        if (value < 50) return 'Medium';
        if (value < 75) return 'Bad';
        return 'Very Bad';
      case 'PM10':
        if (value < 20) return 'Good';
        if (value < 50) return 'Okay';
        if (value < 100) return 'Medium';
        if (value < 200) return 'Bad';
        return 'Very Bad';
      case 'O₃':
        if (value < 60) return 'Good';
        if (value < 100) return 'Okay';
        if (value < 140) return 'Medium';
        if (value < 180) return 'Bad';
        return 'Very Bad';
      case 'NO₂':
        if (value < 40) return 'Good';
        if (value < 70) return 'Okay';
        if (value < 150) return 'Medium';
        if (value < 200) return 'Bad';
        return 'Very Bad';
      case 'SO₂':
        if (value < 20) return 'Good';
        if (value < 80) return 'Okay';
        if (value < 250) return 'Medium';
        if (value < 350) return 'Bad';
        return 'Very Bad';
      case 'CO':
        if (value < 4400) return 'Good';
        if (value < 9400) return 'Okay';
        if (value < 12400) return 'Medium';
        if (value < 15400) return 'Bad';
        return 'Very Bad';
      default:
        if (value < 20) return 'Low';
        if (value < 50) return 'Medium';
        if (value < 100) return 'High';
        return 'Very High';
    }
  }

  static IconData getPollutantIcon(String pollutant) {
    switch (pollutant) {
      case 'PM2.5':
        return Icons.blur_on;
      case 'PM10':
        return Icons.grain;
      case 'O₃':
        return Icons.air;
      case 'NO₂':
        return Icons.directions_car;
      case 'SO₂':
        return Icons.factory;
      case 'CO':
        return Icons.local_fire_department;
      default:
        return Icons.science;
    }
  }

  static String getFullName(String pollutant) {
    switch (pollutant) {
      case 'PM2.5':
        return 'Fine Particulate Matter';
      case 'PM10':
        return 'Coarse Particulate Matter';
      case 'O₃':
        return 'Ozone';
      case 'NO₂':
        return 'Nitrogen Dioxide';
      case 'SO₂':
        return 'Sulfur Dioxide';
      case 'CO':
        return 'Carbon Monoxide';
      default:
        return pollutant;
    }
  }
}

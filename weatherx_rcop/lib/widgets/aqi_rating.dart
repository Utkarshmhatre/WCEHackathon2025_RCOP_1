import 'package:flutter/material.dart';

class AqiRating extends StatelessWidget {
  final int aqi;

  const AqiRating({super.key, required this.aqi});

  @override
  Widget build(BuildContext context) {
    // Convert AQI (1-5 scale) to rating out of 10
    // AQI 1 = 10, AQI 5 = 2
    final rating = 12.0 - (aqi * 2.0); // Convert to double
    final color = _getAqiColor(aqi);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '/10',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          width: 200,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 200.0 * (rating / 10.0), // Ensure doubles
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          _getRatingDescription(rating),
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _getRatingDescription(double rating) {
    if (rating >= 9) return 'Excellent';
    if (rating >= 7) return 'Good';
    if (rating >= 5) return 'Moderate';
    if (rating >= 3) return 'Poor';
    return 'Very Poor';
  }

  Color _getAqiColor(int aqi) {
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

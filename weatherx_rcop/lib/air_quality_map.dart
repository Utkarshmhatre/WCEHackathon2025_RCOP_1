import 'package:flutter/material.dart';

class AirQualityMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                'Air Quality Map',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Positioned(
              top: 50,
              left: 50,
              child: _buildAirQualityIndicator('Thane', 'Good', Colors.green),
            ),
            Positioned(
              top: 100,
              right: 50,
              child: _buildAirQualityIndicator(
                  'Mumbai', 'Moderate', Colors.yellow),
            ),
            Positioned(
              bottom: 50,
              left: 100,
              child: _buildAirQualityIndicator('Pune', 'Poor', Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAirQualityIndicator(
      String location, String quality, Color color) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.7),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(location, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(quality),
        ],
      ),
    );
  }
}

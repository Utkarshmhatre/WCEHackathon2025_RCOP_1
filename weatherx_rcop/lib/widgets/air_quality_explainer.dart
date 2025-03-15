import 'package:flutter/material.dart';

class AirQualityExplainer extends StatelessWidget {
  final bool isDarkMode;

  const AirQualityExplainer({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'Understanding Air Quality',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'The Air Quality Index (AQI) is a standardized measurement that indicates how polluted the air is. The index ranges from 1-5, with higher values indicating worse air quality.',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'AQI Index Explanation:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          _buildAqiExplanationRow(
            1,
            'Good',
            Colors.green,
            'The air is clean and safe for everyone.',
          ),
          SizedBox(height: 8),
          _buildAqiExplanationRow(
            2,
            'Fair',
            Colors.lightGreen,
            'The air is okay for most people.',
          ),
          SizedBox(height: 8),
          _buildAqiExplanationRow(
            3,
            'Moderate',
            Colors.yellow,
            'The air might affect sensitive people.',
          ),
          SizedBox(height: 8),
          _buildAqiExplanationRow(
            4,
            'Poor',
            Colors.orange,
            'The air is unhealthy and may cause problems.',
          ),
          SizedBox(height: 8),
          _buildAqiExplanationRow(
            5,
            'Very Poor',
            Colors.red,
            'The air is very unhealthy. Stay indoors if possible.',
          ),
        ],
      ),
    );
  }

  Widget _buildAqiExplanationRow(
    int aqi,
    String label,
    Color color,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Text(
            aqi.toString(),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? color : color.withOpacity(0.8),
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

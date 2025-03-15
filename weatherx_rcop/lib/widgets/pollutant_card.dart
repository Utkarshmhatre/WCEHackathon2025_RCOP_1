import 'package:flutter/material.dart';

class PollutantCard extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final String description;
  final bool isDarkMode;

  const PollutantCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.description,
    required this.isDarkMode,
  });

  Color _getColorForValue(String pollutant, double value) {
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
        if (value < 60) return Colors.green;
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

  String _getSimpleExplanation(String pollutant) {
    switch (pollutant) {
      case 'PM2.5':
        return 'Fine particles that can enter the bloodstream';
      case 'PM10':
        return 'Coarse particles that can enter the lungs';
      case 'O₃':
        return 'Ground-level ozone, key component of smog';
      case 'NO₂':
        return 'Nitrogen dioxide from combustion';
      case 'SO₂':
        return 'Sulfur dioxide from fossil fuels';
      case 'CO':
        return 'Carbon monoxide, colorless toxic gas';
      default:
        return description;
    }
  }

  IconData _getPollutantIcon(String pollutant) {
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

  @override
  Widget build(BuildContext context) {
    final color = _getColorForValue(title, value);
    final levelText = _getLevelText(title, value);
    final simpleExplanation = _getSimpleExplanation(title);
    final icon = _getPollutantIcon(title);
    final healthImpact = _getHealthImpact(title, value);

    return InkWell(
      onTap: () => _showDetailedInfo(context, color),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 18),
                    SizedBox(width: 6),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    simpleExplanation,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildLevelIndicator(color, levelText)),
                      SizedBox(width: 4),
                      Text(
                        levelText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelIndicator(Color color, String level) {
    double percentage;
    switch (level) {
      case 'Good':
        percentage = 0.2;
        break;
      case 'Okay':
        percentage = 0.4;
        break;
      case 'Medium':
        percentage = 0.6;
        break;
      case 'Bad':
        percentage = 0.8;
        break;
      case 'Very Bad':
        percentage = 1.0;
        break;
      default:
        percentage = 0.5;
    }

    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        widthFactor: percentage,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  void _showDetailedInfo(BuildContext context, Color color) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDarkMode ? Color(0xFF1A1A2E) : Colors.white,
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(_getPollutantIcon(title), color: color, size: 24),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getFullName(title),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color:
                                      isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                ),
                              ),
                              Text(
                                title,
                                style: TextStyle(
                                  color:
                                      isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoSection(
                          'Current Value',
                          '${value.toStringAsFixed(1)} $unit',
                          color,
                        ),
                        SizedBox(height: 12),
                        _buildInfoSection(
                          'What is it?',
                          _getDetailedDescription(title),
                          color,
                        ),
                        SizedBox(height: 12),
                        _buildInfoSection(
                          'Health Impact',
                          _getHealthImpact(title, value),
                          color,
                        ),
                        SizedBox(height: 12),
                        _buildInfoSection(
                          'Sources',
                          _getPollutantSources(title),
                          color,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Level: ${_getLevelText(title, value)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: _getLevelPercentage(title, value),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 100 - _getLevelPercentage(title, value),
                                child: Container(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Close', style: TextStyle(color: color)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildInfoSection(String title, String content, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            fontSize: 13,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }

  String _getFullName(String pollutant) {
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

  String _getDetailedDescription(String pollutant) {
    switch (pollutant) {
      case 'PM2.5':
        return 'Tiny particles or droplets in the air that are 2.5 microns or less in diameter. They can travel deeply into the respiratory tract and cause significant health problems.';
      case 'PM10':
        return 'Inhalable particles with diameters that are generally 10 micrometers and smaller. These particles can penetrate the lungs and potentially cause respiratory issues.';
      case 'O₃':
        return 'Ground-level ozone is formed by chemical reactions between oxides of nitrogen and volatile organic compounds in sunlight. It\'s a harmful air pollutant and a key component of smog.';
      case 'NO₂':
        return 'A reddish-brown gas with a pungent, acrid odor, formed when fossil fuels are burned at high temperatures. It can cause inflammation of the airways and is a major component of urban air pollution.';
      case 'SO₂':
        return 'A toxic gas with a strong, irritating smell, produced mainly from burning fossil fuels containing sulfur. It can form fine particles when it reacts with other substances in the atmosphere.';
      case 'CO':
        return 'An odorless, colorless gas produced by the incomplete combustion of carbon-containing fuels. It can be deadly in high concentrations as it prevents oxygen from being delivered throughout the body.';
      default:
        return 'A component of air pollution that can affect human health and the environment.';
    }
  }

  String _getHealthImpact(String pollutant, double value) {
    String baseImpact;

    switch (pollutant) {
      case 'PM2.5':
        baseImpact =
            'Can cause respiratory and cardiovascular issues, lung inflammation, and has been linked to premature death in people with heart or lung disease.';
        break;
      case 'PM10':
        baseImpact =
            'Can irritate airways, aggravate asthma, and cause coughing or breathing difficulties. May make people more susceptible to respiratory infections.';
        break;
      case 'O₃':
        baseImpact =
            'Can trigger chest pain, coughing, throat irritation, congestion, worsen bronchitis and asthma, and reduce lung function.';
        break;
      case 'NO₂':
        baseImpact =
            'Inflames the lining of the lungs, reduces immunity to lung infections, causes problems like wheezing, coughing, and potentially reduced lung function.';
        break;
      case 'SO₂':
        baseImpact =
            'Irritates the nose, throat, and airways, causing coughing, wheezing, and shortness of breath. Can worsen existing conditions like asthma.';
        break;
      case 'CO':
        baseImpact =
            'Reduces oxygen delivery to the body\'s vital organs, which can cause headache, dizziness, and at high levels, death.';
        break;
      default:
        baseImpact =
            'May have various health impacts depending on concentration levels.';
    }

    // Add severity information based on level
    String levelText = _getLevelText(pollutant, value);
    String severityInfo;

    if (levelText == 'Good') {
      severityInfo =
          'At current levels, health impact is minimal for most people.';
    } else if (levelText == 'Okay' || levelText == 'Medium') {
      severityInfo =
          'Current levels may affect unusually sensitive individuals.';
    } else if (levelText == 'Bad') {
      severityInfo =
          'Current levels could cause health effects for sensitive groups.';
    } else {
      severityInfo =
          'Current levels could cause health effects for everyone, with more serious effects for sensitive groups.';
    }

    return '$baseImpact $severityInfo';
  }

  String _getPollutantSources(String pollutant) {
    switch (pollutant) {
      case 'PM2.5':
        return 'Power plants, industrial processes, vehicle emissions, fireplaces, wood stoves, wildfires, and dust.';
      case 'PM10':
        return 'Construction sites, unpaved roads, fields, dust storms, and fires.';
      case 'O₃':
        return 'Not directly emitted but formed by chemical reactions between nitrogen oxides and volatile organic compounds in sunlight.';
      case 'NO₂':
        return 'Cars, trucks, buses, power plants, and off-road equipment.';
      case 'SO₂':
        return 'Burning of sulfur-containing fossil fuels like coal and oil, industrial activities, and volcanoes.';
      case 'CO':
        return 'Cars, trucks, and other engines that burn fossil fuels, gas stoves, leaking furnaces, and tobacco smoke.';
      default:
        return 'Various human activities and natural processes.';
    }
  }

  int _getLevelPercentage(String pollutant, double value) {
    // Return percentage based on pollutant thresholds
    switch (pollutant) {
      case 'PM2.5':
        if (value < 10) return (value / 10 * 20).round();
        if (value < 25) return 20 + ((value - 10) / 15 * 20).round();
        if (value < 50) return 40 + ((value - 25) / 25 * 20).round();
        if (value < 75) return 60 + ((value - 50) / 25 * 20).round();
        return min(80 + ((value - 75) / 25 * 20).round(), 100);
      case 'PM10':
        if (value < 20) return (value / 20 * 20).round();
        if (value < 50) return 20 + ((value - 20) / 30 * 20).round();
        if (value < 100) return 40 + ((value - 50) / 50 * 20).round();
        if (value < 200) return 60 + ((value - 100) / 100 * 20).round();
        return min(80 + ((value - 200) / 100 * 20).round(), 100);
      // Add other pollutants with appropriate thresholds
      default:
        // Generic calculation
        if (value < 20) return (value / 20 * 20).round();
        if (value < 50) return 20 + ((value - 20) / 30 * 20).round();
        if (value < 100) return 40 + ((value - 50) / 50 * 20).round();
        if (value < 200) return 60 + ((value - 100) / 100 * 20).round();
        return min(80 + ((value - 200) / 200 * 20).round(), 100);
    }
  }

  int min(int a, int b) {
    return a < b ? a : b;
  }

  String _getLevelText(String pollutant, double value) {
    // Simplified text for levels
    if (pollutant == 'PM2.5') {
      if (value < 10) return 'Good';
      if (value < 25) return 'Okay';
      if (value < 50) return 'Medium';
      if (value < 75) return 'Bad';
      return 'Very Bad';
    } else if (pollutant == 'PM10') {
      if (value < 20) return 'Good';
      if (value < 50) return 'Okay';
      if (value < 100) return 'Medium';
      if (value < 200) return 'Bad';
      return 'Very Bad';
    }
    // Add similar patterns for other pollutants
    // ...

    // Generic fallback
    if (value < 20) return 'Low';
    if (value < 50) return 'Medium';
    if (value < 100) return 'High';
    return 'Very High';
  }
}

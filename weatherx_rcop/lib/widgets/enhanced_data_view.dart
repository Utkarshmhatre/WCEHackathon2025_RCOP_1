import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/air_quality_model.dart';
import 'mobile_friendly_chart.dart';
import 'package:intl/intl.dart';

class EnhancedDataView extends StatefulWidget {
  final List<AirQuality> data;
  final String pollutant;
  final bool isDarkMode;
  final String activeView;

  const EnhancedDataView({
    super.key,
    required this.data,
    required this.pollutant,
    required this.isDarkMode,
    required this.activeView,
  });

  @override
  State<EnhancedDataView> createState() => _EnhancedDataViewState();
}

class _EnhancedDataViewState extends State<EnhancedDataView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void didUpdateWidget(EnhancedDataView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeView != widget.activeView ||
        oldWidget.pollutant != widget.pollutant) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      );
    }

    // Use FadeTransition to animate between different views
    return FadeTransition(
      opacity: _animationController.drive(CurveTween(curve: Curves.easeInOut)),
      child: _buildSelectedView(),
    );
  }

  Widget _buildSelectedView() {
    switch (widget.activeView) {
      case 'historical':
        return _buildHistoricalView();
      case 'forecast':
        return _buildForecastView();
      default:
        return _buildChartView();
    }
  }

  Widget _buildChartView() {
    return MobileFriendlyChart(
      data: widget.data,
      pollutant: widget.pollutant,
      isDarkMode: widget.isDarkMode,
    );
  }

  Widget _buildHistoricalView() {
    // Sort data by date in descending order for historical view
    final sortedData = List<AirQuality>.from(widget.data)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return ListView.builder(
      itemCount: sortedData.length,
      padding: EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final item = sortedData[index];
        final pollutantValue = _getPollutantValue(item, widget.pollutant);

        // Determine color based on pollutant value
        final color = _getPollutantColor(widget.pollutant, pollutantValue);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                _showDetailDialog(item);
              },
              borderRadius: BorderRadius.circular(12),
              splashColor: color.withOpacity(0.1),
              highlightColor: color.withOpacity(0.05),
              child: Ink(
                decoration: BoxDecoration(
                  color:
                      widget.isDarkMode
                          ? Colors.black.withOpacity(0.2)
                          : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.5), width: 1),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          pollutantValue.toStringAsFixed(1),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat(
                              'EEEE, MMMM d, yyyy',
                            ).format(item.dateTime),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  widget.isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            DateFormat('h:mm a').format(item.dateTime),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  widget.isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.pollutant,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          _getQualityText(pollutantValue),
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                widget.isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForecastView() {
    // Filter to just show future data and sort by date
    final now = DateTime.now();
    final forecastData =
        widget.data.where((item) => item.dateTime.isAfter(now)).toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    if (forecastData.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 48,
              color: widget.isDarkMode ? Colors.white30 : Colors.black26,
            ),
            SizedBox(height: 16),
            Text(
              'No forecast data available',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: forecastData.length,
      padding: EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final item = forecastData[index];
        final pollutantValue = _getPollutantValue(item, widget.pollutant);
        final color = _getPollutantColor(widget.pollutant, pollutantValue);

        // Group by date
        bool showHeader =
            index == 0 ||
            !_isSameDay(
              forecastData[index].dateTime,
              forecastData[index - 1].dateTime,
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                child: Text(
                  DateFormat('EEEE, MMMM d').format(item.dateTime),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showDetailDialog(item);
                  },
                  borderRadius: BorderRadius.circular(12),
                  splashColor: color.withOpacity(0.1),
                  highlightColor: color.withOpacity(0.05),
                  child: Ink(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          color.withOpacity(0.1),
                          widget.isDarkMode
                              ? Colors.black.withOpacity(0.1)
                              : Colors.white.withOpacity(0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          DateFormat('h:mm a').format(item.dateTime),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                widget.isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                          ),
                        ),
                        SizedBox(width: 16),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${pollutantValue.toStringAsFixed(1)} μg/m³',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.pollutant,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            Text(
                              _getQualityText(pollutantValue),
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    widget.isDarkMode
                                        ? Colors.white70
                                        : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDetailDialog(AirQuality item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: widget.isDarkMode ? Color(0xFF1A1A2E) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: -5,
                offset: Offset(0, -5),
              ),
            ],
          ),
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                DateFormat('EEEE, MMMM d, yyyy • h:mm a').format(item.dateTime),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Air Quality Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildDetailTile('PM2.5', item.pm2_5, 'μg/m³'),
                  _buildDetailTile('PM10', item.pm10, 'μg/m³'),
                  _buildDetailTile('O₃', item.o3, 'μg/m³'),
                  _buildDetailTile('NO₂', item.no2, 'μg/m³'),
                  _buildDetailTile('SO₂', item.so2, 'μg/m³'),
                  _buildDetailTile('CO', item.co, 'μg/m³'),
                ],
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close),
                    label: Text('Close'),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          widget.isDarkMode ? Colors.white70 : Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailTile(String title, double value, String unit) {
    final color = _getPollutantColor(title, value);

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 12,
              color: widget.isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
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

  Color _getPollutantColor(String pollutant, double value) {
    // Based on standardized thresholds for each pollutant
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
      default:
        // Generic thresholds for other pollutants
        if (value < 20) return Colors.green;
        if (value < 50) return Colors.lightGreen;
        if (value < 100) return Colors.yellow;
        if (value < 200) return Colors.orange;
        return Colors.red;
    }
  }

  String _getQualityText(double value) {
    // Universal quality descriptions
    if (value < 20) return 'Excellent';
    if (value < 50) return 'Good';
    if (value < 100) return 'Moderate';
    if (value < 200) return 'Poor';
    return 'Very Poor';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

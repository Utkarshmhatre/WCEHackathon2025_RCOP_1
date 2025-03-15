import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/air_quality_model.dart';
import 'chart_painters.dart';

class MobileFriendlyChart extends StatefulWidget {
  final List<AirQuality> data;
  final String pollutant;
  final bool isDarkMode;

  const MobileFriendlyChart({
    super.key,
    required this.data,
    required this.pollutant,
    required this.isDarkMode,
  });

  @override
  State<MobileFriendlyChart> createState() => _MobileFriendlyChartState();
}

class _MobileFriendlyChartState extends State<MobileFriendlyChart>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  int? _selectedIndex;
  bool _isFullScreen = false;
  String _chartType = 'bars'; // 'bars', 'line', 'area'

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MobileFriendlyChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data ||
        oldWidget.pollutant != widget.pollutant) {
      _animationController.reset();
      _animationController.forward();
      _selectedIndex = null;
    }
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

    // Sort data by date
    final List<AirQuality> sortedData = List<AirQuality>.from(widget.data)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // Get min and max values for visualization
    double minValue = double.infinity;
    double maxValue = 0;
    for (var item in sortedData) {
      final value = _getPollutantValue(item, widget.pollutant);
      if (value < minValue) minValue = value;
      if (value > maxValue) maxValue = value;
    }

    // Padding for better visibility
    minValue = minValue * 0.8;
    maxValue = maxValue * 1.2;

    // Detect orientation
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Handle fullscreen mode
    if (_isFullScreen) {
      return Scaffold(
        backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
        appBar: AppBar(
          title: Text('${widget.pollutant} Chart'),
          backgroundColor: widget.isDarkMode ? Color(0xFF1A1A2E) : Colors.blue,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _isFullScreen = false;
              });
            },
          ),
          actions: [
            _buildChartTypeSelector(),
            IconButton(
              icon: Icon(Icons.rotate_90_degrees_ccw),
              tooltip: 'Rotate Screen',
              onPressed: () {
                final newOrientation =
                    isLandscape
                        ? DeviceOrientation.portraitUp
                        : DeviceOrientation.landscapeLeft;
                SystemChrome.setPreferredOrientations([newOrientation]);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: _buildChartContent(sortedData, minValue, maxValue, true),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart options and controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Min/Max indicators
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Min: ${minValue.toStringAsFixed(1)} μg/m³',
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          widget.isDarkMode ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Max: ${maxValue.toStringAsFixed(1)} μg/m³',
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          widget.isDarkMode ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),

              // Chart controls
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildChartTypeSelector(),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.fullscreen,
                      color:
                          widget.isDarkMode
                              ? Colors.white70
                              : Colors.blueAccent,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _isFullScreen = true;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Chart content
        Expanded(
          child: _buildChartContent(sortedData, minValue, maxValue, false),
        ),

        // Instructions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Text(
            '← Scroll to view more data • Tap bars for details',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: widget.isDarkMode ? Colors.white30 : Colors.black38,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildChartContent(
    List<AirQuality> sortedData,
    double minValue,
    double maxValue,
    bool isFullScreen,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main chart area
        Expanded(
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  // Choose the right chart type based on selection
                  switch (_chartType) {
                    case 'line':
                      return _buildLineChart(
                        sortedData,
                        minValue,
                        maxValue,
                        isFullScreen,
                      );
                    case 'area':
                      return _buildAreaChart(
                        sortedData,
                        minValue,
                        maxValue,
                        isFullScreen,
                      );
                    case 'bars':
                    default:
                      return _buildBarChart(
                        sortedData,
                        minValue,
                        maxValue,
                        isFullScreen,
                      );
                  }
                },
              ),
            ),
          ),
        ),

        // Selected item details
        if (_selectedIndex != null)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  widget.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat(
                    'EEEE, MMMM d, yyyy • h:mm a',
                  ).format(sortedData[_selectedIndex!].dateTime),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${widget.pollutant}: ${_getPollutantValue(sortedData[_selectedIndex!], widget.pollutant).toStringAsFixed(1)} μg/m³',
                  style: TextStyle(
                    fontSize: 14,
                    color: _getPollutantColor(
                      widget.pollutant,
                      _getPollutantValue(
                        sortedData[_selectedIndex!],
                        widget.pollutant,
                      ),
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildChartTypeSelector() {
    return DropdownButton<String>(
      value: _chartType,
      icon: Icon(
        Icons.arrow_drop_down,
        color: widget.isDarkMode ? Colors.white70 : Colors.blueAccent,
      ),
      elevation: 16,
      style: TextStyle(
        color: widget.isDarkMode ? Colors.white70 : Colors.blueAccent,
        fontSize: 12,
      ),
      underline: Container(), // Remove underline
      dropdownColor: widget.isDarkMode ? Color(0xFF1A1A2E) : Colors.white,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _chartType = newValue;
          });
        }
      },
      items: [
        DropdownMenuItem(
          value: 'bars',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bar_chart,
                size: 16,
                color: widget.isDarkMode ? Colors.white70 : Colors.blueAccent,
              ),
              SizedBox(width: 8),
              Text('Bar Chart'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'line',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.show_chart,
                size: 16,
                color: widget.isDarkMode ? Colors.white70 : Colors.blueAccent,
              ),
              SizedBox(width: 8),
              Text('Line Chart'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'area',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.area_chart,
                size: 16,
                color: widget.isDarkMode ? Colors.white70 : Colors.blueAccent,
              ),
              SizedBox(width: 8),
              Text('Area Chart'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(
    List<AirQuality> sortedData,
    double minValue,
    double maxValue,
    bool isFullScreen,
  ) {
    final chartHeight =
        isFullScreen ? MediaQuery.of(context).size.height * 0.8 : 150.0;

    final chartWidth = max(
      MediaQuery.of(context).size.width,
      sortedData.length * 60.0,
    );

    // Use a SizedBox with a fixed width and height
    return SizedBox(
      width: chartWidth,
      height: chartHeight,
      child: Row(
        children:
            sortedData.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final value = _getPollutantValue(item, widget.pollutant);
              final percentage = ((value - minValue) / (maxValue - minValue))
                  .clamp(0.0, 1.0);
              final color = _getPollutantColor(widget.pollutant, value);
              final isSelected = _selectedIndex == index;

              // Fixed width for each bar item
              return SizedBox(
                width: chartWidth / sortedData.length,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedIndex = isSelected ? null : index;
                    });
                  },
                  // Use Stack for absolute positioning to avoid overflows
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Bar
                      Positioned(
                        bottom: 26, // Increased from 24 to 26 to avoid overflow
                        width: isSelected ? 10 : 6,
                        height:
                            (chartHeight - 26) *
                            percentage *
                            _animationController.value, // Also adjust here
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [color.withOpacity(0.4), color],
                            ),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                            boxShadow:
                                isSelected
                                    ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ]
                                    : null,
                          ),
                        ),
                      ),

                      // Value tooltip when selected
                      if (isSelected)
                        Positioned(
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              value.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 10,
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      // Date labels (fixed height to prevent overflow)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 26, // Increased from 24 to 26
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('HH:mm').format(item.dateTime),
                              style: TextStyle(
                                fontSize: 8, // Decreased from 9 to 8
                                color:
                                    widget.isDarkMode
                                        ? Colors.white60
                                        : Colors.black54,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                              maxLines: 1,
                            ),
                            SizedBox(
                              height: 1,
                            ), // Add a tiny space between the texts
                            Text(
                              DateFormat('dd/MM').format(item.dateTime),
                              style: TextStyle(
                                fontSize: 8, // Decreased from 9 to 8
                                color:
                                    widget.isDarkMode
                                        ? Colors.white60
                                        : Colors.black54,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildLineChart(
    List<AirQuality> sortedData,
    double minValue,
    double maxValue,
    bool isFullScreen,
  ) {
    final chartHeight =
        isFullScreen ? MediaQuery.of(context).size.height * 0.8 : 150.0;

    final chartWidth = max(
      MediaQuery.of(context).size.width,
      sortedData.length * 60.0,
    );

    return SizedBox(
      width: chartWidth,
      height: chartHeight,
      child: Stack(
        children: [
          // Chart Canvas with Line Painter
          CustomPaint(
            size: Size(chartWidth, chartHeight),
            painter: LineChartPainter(
              data: sortedData,
              pollutant: widget.pollutant,
              minValue: minValue,
              maxValue: maxValue,
              isDarkMode: widget.isDarkMode,
              animationValue: _animationController.value,
            ),
          ),

          // Interactive overlay for touch events
          GestureDetector(
            onTapUp: (details) {
              final touchX = details.localPosition.dx;
              final itemWidth = chartWidth / sortedData.length;
              final index = (touchX / itemWidth).floor();

              if (index >= 0 && index < sortedData.length) {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedIndex = _selectedIndex == index ? null : index;
                });
              }
            },
            child: Container(color: Colors.transparent),
          ),

          // Data points
          ...sortedData.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final value = _getPollutantValue(item, widget.pollutant);
            final percentage = ((value - minValue) / (maxValue - minValue))
                .clamp(0.0, 1.0);
            final color = _getPollutantColor(widget.pollutant, value);
            final isSelected = _selectedIndex == index;

            final xPosition = (index + 0.5) * (chartWidth / sortedData.length);
            final yPosition = (chartHeight - 25) * (1 - percentage);

            return Positioned(
              left: xPosition - (isSelected ? 6 : 4),
              top: yPosition - (isSelected ? 6 : 4),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedIndex = isSelected ? null : index;
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: isSelected ? 12 : 8,
                  height: isSelected ? 12 : 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 4,
                              ),
                            ]
                            : null,
                  ),
                ),
              ),
            );
          }),

          // Date labels at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 25,
            child: Row(
              children:
                  sortedData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = _selectedIndex == index;

                    return Expanded(
                      child: Text(
                        DateFormat('HH:mm').format(item.dateTime),
                        style: TextStyle(
                          fontSize: 9,
                          color:
                              widget.isDarkMode
                                  ? Colors.white60
                                  : Colors.black54,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaChart(
    List<AirQuality> sortedData,
    double minValue,
    double maxValue,
    bool isFullScreen,
  ) {
    final chartHeight =
        isFullScreen ? MediaQuery.of(context).size.height * 0.8 : 150.0;

    final chartWidth = max(
      MediaQuery.of(context).size.width,
      sortedData.length * 60.0,
    );

    return SizedBox(
      width: chartWidth,
      height: chartHeight,
      child: Stack(
        children: [
          // Chart Canvas with Area Painter
          CustomPaint(
            size: Size(chartWidth, chartHeight),
            painter: AreaChartPainter(
              data: sortedData,
              pollutant: widget.pollutant,
              minValue: minValue,
              maxValue: maxValue,
              isDarkMode: widget.isDarkMode,
              animationValue: _animationController.value,
            ),
          ),

          // Interactive overlay
          GestureDetector(
            onTapUp: (details) {
              final touchX = details.localPosition.dx;
              final itemWidth = chartWidth / sortedData.length;
              final index = (touchX / itemWidth).floor();

              if (index >= 0 && index < sortedData.length) {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedIndex = _selectedIndex == index ? null : index;
                });
              }
            },
            child: Container(color: Colors.transparent),
          ),

          // Data points
          ...sortedData.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final value = _getPollutantValue(item, widget.pollutant);
            final percentage = ((value - minValue) / (maxValue - minValue))
                .clamp(0.0, 1.0);
            final color = _getPollutantColor(widget.pollutant, value);
            final isSelected = _selectedIndex == index;

            final xPosition = (index + 0.5) * (chartWidth / sortedData.length);
            final yPosition = (chartHeight - 25) * (1 - percentage);

            return Positioned(
              left: xPosition - (isSelected ? 6 : 4),
              top: yPosition - (isSelected ? 6 : 4),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedIndex = isSelected ? null : index;
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: isSelected ? 12 : 8,
                  height: isSelected ? 12 : 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 4,
                              ),
                            ]
                            : null,
                  ),
                ),
              ),
            );
          }),

          // Date labels at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 25,
            child: Row(
              children:
                  sortedData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = _selectedIndex == index;

                    return Expanded(
                      child: Text(
                        DateFormat('HH:mm').format(item.dateTime),
                        style: TextStyle(
                          fontSize: 9,
                          color:
                              widget.isDarkMode
                                  ? Colors.white60
                                  : Colors.black54,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
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

  // Helper to calculate max between two values
  double max(double a, double b) {
    return a > b ? a : b;
  }
}

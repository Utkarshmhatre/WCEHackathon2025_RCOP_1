import 'package:flutter/material.dart';
import '../utils/pollutant_info.dart';

class PollutantInfoDialog extends StatefulWidget {
  final String pollutant;
  final bool isDarkMode;

  const PollutantInfoDialog({
    super.key,
    required this.pollutant,
    required this.isDarkMode,
  });

  @override
  State<PollutantInfoDialog> createState() => _PollutantInfoDialogState();
}

class _PollutantInfoDialogState extends State<PollutantInfoDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = PollutantInfo.getInfo(widget.pollutant);

    if (info == null) {
      return AlertDialog(
        title: Text('Information Not Available'),
        content: Text('No information available for ${widget.pollutant}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      );
    }

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: widget.isDarkMode ? Color(0xFF1A1A2E) : Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with pollutant name and close button
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getPollutantColor(widget.pollutant),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info['title'] ?? widget.pollutant,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.pollutant,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),

                // Tab bar for different sections
                SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.6),
                  indicatorColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: [
                    Tab(text: 'Overview'),
                    Tab(text: 'Health'),
                    Tab(text: 'Sources'),
                    Tab(text: 'Standards'),
                  ],
                ),
              ],
            ),
          ),

          // Content with tabs
          SizedBox(
            height: 300, // Increased height for more content
            child: TabBarView(
              controller: _tabController,
              children: [
                // Overview tab
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoHeader('What is ${widget.pollutant}?'),
                      SizedBox(height: 8),
                      Text(
                        info['description'] ?? 'No description available.',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              widget.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildInfoHeader('WHO Guidelines'),
                      SizedBox(height: 8),
                      _buildGuideline(
                        widget.pollutant,
                        info['guidelines'] ?? 'No guideline data available.',
                      ),
                      SizedBox(height: 16),
                      _buildInfoHeader('Monitoring Methods'),
                      SizedBox(height: 8),
                      Text(
                        info['monitoring'] ??
                            'No monitoring information available.',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              widget.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                // Health effects tab
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoHeader('Health Effects'),
                      SizedBox(height: 8),
                      Text(
                        info['health_effects'] ??
                            'No health effects information available.',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              widget.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildInfoHeader('Short-term Exposure'),
                      SizedBox(height: 8),
                      Text(
                        info['short_term_effects'] ??
                            'No short-term exposure information available.',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              widget.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildInfoHeader('Long-term Exposure'),
                      SizedBox(height: 8),
                      Text(
                        info['long_term_effects'] ??
                            'No long-term exposure information available.',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              widget.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildInfoHeader('Vulnerable Groups'),
                      SizedBox(height: 8),
                      Text(
                        info['vulnerable_groups'] ??
                            'No information on vulnerable groups available.',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              widget.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                // Sources tab
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoHeader('Common Sources'),
                      SizedBox(height: 8),
                      Text(
                        info['sources'] ?? 'No source information available.',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              widget.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildInfoHeader('Natural Sources'),
                      SizedBox(height: 8),
                      Text(
                        info['natural_sources'] ??
                            'No natural source information available.',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              widget.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildInfoHeader('Human Activities'),
                      SizedBox(height: 8),
                      Text(
                        info['human_sources'] ??
                            'No human source information available.',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              widget.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                // Standards tab
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoHeader('Air Quality Standards'),
                      SizedBox(height: 8),
                      _buildStandardsTable(widget.pollutant),
                      SizedBox(height: 16),
                      _buildInfoHeader('Interpretation'),
                      SizedBox(height: 8),
                      Text(
                        info['standards_interpretation'] ??
                            'Standards vary by country and organization. They represent thresholds designed to protect public health.',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              widget.isDarkMode
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

          // Action buttons at bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.info_outline),
                  label: Text('Learn More'),
                  style: TextButton.styleFrom(
                    foregroundColor: _getPollutantColor(widget.pollutant),
                  ),
                  onPressed: () {
                    // Could open a web view or external resource
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('External resources would open here'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getPollutantColor(widget.pollutant),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: widget.isDarkMode ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildGuideline(String pollutant, String guidelineText) {
    IconData icon;
    String unit;

    switch (pollutant) {
      case 'PM2.5':
        icon = Icons.blur_on;
        unit = 'μg/m³';
        break;
      case 'PM10':
        icon = Icons.grain;
        unit = 'μg/m³';
        break;
      case 'O₃':
        icon = Icons.air;
        unit = 'μg/m³';
        break;
      default:
        icon = Icons.science;
        unit = 'μg/m³';
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getPollutantColor(pollutant).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getPollutantColor(pollutant).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: _getPollutantColor(pollutant), size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WHO Air Quality Guideline',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  guidelineText,
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardsTable(String pollutant) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.isDarkMode ? Colors.white30 : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade100,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Organization',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Standard',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Averaging Time',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Table rows based on pollutant type
          ..._getStandardsForPollutant(pollutant),
        ],
      ),
    );
  }

  List<Widget> _getStandardsForPollutant(String pollutant) {
    switch (pollutant) {
      case 'PM2.5':
        return [
          _buildStandardRow('WHO', '5', 'Annual mean'),
          _buildStandardRow('WHO', '15', '24-hour mean'),
          _buildStandardRow('EPA (US)', '12', 'Annual mean'),
          _buildStandardRow('EPA (US)', '35', '24-hour mean'),
          _buildStandardRow('EU', '20', 'Annual mean'),
        ];
      case 'PM10':
        return [
          _buildStandardRow('WHO', '15', 'Annual mean'),
          _buildStandardRow('WHO', '45', '24-hour mean'),
          _buildStandardRow('EPA (US)', '150', '24-hour mean'),
          _buildStandardRow('EU', '40', 'Annual mean'),
        ];
      case 'O₃':
        return [
          _buildStandardRow('WHO', '100', '8-hour mean'),
          _buildStandardRow('EPA (US)', '70 ppb', '8-hour mean'),
          _buildStandardRow('EU', '120', 'Max daily 8-hour'),
        ];
      case 'NO₂':
        return [
          _buildStandardRow('WHO', '10', 'Annual mean'),
          _buildStandardRow('WHO', '25', '24-hour mean'),
          _buildStandardRow('EPA (US)', '53 ppb', 'Annual mean'),
          _buildStandardRow('EPA (US)', '100 ppb', '1-hour mean'),
        ];
      case 'SO₂':
        return [
          _buildStandardRow('WHO', '40', '24-hour mean'),
          _buildStandardRow('EPA (US)', '75 ppb', '1-hour mean'),
          _buildStandardRow('EU', '125', '24-hour mean'),
        ];
      case 'CO':
        return [
          _buildStandardRow('WHO', '4', '24-hour mean'),
          _buildStandardRow('EPA (US)', '9 ppm', '8-hour mean'),
          _buildStandardRow('EPA (US)', '35 ppm', '1-hour mean'),
        ];
      default:
        return [_buildStandardRow('Various', 'Varies', 'Different periods')];
    }
  }

  Widget _buildStandardRow(
    String organization,
    String value,
    String timeframe,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              organization,
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              timeframe,
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPollutantColor(String pollutant) {
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
}

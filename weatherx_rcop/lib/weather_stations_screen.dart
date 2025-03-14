import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'site.dart';
import 'theme_provider.dart';

class WeatherStationsScreen extends StatefulWidget {
  @override
  _ApiPageState createState() => _ApiPageState();
}

class _ApiPageState extends State<WeatherStationsScreen> {
  List<Site> sites = [];
  int page = 0;
  bool isLoading = true;

  Future<void> loadSiteData() async {
    setState(() {
      if (page == 0) isLoading = true;
    });

    try {
      String jsonString = await rootBundle.loadString('assets/site_ids.json');
      List<dynamic> jsonResponse = json.decode(jsonString);

      setState(() {
        int start = page * 5;
        int end = start + 5;
        if (end > jsonResponse.length) end = jsonResponse.length;

        if (start < jsonResponse.length) {
          List<Site> newSites =
              jsonResponse
                  .sublist(start, end)
                  .map<Site>((siteJson) => Site.fromJson(siteJson))
                  .toList();
          sites.addAll(newSites);
          page++;
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error loading site data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadSiteData();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:
              isDarkMode
                  ? [Color(0xFF1A1A2E), Color(0xFF16213E)]
                  : [Color(0xFF87CEEB), Color(0xFF1E90FF)],
        ),
      ),
      child: SafeArea(
        bottom:
            false, // Don't apply SafeArea at bottom since we handle it manually
        child: Padding(
          // Add padding at the bottom to prevent overlap with navigation bar
          padding: const EdgeInsets.only(bottom: 95),
          child:
              isLoading && sites.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          "Loading site data...",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                  : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Weather Stations Data',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: sites.length,
                          itemBuilder: (context, index) {
                            Site site = sites[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          isDarkMode
                                              ? Colors.white.withOpacity(0.05)
                                              : Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            site.name,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  isDarkMode
                                                      ? Colors.white
                                                      : Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Location: ${site.city}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  isDarkMode
                                                      ? Colors.white70
                                                      : Colors.black54,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Coordinates: ${site.lat.toStringAsFixed(4)}, ${site.lon.toStringAsFixed(4)}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  isDarkMode
                                                      ? Colors.white70
                                                      : Colors.black54,
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              _buildInfoChip(
                                                'Conditions',
                                                site.conditions ?? 'Unknown',
                                                isDarkMode,
                                              ),
                                              _buildInfoChip(
                                                'Avg',
                                                site.avg?.toStringAsFixed(1) ??
                                                    'N/A',
                                                isDarkMode,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: loadSiteData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDarkMode ? Colors.white10 : Colors.white,
                            foregroundColor:
                                isDarkMode ? Colors.white : Colors.blueAccent,
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text("Load More Data"),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.white60 : Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

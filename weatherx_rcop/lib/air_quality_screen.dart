import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for HapticFeedback
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:ui';
import 'dart:async'; // Add this import for debounce timer
import '../services/weather_service.dart';
import 'models/air_quality_model.dart';
import 'theme_provider.dart';
import 'widgets/pollutant_card.dart';
import 'widgets/aqi_gauge.dart';
import 'widgets/air_quality_chart.dart';
import 'widgets/aqi_rating.dart';
import 'widgets/pollutant_info_dialog.dart';
import 'widgets/air_quality_explainer.dart';
import 'widgets/enhanced_data_view.dart'; // Add this import for EnhancedDataView
import 'providers/air_quality_selections.dart';

class AirQualityScreen extends StatefulWidget {
  const AirQualityScreen({super.key});

  @override
  _AirQualityScreenState createState() => _AirQualityScreenState();
}

class _AirQualityScreenState extends State<AirQualityScreen>
    with SingleTickerProviderStateMixin {
  final _weatherService = WeatherService('4ff6eddbdab716e97b0ba1a6a87fd510');

  AirQuality? _currentAirQuality;
  List<AirQuality>? _forecastAirQuality;
  String _currentLocationName = "Your Location";

  // Added for location search
  final TextEditingController _locationController = TextEditingController();
  bool _isSearching = false;
  List<AirQuality>? _searchedLocationAirQuality;
  String? _searchedLocationName;

  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _fadeController;

  // Create the selections provider
  final AirQualitySelections _selections = AirQualitySelections();

  // Added for search suggestions
  List<String> _searchSuggestions = [];
  bool _showSuggestions = false;
  Timer? _debounceTimer;
  FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadAirQualityData();
    _searchFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    _fadeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    // Show suggestions when the search field gains focus
    if (_searchFocusNode.hasFocus && _locationController.text.isNotEmpty) {
      _fetchSuggestions(_locationController.text);
    }
  }

  Future<void> _loadAirQualityData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await _weatherService.getCurrentPosition();
      print('Current position: ${position.latitude}, ${position.longitude}');

      // Get location name
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final locality = placemarks[0].locality ?? '';
        final administrativeArea = placemarks[0].administrativeArea ?? '';
        _currentLocationName =
            locality.isNotEmpty
                ? locality
                : (administrativeArea.isNotEmpty
                    ? administrativeArea
                    : "Your Location");
      }

      // First get current air quality
      final currentData = await _weatherService.getCurrentAirQuality(
        position.latitude,
        position.longitude,
      );

      // Then fetch forecast data
      final forecastData = await _weatherService.getForecastAirQuality(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _currentAirQuality = currentData;
        _forecastAirQuality = forecastData;
        _isLoading = false;
        _fadeController.forward(from: 0.0);
      });
    } catch (e) {
      print('Error loading air quality data: $e');
      setState(() {
        _errorMessage =
            'Unable to load air quality data. Please try again later.';
        _isLoading = false;
      });
    }
  }

  // Add search location air quality method
  Future<void> _searchLocationAirQuality() async {
    final location = _locationController.text.trim();
    if (location.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchedLocationName = null;
      _searchedLocationAirQuality = null;
    });

    try {
      // Get coordinates for the location
      List<Location> locations = await locationFromAddress(location);

      if (locations.isEmpty) {
        setState(() {
          _isSearching = false;
          _errorMessage = "Couldn't find the location '$location'";
        });
        return;
      }

      final lat = locations[0].latitude;
      final lon = locations[0].longitude;

      // Get air quality data for the coordinates
      final airQualityData = await _weatherService.getCurrentAirQuality(
        lat,
        lon,
      );
      final forecastData = await _weatherService.getForecastAirQuality(
        lat,
        lon,
      );

      setState(() {
        _searchedLocationName = location;
        _searchedLocationAirQuality = [airQualityData];
        _forecastAirQuality = forecastData;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _errorMessage = "Error searching for air quality data: $e";
      });
      print('Error searching air quality: $e');
    }
  }

  // Add this method to fetch search suggestions
  Future<void> _fetchSuggestions(String query) async {
    // Cancel any previous debounce timer
    _debounceTimer?.cancel();

    // Don't search for very short queries
    if (query.length < 2) {
      setState(() {
        _searchSuggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    // Debounce input to avoid too many API calls
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        final suggestions = await _weatherService.getCitySuggestions(query);
        setState(() {
          _searchSuggestions = suggestions;
          _showSuggestions = suggestions.isNotEmpty;
        });
      } catch (e) {
        print('Error fetching suggestions: $e');
      }
    });
  }

  String _getCurrentDateTime() {
    final now = DateTime.now();
    return DateFormat('EEEE, MMMM d • h:mm a').format(now);
  }

  void _showPollutantInfo(
    BuildContext context,
    String pollutant,
    bool isDarkMode,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PollutantInfoDialog(
          pollutant: pollutant,
          isDarkMode: isDarkMode,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return ChangeNotifierProvider.value(
      value: _selections,
      child: Container(
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
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 95),
            child:
                _isLoading
                    ? _buildLoadingView()
                    : _errorMessage != null
                    ? _buildErrorView()
                    : _buildAirQualityContent(isDarkMode),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset('assets/loading.json', height: 120, width: 120),
          const SizedBox(height: 16),
          Text(
            "Loading air quality data...",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 70, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadAirQualityData,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAirQualityContent(bool isDarkMode) {
    if (_currentAirQuality == null && _searchedLocationAirQuality == null) {
      return Center(
        child: Text(
          "No air quality data available",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    // Use searched location if available, otherwise use current location
    final airQualityData =
        _searchedLocationAirQuality != null &&
                _searchedLocationAirQuality!.isNotEmpty
            ? _searchedLocationAirQuality![0]
            : _currentAirQuality!;

    final locationName = _searchedLocationName ?? _currentLocationName;

    return FadeTransition(
      opacity: _fadeController,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and date
            const Text(
              'Air Quality Index',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _getCurrentDateTime(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            // Add location search bar
            _buildLocationSearchBar(isDarkMode),
            const SizedBox(height: 16),

            // Main AQI card with enhanced rating
            _buildEnhancedAqiCard(isDarkMode, airQualityData, locationName),
            const SizedBox(height: 16),

            // Replace kid-friendly with universal approach
            _buildAirQualityAdvisory(isDarkMode, airQualityData),
            const SizedBox(height: 24),

            // Customizable dashboard section
            _buildCustomizableDashboard(isDarkMode),
            const SizedBox(height: 24),

            // Interactive chart section updated to use EnhancedDataView
            Consumer<AirQualitySelections>(
              builder: (context, selections, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${selections.selectedPollutant} Analysis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.info_outline, color: Colors.white),
                          onPressed:
                              () => _showPollutantInfo(
                                context,
                                selections.selectedPollutant,
                                isDarkMode,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      height: 260, // Slightly taller for the enhanced view
                      child:
                          _forecastAirQuality != null &&
                                  _forecastAirQuality!.isNotEmpty
                              ? EnhancedDataView(
                                data: _forecastAirQuality!,
                                pollutant: selections.selectedPollutant,
                                isDarkMode: isDarkMode,
                                activeView: selections.activeView,
                              )
                              : Center(
                                child: Text(
                                  'No data available',
                                  style: TextStyle(
                                    color:
                                        isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                  ),
                                ),
                              ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Standard pollutants grid
            Text(
              'Pollutants',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPollutantsGrid(isDarkMode, airQualityData),

            // Include forecast section if we have data
            if (_forecastAirQuality != null && _forecastAirQuality!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildForecastSection(isDarkMode),
                ],
              ),

            // Add air quality explainer
            const SizedBox(height: 24),
            AirQualityExplainer(isDarkMode: isDarkMode),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSearchBar(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.7),
            // Remove the duplicate borderRadius property
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16),
              bottom: Radius.circular(_showSuggestions ? 0 : 16),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _locationController,
                  focusNode: _searchFocusNode,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search for a city...',
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.search,
                      color: isDarkMode ? Colors.white70 : Colors.blueAccent,
                    ),
                  ),
                  onChanged: (value) {
                    _fetchSuggestions(value);
                  },
                  onSubmitted: (_) {
                    _searchLocationAirQuality();
                    setState(() {
                      _showSuggestions = false;
                    });
                  },
                ),
              ),
              _isSearching
                  ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDarkMode ? Colors.white : Colors.blueAccent,
                    ),
                  )
                  : IconButton(
                    icon: Icon(
                      Icons.arrow_forward,
                      color: isDarkMode ? Colors.white70 : Colors.blueAccent,
                    ),
                    onPressed: () {
                      _searchLocationAirQuality();
                      setState(() {
                        _showSuggestions = false;
                      });
                      FocusScope.of(context).unfocus();
                    },
                  ),
            ],
          ),
        ),

        // Display suggestions below the search bar
        if (_showSuggestions && _searchSuggestions.isNotEmpty)
          Container(
            constraints: BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? Colors.black.withOpacity(0.7)
                      : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _searchSuggestions.length,
              itemBuilder: (context, index) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _locationController.text = _searchSuggestions[index];
                        _showSuggestions = false;
                      });
                      _searchLocationAirQuality();
                      FocusScope.of(context).unfocus();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color:
                                isDarkMode
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.2),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color:
                                isDarkMode ? Colors.white70 : Colors.blueAccent,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _searchSuggestions[index],
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEnhancedAqiCard(
    bool isDarkMode,
    AirQuality airQuality,
    String locationName,
  ) {
    final aqi = airQuality.aqi;
    final description = airQuality.getAqiDescription();
    final color = airQuality.getAqiColor();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.7), color.withOpacity(0.4)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Air Quality in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            locationName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'AQI: $aqi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Use the rating widget
          AqiRating(aqi: aqi),

          SizedBox(height: 16),
          Text(
            _getKidFriendlyRecommendation(aqi),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),

          // Refresh button at bottom
          TextButton.icon(
            onPressed: _loadAirQualityData,
            icon: Icon(Icons.refresh, color: Colors.white),
            label: Text('Refresh Data', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAirQualityAdvisory(bool isDarkMode, AirQuality airQuality) {
    final aqi = airQuality.aqi;

    // Advisory text and icons that appeal to all age groups
    String iconName;
    String heading;
    String advice;
    IconData iconData;

    switch (aqi) {
      case 1:
        iconData = Icons.check_circle_outline;
        heading = "Good Air Quality";
        advice =
            "Air quality is satisfactory and poses little or no health risk.";
        break;
      case 2:
        iconData = Icons.thumb_up_outlined;
        heading = "Fair Air Quality";
        advice =
            "Air quality is acceptable. However, there may be some health concerns for a very small number of unusually sensitive individuals.";
        break;
      case 3:
        iconData = Icons.info_outline;
        heading = "Moderate Air Quality";
        advice =
            "Members of sensitive groups may experience health effects. The general public is less likely to be affected.";
        break;
      case 4:
        iconData = Icons.warning_amber_outlined;
        heading = "Poor Air Quality";
        advice =
            "Everyone may begin to experience health effects. Members of sensitive groups may experience more serious effects.";
        break;
      case 5:
        iconData = Icons.dangerous_outlined;
        heading = "Very Poor Air Quality";
        advice =
            "Health alert: The risk of health effects is increased for everyone. Avoid prolonged outdoor exertion.";
        break;
      default:
        iconData = Icons.help_outline;
        heading = "Air Quality Unknown";
        advice = "Information about air quality is currently unavailable.";
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: airQuality.getAqiColor().withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, color: airQuality.getAqiColor(), size: 24),
              SizedBox(width: 12),
              Text(
                heading,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            advice,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          SizedBox(height: 12),
          _buildHealthTips(aqi, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildHealthTips(int aqi, bool isDarkMode) {
    List<String> tips = [];

    switch (aqi) {
      case 1:
        tips = [
          "Perfect for outdoor activities",
          "Ventilate your home with fresh air",
          "Enjoy the clean air conditions",
        ];
        break;
      case 2:
        tips = [
          "Most people can continue outdoor activities",
          "Sensitive individuals should monitor their health",
          "Good time for moderate outdoor exercise",
        ];
        break;
      case 3:
        tips = [
          "Sensitive groups should limit prolonged outdoor exertion",
          "Consider indoor activities if you experience symptoms",
          "Keep windows closed during peak traffic hours",
        ];
        break;
      case 4:
        tips = [
          "Reduce prolonged or heavy outdoor exertion",
          "Sensitive groups should avoid outdoor activities",
          "Use air purifiers indoors if available",
        ];
        break;
      case 5:
        tips = [
          "Avoid outdoor physical activities",
          "Keep windows and doors closed",
          "Wear masks (N95 or N99) if you must go outside",
        ];
        break;
      default:
        tips = [
          "Monitor air quality reports",
          "Follow health authority recommendations",
        ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Health Tips:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        ...tips.map(
          (tip) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check,
                  size: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Updated to pass AirQuality directly
  Widget _buildPollutantsGrid(bool isDarkMode, AirQuality airQuality) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        PollutantCard(
          title: 'PM2.5',
          value: airQuality.pm2_5,
          unit: 'μg/m³',
          description: 'Fine particles',
          isDarkMode: isDarkMode,
        ),
        PollutantCard(
          title: 'PM10',
          value: airQuality.pm10,
          unit: 'μg/m³',
          description: 'Coarse particles',
          isDarkMode: isDarkMode,
        ),
        PollutantCard(
          title: 'O₃',
          value: airQuality.o3,
          unit: 'μg/m³',
          description: 'Ozone',
          isDarkMode: isDarkMode,
        ),
        PollutantCard(
          title: 'NO₂',
          value: airQuality.no2,
          unit: 'μg/m³',
          description: 'Nitrogen dioxide',
          isDarkMode: isDarkMode,
        ),
        PollutantCard(
          title: 'SO₂',
          value: airQuality.so2,
          unit: 'μg/m³',
          description: 'Sulfur dioxide',
          isDarkMode: isDarkMode,
        ),
        PollutantCard(
          title: 'CO',
          value: airQuality.co,
          unit: 'μg/m³',
          description: 'Carbon monoxide',
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  Widget _buildCustomizableDashboard(bool isDarkMode) {
    return Consumer<AirQualitySelections>(
      builder: (context, selections, child) {
        return Container(
          padding: EdgeInsets.all(16),
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
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Data Dashboard',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.dashboard_customize,
                      size: 18,
                      color: isDarkMode ? Colors.white : Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Improved pollutant selection with animations
              Text(
                'Select Pollutant:',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selections.pollutants.length,
                  itemBuilder: (context, index) {
                    final pollutant = selections.pollutants[index];
                    final isSelected =
                        selections.selectedPollutant == pollutant;
                    final color = _getPollutantColor(pollutant);

                    return AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            HapticFeedback.selectionClick();
                            selections.updatePollutant(pollutant);
                          },
                          splashColor: color.withOpacity(0.3),
                          highlightColor: color.withOpacity(0.1),
                          child: Ink(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? color.withOpacity(0.2)
                                      : (isDarkMode
                                          ? Colors.white10
                                          : Colors.white),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? color : Colors.transparent,
                                width: 1.5,
                              ),
                              boxShadow:
                                  isSelected
                                      ? [
                                        BoxShadow(
                                          color: color.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: Offset(0, 1),
                                        ),
                                      ]
                                      : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected) ...[
                                  Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: color,
                                  ),
                                  SizedBox(width: 4),
                                ],
                                Text(
                                  pollutant,
                                  style: TextStyle(
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color:
                                        isSelected
                                            ? color
                                            : (isDarkMode
                                                ? Colors.white70
                                                : Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),

              // Better data view selector
              Text(
                'Data View:',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                height: 40, // Reduced from 50 to 40
                child: Row(
                  children: [
                    _buildViewSelector(
                      context,
                      isDarkMode,
                      selections,
                      'chart',
                      'Chart',
                      Icons.show_chart,
                    ),
                    SizedBox(width: 8),
                    _buildViewSelector(
                      context,
                      isDarkMode,
                      selections,
                      'historical',
                      'Historical',
                      Icons.history,
                    ),
                    SizedBox(width: 8),
                    _buildViewSelector(
                      context,
                      isDarkMode,
                      selections,
                      'forecast',
                      'Forecast',
                      Icons.calendar_today,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // New helper method for view selector
  Widget _buildViewSelector(
    BuildContext context,
    bool isDarkMode,
    AirQualitySelections selections,
    String viewType,
    String label,
    IconData icon,
  ) {
    final isActive = selections.activeView == viewType;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.selectionClick();
            selections.setActiveView(viewType);
          },
          splashColor: Colors.blue.withOpacity(0.2),
          highlightColor: Colors.blue.withOpacity(0.1),
          child: Ink(
            padding: EdgeInsets.all(8), // Reduced from 12 to 8
            decoration: BoxDecoration(
              color:
                  isActive
                      ? (isDarkMode
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.1))
                      : (isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? Colors.blue : Colors.transparent,
                width: 1,
              ),
              boxShadow:
                  isActive
                      ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            child: Row(
              // Changed from Column to Row to avoid vertical overflow
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color:
                      isActive
                          ? Colors.blue
                          : (isDarkMode ? Colors.white54 : Colors.black38),
                  size: 16, // Reduced from 18 to 16
                ),
                SizedBox(width: 4), // Added horizontal spacing
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10, // Reduced from 11 to 10
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color:
                        isActive
                            ? Colors.blue
                            : (isDarkMode ? Colors.white54 : Colors.black38),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForecastSection(bool isDarkMode) {
    // Filter forecast to show one entry per day (noon time)
    final dailyForecasts =
        _forecastAirQuality!.where((item) => item.dateTime.hour == 12).toList();
    if (dailyForecasts.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forecast',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dailyForecasts.length,
            itemBuilder: (context, index) {
              final forecast = dailyForecasts[index];
              return _buildForecastItem(forecast, isDarkMode);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForecastItem(AirQuality forecast, bool isDarkMode) {
    final color = forecast.getAqiColor();
    return Container(
      width: 100,
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('E, MMM d').format(forecast.dateTime),
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              forecast.aqi.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            forecast.getAqiDescription(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
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

  String _getKidFriendlyRecommendation(int aqi) {
    switch (aqi) {
      case 1:
        return 'The air is clean and healthy! Perfect for outdoor activities.';
      case 2:
        return 'The air is okay today. Most people can enjoy outdoor activities.';
      case 3:
        return 'The air is a bit dirty today. Take breaks if you play outside.';
      case 4:
        return 'The air is not good today. Try to stay indoors more.';
      case 5:
        return 'The air is very unhealthy. Stay inside with windows closed.';
      default:
        return 'We\'re not sure about the air quality right now.';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../services/weather_service.dart';
import 'package:intl/intl.dart';
import 'theme_provider.dart';

class WeatherForecastScreen extends StatefulWidget {
  const WeatherForecastScreen({super.key});

  @override
  State<WeatherForecastScreen> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherForecastScreen>
    with SingleTickerProviderStateMixin {
  // API service
  final _weatherService = WeatherService('4ff6eddbdab716e97b0ba1a6a87fd510');

  // Text controller for search
  final TextEditingController _locationController = TextEditingController();

  // Animation controllers
  late AnimationController _fadeController;

  // Weather data
  dynamic _currentLocationWeather;
  dynamic _searchedCityWeather;
  bool _isLoadingCurrent = false;
  bool _isLoadingSearch = false;
  String? _currentLocationError;
  String? _searchLocationError;

  // Debounce timer
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fetchCurrentLocationWeather();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _locationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // Fetch weather for current location
  Future<void> _fetchCurrentLocationWeather() async {
    setState(() {
      _isLoadingCurrent = true;
      _currentLocationError = null;
    });

    try {
      final cityname = await _weatherService.getCurrentCity();
      final weather = await _weatherService.getWeather(cityname);
      setState(() {
        _currentLocationWeather = weather;
        _isLoadingCurrent = false;
        _fadeController.forward(from: 0.0);
      });
    } catch (e) {
      setState(() {
        _currentLocationError = "Couldn't fetch weather for your location";
        _isLoadingCurrent = false;
      });
      print(e);
    }
  }

  // Search weather for a specific city
  Future<void> _searchCityWeather() async {
    final location = _locationController.text.trim();
    if (location.isEmpty) return;

    setState(() {
      _isLoadingSearch = true;
      _searchLocationError = null;
    });

    try {
      final weather = await _weatherService.getWeather(location);
      setState(() {
        _searchedCityWeather = weather;
        _isLoadingSearch = false;
        _fadeController.forward(from: 0.0);
      });
    } catch (e) {
      setState(() {
        _searchLocationError = "Couldn't find weather for '$location'";
        _isLoadingSearch = false;
      });
      print(e);
    }
  }

  // Weather animations
  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/clear_sky.json';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
        return 'assets/few_clouds.json';
      case 'mist':
        return 'assets/mist.json';
      case 'smoke':
        return 'assets/mist.json';
      case 'haze':
        return 'assets/mist.json';
      case 'dust':
        return 'assets/mist.json';
      case 'fog':
        return 'assets/Broken_clouds.json';
      case 'rain':
        return 'assets/rain.json';
      case 'drizzle':
        return 'assets/mis.json';
      case 'shower rain':
        return 'assets/clear_sky.json';
      case 'clear':
        return 'assets/clear_sky.json';
      default:
        return 'assets/clear_sky.json';
    }
  }

  // Enhanced background gradient based on both weather and temperature
  // Modified for more granular temperature ranges suitable for Indian climate
  List<Color> getWeatherGradient(
    String? condition,
    bool isDarkMode, [
    double? temperature,
  ]) {
    if (condition == null) {
      return isDarkMode
          ? [Color(0xFF1A1A2E), Color(0xFF16213E)]
          : [Color(0xFF87CEEB), Color(0xFF1E90FF)];
    }

    // More granular temperature based theme adjustments for Indian climate
    if (temperature != null) {
      // Very cold (below 5°C) - Northern mountainous regions
      if (temperature < 5) {
        return isDarkMode
            ? [Color(0xFF0D324D), Color(0xFF0F2027)]
            : [Color(0xFFB5D8F7), Color(0xFF7CB9E8)];
      }
      // Cold (5°C to 15°C) - North Indian winter
      else if (temperature < 15) {
        return isDarkMode
            ? [Color(0xFF2C3E50), Color(0xFF1E3B70)]
            : [Color(0xFF87CEEB), Color(0xFF6CA6CD)];
      }
      // Pleasant/Mild (15°C to 25°C) - Comfortable weather
      else if (temperature < 25) {
        return isDarkMode
            ? [Color(0xFF2E8B57), Color(0xFF3CB371)]
            : [Color(0xFF90EE90), Color(0xFF98FB98)];
      }
      // Warm (25°C to 30°C) - Common Indian temperatures
      else if (temperature < 30) {
        return isDarkMode
            ? [Color(0xFF614385), Color(0xFF516395)]
            : [Color(0xFF87CEFA), Color(0xFF00BFFF)];
      }
      // Hot (30°C to 35°C) - Summer in many Indian cities
      else if (temperature < 35) {
        return isDarkMode
            ? [Color(0xFFFF8C00), Color(0xFFFF4500)]
            : [Color(0xFFFFD700), Color(0xFFFFA500)];
      }
      // Very Hot (35°C to 40°C) - Peak summer
      else if (temperature < 40) {
        return isDarkMode
            ? [Color(0xFFB22222), Color(0xFF8B0000)]
            : [Color(0xFFFF8C00), Color(0xFFFF4500)];
      }
      // Extreme Heat (Above 40°C) - Common in parts of India during summer
      else {
        return isDarkMode
            ? [Color(0xFF8B0000), Color(0xFF800000)]
            : [Color(0xFFDC143C), Color(0xFF8B0000)];
      }
    }

    // Default weather-based gradients if temperature-based doesn't apply
    // or for temperatures between 10-20°C (moderate)
    switch (condition.toLowerCase()) {
      case 'clouds':
        return isDarkMode
            ? [Color(0xFF2C3E50), Color(0xFF34495E)]
            : [Color(0xFFA9A9A9), Color(0xFF778899)];
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return isDarkMode
            ? [Color(0xFF3E4551), Color(0xFF2C3E50)]
            : [Color(0xFFD3D3D3), Color(0xFF696969)];
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return isDarkMode
            ? [Color(0xFF1A237E), Color(0xFF0D47A1)]
            : [Color(0xFF4682B4), Color(0xFF000080)];
      case 'thunderstorm':
        return isDarkMode
            ? [Color(0xFF1A1A3A), Color(0xFF1C1C3A)]
            : [Color(0xFF4B0082), Color(0xFF483D8B)];
      case 'snow':
        return isDarkMode
            ? [Color(0xFF3E4551), Color(0xFF6A7178)]
            : [Color(0xFFE0FFFF), Color(0xFFAFEEEE)];
      case 'clear':
        return isDarkMode
            ? [Color(0xFF0D47A1), Color(0xFF1565C0)]
            : [Color(0xFF87CEEB), Color(0xFF1E90FF)];
      default:
        return isDarkMode
            ? [Color(0xFF1A1A2E), Color(0xFF16213E)]
            : [Color(0xFF87CEEB), Color(0xFF1E90FF)];
    }
  }

  // Get temperature color for text and accents
  // Modified for more granular temperature ranges suitable for Indian climate
  Color getTemperatureColor(double temperature, bool isDarkMode) {
    // Very cold (below 5°C)
    if (temperature < 5) {
      return isDarkMode ? Colors.lightBlue[100]! : Colors.blue[900]!;
    }
    // Cold (5°C to 15°C)
    else if (temperature < 15) {
      return isDarkMode ? Colors.lightBlue[300]! : Colors.blue[600]!;
    }
    // Pleasant/Mild (15°C to 20°C)
    else if (temperature < 20) {
      return isDarkMode ? Colors.green[200]! : Colors.green[700]!;
    }
    // Comfortable (20°C to 25°C)
    else if (temperature < 25) {
      return isDarkMode ? Colors.green[300]! : Colors.green[500]!;
    }
    // Warm (25°C to 30°C)
    else if (temperature < 30) {
      return isDarkMode ? Colors.amber[300]! : Colors.amber[600]!;
    }
    // Hot (30°C to 35°C)
    else if (temperature < 35) {
      return isDarkMode ? Colors.orange[300]! : Colors.orange[700]!;
    }
    // Very Hot (35°C to 40°C)
    else if (temperature < 40) {
      return isDarkMode ? Colors.deepOrange[300]! : Colors.deepOrange[700]!;
    }
    // Extreme Heat (above 40°C)
    else {
      return isDarkMode ? Colors.red[300]! : Colors.red[900]!;
    }
  }

  // Current date and time
  String getCurrentDateTime() {
    final now = DateTime.now();
    return DateFormat('EEEE, MMMM d • h:mm a').format(now);
  }

  // Current location weather display
  Widget _buildCurrentLocationWeather(bool isDarkMode) {
    if (_isLoadingCurrent) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/loading.json', height: 120, width: 120),
            const SizedBox(height: 16),
            Text(
              "Fetching your location's weather...",
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_currentLocationError != null) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 70,
              color: isDarkMode ? Colors.white70 : Colors.white70,
            ),
            const SizedBox(height: 16),
            Text(
              _currentLocationError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchCurrentLocationWeather,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.white10 : Colors.white24,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_currentLocationWeather == null) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: Text(
          "No weather data available",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.white,
            fontSize: 18,
          ),
        ),
      );
    }

    final weather = _currentLocationWeather;
    final tempColor = getTemperatureColor(weather.temperature, isDarkMode);

    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: getWeatherGradient(
              weather.mainCondition,
              isDarkMode,
              weather.temperature,
            ),
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          weather.cityname,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      getCurrentDateTime(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.white),
                  onPressed: _fetchCurrentLocationWeather,
                ),
              ],
            ),

            // Weather animation and temperature
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${weather.temperature.round()}°',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: tempColor.withOpacity(0.6),
                                  blurRadius: 15,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 12),
                            child: Text(
                              'C',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 26,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: tempColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: tempColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          weather.mainCondition,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          _buildWeatherDetail(
                            Icons.water_drop_outlined,
                            '${weather.humidity}%',
                            'Humidity',
                            Colors.white,
                          ),
                          SizedBox(width: 16),
                          _buildWeatherDetail(
                            Icons.air,
                            '${weather.windSpeed} m/s',
                            'Wind',
                            Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Hero(
                    tag: 'current_weather_animation',
                    child: Lottie.asset(
                      getWeatherAnimation(weather.mainCondition),
                      height: 150,
                      repeat: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color.withOpacity(0.7), size: 14),
            SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(color: color.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  // Searched city weather display
  Widget _buildSearchedCityWeather() {
    if (!_isLoadingSearch &&
        _searchedCityWeather == null &&
        _searchLocationError == null) {
      return const SizedBox.shrink(); // Show nothing initially
    }

    if (_isLoadingSearch) {
      return Container(
        height: 250,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Colors.blueAccent),
      );
    }

    if (_searchLocationError != null) {
      return Container(
        height: 250,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              _searchLocationError!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.redAccent),
            ),
          ],
        ),
      );
    }

    final weather = _searchedCityWeather;
    final tempColor = getTemperatureColor(weather.temperature, false);

    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: getWeatherGradient(
              weather.mainCondition,
              false,
              weather.temperature,
            ),
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // City name
            Text(
              weather.cityname,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Weather animation and temperature
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Lottie.asset(
                  getWeatherAnimation(weather.mainCondition),
                  height: 120,
                ),
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${weather.temperature.round()}°',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: tempColor.withOpacity(0.6),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'C',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: tempColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: tempColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        weather.mainCondition,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildWeatherDetail(
                  Icons.water_drop_outlined,
                  '${weather.humidity}%',
                  'Humidity',
                  Colors.white,
                ),
                _buildWeatherDetail(
                  Icons.air,
                  '${weather.windSpeed} m/s',
                  'Wind',
                  Colors.white,
                ),
                _buildWeatherDetail(
                  Icons.thermostat_outlined,
                  '${weather.feelsLike.round()}°C',
                  'Feels Like',
                  Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    // Get the main background gradient based on current weather and temperature
    List<Color> backgroundGradient =
        _currentLocationWeather != null
            ? getWeatherGradient(
              _currentLocationWeather.mainCondition,
              isDarkMode,
              _currentLocationWeather.temperature,
            )
            : [Color(0xFF87CEEB), Color(0xFF1E90FF)];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with app title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wb_sunny_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'WeatherX',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Current Location Weather Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildCurrentLocationWeather(isDarkMode),
                ),
                const SizedBox(height: 30),

                // Search Section with Glass Effect
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Search Weather for City',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Search input with autocomplete
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Autocomplete<String>(
                              optionsBuilder: (
                                TextEditingValue textEditingValue,
                              ) async {
                                if (textEditingValue.text.length < 3) {
                                  return const Iterable<String>.empty();
                                }
                                final suggestions = await _weatherService
                                    .getCitySuggestions(textEditingValue.text);
                                return suggestions;
                              },
                              onSelected: (String selection) {
                                _locationController.text =
                                    selection.split(',')[0];
                                _searchCityWeather();
                              },
                              fieldViewBuilder: (
                                context,
                                controller,
                                focusNode,
                                onFieldSubmitted,
                              ) {
                                return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    hintText: 'Enter city name',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.blueAccent,
                                    ),
                                    suffixIcon:
                                        controller.text.isNotEmpty
                                            ? IconButton(
                                              icon: Icon(Icons.clear),
                                              onPressed:
                                                  () => controller.clear(),
                                            )
                                            : null,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  onSubmitted: (_) {
                                    _locationController.text = controller.text;
                                    _searchCityWeather();
                                  },
                                );
                              },
                              optionsViewBuilder: (
                                context,
                                onSelected,
                                options,
                              ) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    elevation: 4.0,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width -
                                          80,
                                      constraints: BoxConstraints(
                                        maxHeight: 200,
                                      ),
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        itemCount: options.length,
                                        itemBuilder: (
                                          BuildContext context,
                                          int index,
                                        ) {
                                          final String option = options
                                              .elementAt(index);
                                          return ListTile(
                                            leading: Icon(
                                              Icons.location_on,
                                              color: Colors.blueAccent,
                                            ),
                                            title: Text(option),
                                            onTap: () {
                                              onSelected(option);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Search button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _searchCityWeather,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                              ),
                              child: Text(
                                'Search Weather',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Searched city weather result
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSearchedCityWeather(),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

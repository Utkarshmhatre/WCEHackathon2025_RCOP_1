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

  // Background gradient based on weather and theme
  List<Color> getWeatherGradient(String? condition, bool isDarkMode) {
    if (condition == null) {
      return isDarkMode
          ? [Color(0xFF1A1A2E), Color(0xFF16213E)]
          : [Color(0xFF87CEEB), Color(0xFF1E90FF)];
    }

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

    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: getWeatherGradient(weather.mainCondition, isDarkMode),
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
                      Text(
                        '${weather.temperature.round()}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          weather.mainCondition,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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

    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        margin: const EdgeInsets.only(top: 20),
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
          children: [
            // City name
            Text(
              weather.cityname,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
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
                    Text(
                      '${weather.temperature.round()}°C',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        weather.mainCondition,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
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

    // Get the main background gradient based on current weather
    List<Color> backgroundGradient =
        _currentLocationWeather != null
            ? getWeatherGradient(
              _currentLocationWeather.mainCondition,
              isDarkMode,
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

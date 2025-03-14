import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import '../services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // api key
  final _weatherService = WeatherService('4ff6eddbdab716e97b0ba1a6a87fd510');

  // text controller for search
  final TextEditingController _locationController = TextEditingController();

  // weather
  dynamic _weather;
  bool _isLoading = false;
  String? _errorMessage;

  // debounce timer
  Timer? _debounce;

  // fetch weather for current location
  _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String cityname = await _weatherService.getCurrentCity();
    try {
      final weather = await _weatherService.getWeather(cityname);
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Couldn't fetch weather for current location";
        _isLoading = false;
      });
      print(e);
    }
  }

  // fetch weather for specified location
  _searchWeather() async {
    final location = _locationController.text.trim();
    if (location.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = await _weatherService.getWeather(location);
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Couldn't find weather for '$location'";
        _isLoading = false;
      });
      print(e);
    }
  }

  // weather animations
  String getWeatherAminations(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';

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

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Modern gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFAFAFA), Color(0xFFE0F7FA)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'WeatherX',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 24),

                // Search bar with autocomplete
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
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
                        _locationController.text = selection.split(',')[0];
                        _searchWeather();
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
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onSubmitted: (_) => _searchWeather(),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 48,
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final String option = options.elementAt(
                                    index,
                                  );
                                  return ListTile(
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
                ),
                const SizedBox(height: 16),

                // Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _searchWeather,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.search),
                        label: const Text('Search'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _fetchWeather,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.my_location),
                        label: const Text('My Location'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                // Weather results (refined without an extra white container)
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _weather == null
                    ? const Center(child: Text("No weather data available"))
                    : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Temperature and main condition section
                        Text(
                          '${_weather.temperature.round()}°C',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),

                        // Main condition
                        Text(
                          _weather.mainCondition,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),

                        // City name (updated to use headlineMedium)
                        Text(
                          _weather.cityname,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Weather Animation
                        Lottie.asset(
                          getWeatherAminations(_weather.mainCondition),
                          height: 150,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

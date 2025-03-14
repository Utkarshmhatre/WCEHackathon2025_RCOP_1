import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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

  //weather animations
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
        return 'assets/sunny.json';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'Enter city name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _searchWeather(),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _searchWeather,
                    child: Text('Search'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),

              // My location button
              TextButton.icon(
                onPressed: _fetchWeather,
                icon: Icon(Icons.my_location),
                label: Text('Use My Location'),
              ),

              // Error message if any
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),

              // Loading indicator or weather data
              Expanded(
                child:
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Center(
                          child:
                              _weather == null
                                  ? Text("No weather data available")
                                  : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // city name
                                      Text(
                                        _weather.cityname,
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 20),

                                      // animation
                                      Lottie.asset(
                                        getWeatherAminations(
                                          _weather.mainCondition,
                                        ),
                                        height: 200,
                                      ),
                                      SizedBox(height: 20),

                                      // temperature
                                      Text(
                                        '${_weather.temperature.round()}°C',
                                        style: TextStyle(fontSize: 32),
                                      ),
                                      SizedBox(height: 10),

                                      // weather condition
                                      Text(
                                        _weather.mainCondition,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

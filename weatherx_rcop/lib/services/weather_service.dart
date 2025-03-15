import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/weather_model.dart';
import '../models/air_quality_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const BASE_url = "https://api.openweathermap.org/data/2.5/weather";
  static const AIR_POLLUTION_URL =
      "https://api.openweathermap.org/data/2.5/air_pollution";
  final String apikey;

  WeatherService(this.apikey);

  Future<Weather> getWeather(String cityname) async {
    final response = await http.get(
      Uri.parse('$BASE_url?q=$cityname&appid=$apikey&units=metric'),
    );
    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error fetching weather');
    }
  }

  Future<String> getCurrentCity() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    String city = placemarks[0].locality ?? "";
    return city;
  }

  Future<Position> getCurrentPosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<List<String>> getCitySuggestions(String query) async {
    if (query.length < 2) return [];

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apikey',
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        // Create more descriptive location strings with state and country
        return data.map<String>((city) {
          String name = city['name'] ?? '';
          String state = city['state'] ?? '';
          String country = city['country'] ?? '';

          if (state.isNotEmpty) {
            return "$name, $state, $country";
          } else {
            return "$name, $country";
          }
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error getting suggestions: $e');
      return [];
    }
  }

  // Fixed method to get current air quality data
  Future<AirQuality> getCurrentAirQuality(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('$AIR_POLLUTION_URL?lat=$lat&lon=$lon&appid=$apikey'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Handle coord as either a map or list
      List<double> coordList;
      if (data['coord'] is List) {
        // If coord is a list, use it directly
        final List coordData = data['coord'];
        coordList = [coordData[0].toDouble(), coordData[1].toDouble()];
      } else {
        // If coord is a map or any other type, use the passed lat and lon
        coordList = [lat, lon];
      }

      return AirQuality.fromJson(data['list'][0], coordList);
    } else {
      throw Exception(
        'Error fetching air quality data: ${response.statusCode}',
      );
    }
  }

  // Fixed method to get forecast air quality data
  Future<List<AirQuality>> getForecastAirQuality(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('$AIR_POLLUTION_URL/forecast?lat=$lat&lon=$lon&appid=$apikey'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> list = data['list'];

      // Handle coord as either a map or list
      List<double> coordList;
      if (data['coord'] is List) {
        // If coord is a list, use it directly
        final List coordData = data['coord'];
        coordList = [coordData[0].toDouble(), coordData[1].toDouble()];
      } else {
        // If coord is a map or any other type, use the passed lat and lon
        coordList = [lat, lon];
      }

      return list
          .map<AirQuality>((item) => AirQuality.fromJson(item, coordList))
          .toList();
    } else {
      throw Exception(
        'Error fetching air quality forecast data: ${response.statusCode}',
      );
    }
  }

  // Fixed method to get historical air quality data
  Future<List<AirQuality>> getHistoricalAirQuality(
    double lat,
    double lon,
    int startTime,
    int endTime,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$AIR_POLLUTION_URL/history?lat=$lat&lon=$lon&start=$startTime&end=$endTime&appid=$apikey',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> list = data['list'];

      // Handle coord as either a map or list
      List<double> coordList;
      if (data['coord'] is List) {
        // If coord is a list, use it directly
        final List coordData = data['coord'];
        coordList = [coordData[0].toDouble(), coordData[1].toDouble()];
      } else {
        // If coord is a map or any other type, use the passed lat and lon
        coordList = [lat, lon];
      }

      return list
          .map<AirQuality>((item) => AirQuality.fromJson(item, coordList))
          .toList();
    } else {
      throw Exception(
        'Error fetching historical air quality data: ${response.statusCode}',
      );
    }
  }
}

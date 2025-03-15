class Weather {
  final String cityname;
  final double temperature;
  final String mainCondition;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int pressure;

  Weather({
    required this.cityname,
    required this.temperature,
    required this.mainCondition,
    this.feelsLike = 0,
    this.humidity = 0,
    this.windSpeed = 0,
    this.pressure = 0,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityname: json['name'],
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
      feelsLike: json['main']['feels_like']?.toDouble() ?? 0,
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: json['wind']['speed']?.toDouble() ?? 0,
      pressure: json['main']['pressure'] ?? 0,
    );
  }
}

class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final double maxTemp;
  final double minTemp;
  final double windSpeed;
  final String sunrise;
  final String sunset;
  final int humidity;
  final double feelsLike;
  final String icon;
  final int visibility;
  final int pressure;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.maxTemp,
    required this.minTemp,
    required this.windSpeed,
    required this.sunrise,
    required this.sunset,
    required this.humidity,
    required this.feelsLike,
    required this.icon,
    required this.visibility,
    required this.pressure,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      maxTemp: (json['main']['temp_max'] as num).toDouble(),
      minTemp: (json['main']['temp_min'] as num).toDouble(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      sunrise:
          DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000)
              .toString()
              .substring(11, 16),
      sunset: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000)
          .toString()
          .substring(11, 16),
      humidity: json['main']['humidity'] as int? ?? 0,
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      icon: json['weather'][0]['icon'] ?? '',
      visibility: (json['visibility'] as int?) ?? 0,
      pressure: json['main']['pressure'] as int? ?? 0,
    );
  }
}

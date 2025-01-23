class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String icon;
  final String description;
  final double rain;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.icon,
    required this.description,
    required this.rain,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      maxTemp: (json['main']['temp_max'] as num).toDouble(),
      minTemp: (json['main']['temp_min'] as num).toDouble(),
      icon: json['weather'][0]['icon'] as String,
      description: json['weather'][0]['description'] as String,
      rain: (json['rain']?['3h'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'maxTemp': maxTemp,
      'minTemp': minTemp,
      'icon': icon,
      'description': description,
      'rain': rain,
    };
  }
}

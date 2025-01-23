class HourlyForecast {
  final String hour;
  final double temperature;
  final String description;
  final String icon;
  final DateTime time;
  final double rain;

  HourlyForecast({
    required this.hour,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.time,
    required this.rain,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    final time = DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000);
    return HourlyForecast(
      hour: '${time.hour.toString().padLeft(2, '0')}:00',
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] as String,
      icon: json['weather'][0]['icon'] as String,
      time: time,
      rain: (json['rain']?['3h'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'temperature': temperature,
      'description': description,
      'icon': icon,
      'time': time.toIso8601String(),
      'rain': rain,
    };
  }
}

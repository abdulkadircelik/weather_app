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
    final dt = DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000);
    return HourlyForecast(
      hour: '${dt.hour.toString().padLeft(2, '0')}:00',
      temperature: (json['temp'] as num).toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      time: dt,
      rain: (json['rain']?['1h'] ?? 0.0).toDouble(),
    );
  }
}

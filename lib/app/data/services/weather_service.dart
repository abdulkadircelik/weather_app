import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_model.dart';
import '../models/hourly_forecast.dart';
import '../models/daily_forecast.dart';
import '../../core/constants/api_constants.dart';

class WeatherService {
  final String apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  Future<String> getWeatherBackgroundImage(
      String condition, bool isNight) async {
    try {
      return _getWeatherBackgroundUrl(condition, isNight);
    } catch (e) {
      return ApiConstants.defaultBackgroundUrl;
    }
  }

  String _getWeatherBackgroundUrl(String condition, bool isNight) {
    String iconCode = condition.toLowerCase();

    if (!isNight) {
      // Gündüz durumları
      if (ApiConstants.dayWeatherImages.containsKey(iconCode)) {
        return ApiConstants.dayWeatherImages[iconCode]!;
      }

      // Açıklama bazlı arama
      for (var entry in ApiConstants.weatherDescriptionImages.entries) {
        if (condition.contains(entry.key)) {
          return entry.value;
        }
      }
    } else {
      // Gece durumları
      if (ApiConstants.nightWeatherImages.containsKey(iconCode)) {
        return ApiConstants.nightWeatherImages[iconCode]!;
      }

      // Açıklama bazlı arama
      for (var entry in ApiConstants.weatherDescriptionImages.entries) {
        if (condition.contains(entry.key)) {
          return entry.value;
        }
      }
    }

    return ApiConstants.defaultBackgroundUrl;
  }

  Future<WeatherModel> getCurrentWeather(String city) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/weather?q=$city&appid=$apiKey&units=metric&lang=tr'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel(
          cityName: data['name'],
          temperature: data['main']['temp'].toDouble(),
          description: data['weather'][0]['description'],
          maxTemp: data['main']['temp_max'].toDouble(),
          minTemp: data['main']['temp_min'].toDouble(),
          windSpeed: data['wind']['speed'].toDouble(),
          sunrise:
              DateTime.fromMillisecondsSinceEpoch(data['sys']['sunrise'] * 1000)
                  .toString()
                  .substring(11, 16),
          sunset:
              DateTime.fromMillisecondsSinceEpoch(data['sys']['sunset'] * 1000)
                  .toString()
                  .substring(11, 16),
          humidity: data['main']['humidity'],
          feelsLike: data['main']['feels_like'].toDouble(),
          icon: data['weather'][0]['icon'],
          visibility: (data['visibility'] ?? 0) as int,
          pressure: (data['main']['pressure'] ?? 0) as int,
        );
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<HourlyForecast>> getHourlyForecast(String city) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/forecast?q=$city&appid=$apiKey&units=metric&lang=tr'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['list'];
        return list
            .take(8)
            .map((item) => HourlyForecast(
                  hour:
                      '${DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000).hour.toString().padLeft(2, '0')}:00',
                  temperature: item['main']['temp'].toDouble(),
                  description: item['weather'][0]['description'],
                  icon: item['weather'][0]['icon'],
                  time: DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000),
                  rain: item['rain']?['3h']?.toDouble() ?? 0.0,
                ))
            .toList();
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DailyForecast>> getDailyForecast(String city) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/forecast?q=$city&appid=$apiKey&units=metric&lang=tr'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['list'];
        final Map<String, List<dynamic>> dailyData = {};

        for (var item in list) {
          final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          final dateKey = '${date.year}-${date.month}-${date.day}';

          if (!dailyData.containsKey(dateKey)) {
            dailyData[dateKey] = [];
          }
          dailyData[dateKey]!.add(item);
        }

        final List<DailyForecast> dailyForecasts =
            dailyData.entries.map((entry) {
          final samples = entry.value;
          double maxTemp = double.negativeInfinity;
          double minTemp = double.infinity;

          for (var sample in samples) {
            final temp = sample['main'];
            if (temp['temp_max'] > maxTemp) {
              maxTemp = temp['temp_max'].toDouble();
            }
            if (temp['temp_min'] < minTemp) {
              minTemp = temp['temp_min'].toDouble();
            }
          }

          final middayData = samples.firstWhere(
            (item) {
              final hour =
                  DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000).hour;
              return hour >= 12 && hour <= 15;
            },
            orElse: () => samples.first,
          );

          return DailyForecast(
            date: DateTime.fromMillisecondsSinceEpoch(middayData['dt'] * 1000),
            maxTemp: maxTemp,
            minTemp: minTemp,
            icon: middayData['weather'][0]['icon'],
            description: middayData['weather'][0]['description'],
            rain: middayData['rain']?['3h']?.toDouble() ?? 0.0,
          );
        }).toList();

        dailyForecasts.sort((a, b) => a.date.compareTo(b.date));
        return dailyForecasts.take(5).toList();
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<WeatherModel> getCurrentWeatherByCoordinates(
      double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric&lang=tr'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel(
          cityName: data['name'],
          temperature: data['main']['temp'].toDouble(),
          description: data['weather'][0]['description'],
          maxTemp: data['main']['temp_max'].toDouble(),
          minTemp: data['main']['temp_min'].toDouble(),
          windSpeed: data['wind']['speed'].toDouble(),
          sunrise:
              DateTime.fromMillisecondsSinceEpoch(data['sys']['sunrise'] * 1000)
                  .toString()
                  .substring(11, 16),
          sunset:
              DateTime.fromMillisecondsSinceEpoch(data['sys']['sunset'] * 1000)
                  .toString()
                  .substring(11, 16),
          humidity: data['main']['humidity'],
          feelsLike: data['main']['feels_like'].toDouble(),
          icon: data['weather'][0]['icon'],
          visibility: (data['visibility'] ?? 0) as int,
          pressure: (data['main']['pressure'] ?? 0) as int,
        );
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }
}

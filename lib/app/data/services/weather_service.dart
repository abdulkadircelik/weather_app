import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_model.dart';

class WeatherService {
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';
  final String apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  Future<WeatherModel> getCurrentWeather(String city) async {
    try {
      final url = '$baseUrl/weather?q=$city&appid=$apiKey&units=metric&lang=tr';
      print('API çağrısı yapılıyor: $url');

      final response = await http.get(Uri.parse(url));
      print('API yanıt kodu: ${response.statusCode}');
      print('API yanıtı: ${response.body}');

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception('Hava durumu verileri alınamadı: ${error['message']}');
      }
    } catch (e) {
      print('Hata oluştu: $e');
      rethrow;
    }
  }

  Future<List<HourlyForecast>> getHourlyForecast(String city) async {
    try {
      final url =
          '$baseUrl/forecast?q=$city&appid=$apiKey&units=metric&lang=tr';
      print('Saatlik tahmin API çağrısı yapılıyor: $url');

      final response = await http.get(Uri.parse(url));
      print('Saatlik tahmin API yanıt kodu: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['list'] as List)
            .take(24)
            .map((item) => HourlyForecast.fromJson(item))
            .toList();
      } else {
        final error = json.decode(response.body);
        throw Exception(
            'Saatlik tahmin verileri alınamadı: ${error['message']}');
      }
    } catch (e) {
      print('Saatlik tahmin hatası: $e');
      rethrow;
    }
  }

  Future<List<DailyForecast>> getDailyForecast(String city) async {
    try {
      final url =
          '$baseUrl/forecast?q=$city&appid=$apiKey&units=metric&lang=tr&cnt=40';
      print('Günlük tahmin API çağrısı yapılıyor: $url');

      final response = await http.get(Uri.parse(url));
      print('Günlük tahmin API yanıt kodu: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<DailyForecast> dailyForecasts = [];
        final List<dynamic> list = data['list'];

        for (int i = 0; i < list.length; i += 8) {
          if (dailyForecasts.length >= 5) break;

          final item = list[i];
          double maxTemp = (item['main']['temp_max'] as num).toDouble();
          double minTemp = (item['main']['temp_min'] as num).toDouble();

          dailyForecasts.add(DailyForecast(
            date: DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000),
            maxTemp: maxTemp,
            minTemp: minTemp,
            icon: item['weather'][0]['icon'],
          ));
        }

        return dailyForecasts;
      } else {
        final error = json.decode(response.body);
        throw Exception(
            'Günlük tahmin verileri alınamadı: ${error['message']}');
      }
    } catch (e) {
      print('Günlük tahmin hatası: $e');
      rethrow;
    }
  }
}

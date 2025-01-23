import 'package:get/get.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../models/hourly_forecast.dart';
import '../models/daily_forecast.dart';
import 'weather_repository_interface.dart';

class WeatherRepository implements IWeatherRepository {
  final WeatherService _weatherService = Get.find<WeatherService>();

  @override
  Future<WeatherModel> getCurrentWeather(String city) async {
    try {
      return await _weatherService.getCurrentWeather(city);
    } catch (e) {
      throw Exception('Hava durumu bilgisi alınamadı: $e');
    }
  }

  @override
  Future<WeatherModel> getCurrentWeatherByCoordinates(
      double latitude, double longitude) async {
    try {
      return await _weatherService.getCurrentWeatherByCoordinates(
          latitude, longitude);
    } catch (e) {
      throw Exception('Konum bazlı hava durumu bilgisi alınamadı: $e');
    }
  }

  @override
  Future<List<HourlyForecast>> getHourlyForecast(String city) async {
    try {
      return await _weatherService.getHourlyForecast(city);
    } catch (e) {
      throw Exception('Saatlik tahmin bilgisi alınamadı: $e');
    }
  }

  @override
  Future<List<DailyForecast>> getDailyForecast(String city) async {
    try {
      return await _weatherService.getDailyForecast(city);
    } catch (e) {
      throw Exception('Günlük tahmin bilgisi alınamadı: $e');
    }
  }

  @override
  Future<String> getWeatherBackgroundImage(
      String condition, bool isNight) async {
    try {
      return await _weatherService.getWeatherBackgroundImage(
          condition, isNight);
    } catch (e) {
      throw Exception('Arka plan resmi alınamadı: $e');
    }
  }
}

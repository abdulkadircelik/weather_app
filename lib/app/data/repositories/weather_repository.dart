import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../models/hourly_forecast.dart';
import '../models/daily_forecast.dart';
import 'weather_repository_interface.dart';

class WeatherRepository implements IWeatherRepository {
  final IWeatherService _weatherService;

  WeatherRepository({
    required IWeatherService weatherService,
  }) : _weatherService = weatherService;

  @override
  Future<WeatherModel> getCurrentWeather(String city) async {
    return await _weatherService.getCurrentWeather(city);
  }

  @override
  Future<WeatherModel> getCurrentWeatherByCoordinates(
      double latitude, double longitude) async {
    return await _weatherService.getCurrentWeatherByCoordinates(
        latitude, longitude);
  }

  @override
  Future<List<HourlyForecast>> getHourlyForecast(String city) async {
    return await _weatherService.getHourlyForecast(city);
  }

  @override
  Future<List<DailyForecast>> getDailyForecast(String city) async {
    return await _weatherService.getDailyForecast(city);
  }

  @override
  Future<String> getWeatherBackgroundImage(
      String condition, bool isNight) async {
    return await _weatherService.getWeatherBackgroundImage(condition, isNight);
  }
}

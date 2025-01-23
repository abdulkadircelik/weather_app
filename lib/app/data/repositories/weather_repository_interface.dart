import '../models/weather_model.dart';
import '../models/hourly_forecast.dart';
import '../models/daily_forecast.dart';

abstract class IWeatherRepository {
  Future<WeatherModel> getCurrentWeather(String city);
  Future<WeatherModel> getCurrentWeatherByCoordinates(
      double latitude, double longitude);
  Future<List<HourlyForecast>> getHourlyForecast(String city);
  Future<List<DailyForecast>> getDailyForecast(String city);
  Future<String> getWeatherBackgroundImage(String condition, bool isNight);
}

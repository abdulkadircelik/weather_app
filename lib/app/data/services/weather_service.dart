import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_model.dart';
import '../models/hourly_forecast.dart';
import '../models/daily_forecast.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_constants.dart';
import 'http_service.dart';

abstract class IWeatherService {
  Future<WeatherModel> getCurrentWeather(String city);
  Future<WeatherModel> getCurrentWeatherByCoordinates(
      double latitude, double longitude);
  Future<List<HourlyForecast>> getHourlyForecast(String city);
  Future<List<DailyForecast>> getDailyForecast(String city);
  Future<String> getWeatherBackgroundImage(String condition, bool isNight);
}

class WeatherService implements IWeatherService {
  final IHttpService _httpService;
  final String _apiKey;

  WeatherService({
    required IHttpService httpService,
  })  : _httpService = httpService,
        _apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  @override
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

  @override
  Future<WeatherModel> getCurrentWeather(String city) async {
    try {
      final url = _buildCurrentWeatherUrl(city: city);
      final data = await _httpService.get(url);
      return WeatherModel.fromJson(data);
    } catch (e) {
      throw Exception('${AppConstants.weatherDataError}: $e');
    }
  }

  @override
  Future<List<HourlyForecast>> getHourlyForecast(String city) async {
    try {
      final url = _buildForecastUrl(city: city);
      final data = await _httpService.get(url);

      final List<dynamic> list = data['list'];
      return list
          .take(AppConstants.hourlyForecastLimit)
          .map((item) => HourlyForecast.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('${AppConstants.hourlyForecastError}: $e');
    }
  }

  @override
  Future<List<DailyForecast>> getDailyForecast(String city) async {
    try {
      final url = _buildForecastUrl(city: city);
      final data = await _httpService.get(url);

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

      final List<DailyForecast> dailyForecasts = dailyData.entries.map((entry) {
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
      return dailyForecasts.take(AppConstants.dailyForecastLimit).toList();
    } catch (e) {
      throw Exception('${AppConstants.dailyForecastError}: $e');
    }
  }

  @override
  Future<WeatherModel> getCurrentWeatherByCoordinates(
      double latitude, double longitude) async {
    try {
      final url =
          _buildCurrentWeatherUrl(latitude: latitude, longitude: longitude);
      final data = await _httpService.get(url);
      return WeatherModel.fromJson(data);
    } catch (e) {
      throw Exception('${AppConstants.locationBasedWeatherError}: $e');
    }
  }

  String _buildCurrentWeatherUrl(
      {String? city, double? latitude, double? longitude}) {
    final baseUrl =
        '${ApiEndpoints.openWeatherBaseUrl}${ApiEndpoints.currentWeather}';
    final queryParams = <String, String>{
      ApiEndpoints.apiKeyParam: _apiKey,
      ApiEndpoints.unitsParam: ApiEndpoints.defaultUnits,
      ApiEndpoints.langParam: ApiEndpoints.defaultLang,
    };

    if (city != null) {
      queryParams[ApiEndpoints.cityParam] = city;
    } else if (latitude != null && longitude != null) {
      queryParams[ApiEndpoints.latParam] = latitude.toString();
      queryParams[ApiEndpoints.lonParam] = longitude.toString();
    }

    return Uri.parse(baseUrl).replace(queryParameters: queryParams).toString();
  }

  String _buildForecastUrl(
      {String? city, double? latitude, double? longitude}) {
    final baseUrl =
        '${ApiEndpoints.openWeatherBaseUrl}${ApiEndpoints.forecast}';
    final queryParams = <String, String>{
      ApiEndpoints.apiKeyParam: _apiKey,
      ApiEndpoints.unitsParam: ApiEndpoints.defaultUnits,
      ApiEndpoints.langParam: ApiEndpoints.defaultLang,
    };

    if (city != null) {
      queryParams[ApiEndpoints.cityParam] = city;
    } else if (latitude != null && longitude != null) {
      queryParams[ApiEndpoints.latParam] = latitude.toString();
      queryParams[ApiEndpoints.lonParam] = longitude.toString();
    }

    return Uri.parse(baseUrl).replace(queryParameters: queryParams).toString();
  }
}

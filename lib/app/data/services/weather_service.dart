import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_model.dart';
import '../models/hourly_forecast.dart';
import '../models/daily_forecast.dart';

class WeatherService {
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';
  final String imageBaseUrl = 'https://api.unsplash.com';
  final String unsplashApiKey = dotenv.env['UNSPLASH_API_KEY'] ?? '';
  final String apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  Future<String> getWeatherBackgroundImage(
      String condition, bool isNight) async {
    try {
      String query = _getImageSearchQuery(condition, isNight);
      final response = await http.get(
        Uri.parse(
          '$imageBaseUrl/photos/random?query=$query&orientation=portrait&client_id=$unsplashApiKey&collections=weather,nature,landscape',
        ),
      );

      print('Arka plan resmi sorgusu: $query');
      print('Arka plan resmi yanıt durumu: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['urls']['regular'];
      } else {
        print('Arka plan resmi alınamadı: ${response.statusCode}');
        return _getDefaultBackgroundUrl(condition, isNight);
      }
    } catch (e) {
      print('Arka plan resmi alınırken hata: $e');
      return _getDefaultBackgroundUrl(condition, isNight);
    }
  }

  String _getImageSearchQuery(String condition, bool isNight) {
    String weatherType = '';
    String timePrefix = isNight ? 'night' : 'day';

    if (condition.contains('açık')) {
      weatherType = isNight ? 'starry night sky' : 'sunny clear sky';
    } else if (condition.contains('parçalı bulut')) {
      weatherType = 'scattered clouds sky';
    } else if (condition.contains('bulut')) {
      weatherType = 'overcast cloudy sky';
    } else if (condition.contains('hafif yağmur')) {
      weatherType = 'light rain drops';
    } else if (condition.contains('yağmur')) {
      weatherType = 'heavy rain storm';
    } else if (condition.contains('kar')) {
      weatherType = 'snowy winter';
    } else if (condition.contains('sis')) {
      weatherType = 'foggy misty';
    } else if (condition.contains('gök gürültü')) {
      weatherType = 'thunderstorm lightning';
    } else if (condition.contains('rüzgar')) {
      weatherType = 'windy trees';
    } else if (condition.contains('kapalı')) {
      weatherType = 'overcast grey sky';
    } else if (condition.contains('güneş')) {
      weatherType = 'bright sunny day';
    } else {
      weatherType = condition;
    }

    return '$weatherType $timePrefix weather nature';
  }

  String _getDefaultBackgroundUrl(String condition, bool isNight) {
    if (condition.contains('yağmur')) {
      return 'https://images.unsplash.com/photo-1519692933481-e162a57d6721';
    } else if (condition.contains('kar')) {
      return 'https://images.unsplash.com/photo-1478265409131-1f65c88f965c';
    } else if (condition.contains('bulut')) {
      return 'https://images.unsplash.com/photo-1534088568595-a066f410bcda';
    } else if (condition.contains('gök gürültü')) {
      return 'https://images.unsplash.com/photo-1605727216801-e27ce1d0cc28';
    } else if (condition.contains('sis')) {
      return 'https://images.unsplash.com/photo-1485236715568-ddc5ee6ca227';
    } else if (isNight) {
      return 'https://images.unsplash.com/photo-1532978379173-523e16f371f9';
    } else {
      return 'https://images.unsplash.com/photo-1601297183305-6df142704ea2';
    }
  }

  Future<WeatherModel> getCurrentWeather(String city) async {
    try {
      print('Fetching current weather for $city');
      final response = await http.get(
        Uri.parse(
            '$baseUrl/weather?q=$city&appid=$apiKey&units=metric&lang=tr'),
      );

      print('Current weather response status: ${response.statusCode}');
      print('Current weather response body: ${response.body}');

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
          visibility: data['visibility'],
          pressure: data['main']['pressure'],
        );
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error getting weather: $e');
      rethrow;
    }
  }

  Future<List<HourlyForecast>> getHourlyForecast(String city) async {
    try {
      print('Fetching hourly forecast for $city');
      final response = await http.get(
        Uri.parse(
            '$baseUrl/forecast?q=$city&appid=$apiKey&units=metric&lang=tr'),
      );

      print('Hourly forecast response status: ${response.statusCode}');
      print('Hourly forecast response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['list'];
        return list
            .take(8)
            .map((item) => HourlyForecast(
                  hour: DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000)
                          .hour
                          .toString()
                          .padLeft(2, '0') +
                      ':00',
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
      print('Error getting hourly forecast: $e');
      rethrow;
    }
  }

  Future<List<DailyForecast>> getDailyForecast(String city) async {
    try {
      print('Fetching daily forecast for $city');
      final response = await http.get(
        Uri.parse(
            '$baseUrl/forecast?q=$city&appid=$apiKey&units=metric&lang=tr'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['list'];
        final Map<String, List<dynamic>> dailyData = {};

        // Verileri günlere göre grupla
        for (var item in list) {
          final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          final dateKey = '${date.year}-${date.month}-${date.day}';

          if (!dailyData.containsKey(dateKey)) {
            dailyData[dateKey] = [];
          }
          dailyData[dateKey]!.add(item);
        }

        // Her gün için min/max sıcaklıkları hesapla
        final List<DailyForecast> dailyForecasts =
            dailyData.entries.map((entry) {
          final samples = entry.value;
          double maxTemp = double.negativeInfinity;
          double minTemp = double.infinity;

          // O günün tüm örneklerini kontrol et
          for (var sample in samples) {
            final temp = sample['main'];
            if (temp['temp_max'] > maxTemp)
              maxTemp = temp['temp_max'].toDouble();
            if (temp['temp_min'] < minTemp)
              minTemp = temp['temp_min'].toDouble();
          }

          // Günün ortasındaki veriyi kullan (öğlen vakti)
          final middayData = samples.firstWhere(
            (item) {
              final hour =
                  DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000).hour;
              return hour >= 12 && hour <= 15;
            },
            orElse: () =>
                samples.first, // Eğer öğlen verisi yoksa ilk veriyi kullan
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

        // Bugünden başlayarak 5 günü al ve sırala
        dailyForecasts.sort((a, b) => a.date.compareTo(b.date));
        return dailyForecasts.take(5).toList();
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error getting daily forecast: $e');
      rethrow;
    }
  }

  Future<WeatherModel> getCurrentWeatherByCoordinates(
      double latitude, double longitude) async {
    try {
      print('Fetching current weather for coordinates: $latitude, $longitude');
      final response = await http.get(
        Uri.parse(
            '$baseUrl/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric&lang=tr'),
      );

      print('Current weather response status: ${response.statusCode}');
      print('Current weather response body: ${response.body}');

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
          visibility: data['visibility'],
          pressure: data['main']['pressure'],
        );
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error getting weather by coordinates: $e');
      rethrow;
    }
  }

  String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }
}

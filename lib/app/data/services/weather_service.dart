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
      return _getWeatherBackgroundUrl(condition, isNight);
    } catch (e) {
      print('Arka plan resmi alınırken hata: $e');
      return _getDefaultBackgroundUrl();
    }
  }

  String _getWeatherBackgroundUrl(String condition, bool isNight) {
    // OpenWeatherMap ikon kodlarına göre arka plan seç
    String iconCode = condition.toLowerCase();

    // Gündüz durumları
    if (!isNight) {
      switch (iconCode) {
        case '01d': // açık hava
          return 'https://images.unsplash.com/photo-1598717123623-994ab270a08e'; // Parlak güneşli mavi gökyüzü
        case '02d': // az bulutlu
          return 'https://images.unsplash.com/photo-1601297183305-6df142704ea2'; // Az bulutlu mavi gökyüzü
        case '03d': // parçalı bulutlu
          return 'https://images.unsplash.com/photo-1501630834273-4b5604d2ee31'; // Parçalı bulutlu gökyüzü
        case '04d': // çok bulutlu
          return 'https://images.unsplash.com/photo-1525087740718-9e0f2c58c7ef'; // Kapalı bulutlu gökyüzü
        case '09d': // hafif yağmurlu
          return 'https://images.unsplash.com/photo-1438449805896-28a666819a20'; // Hafif yağmur
        case '10d': // yağmurlu
          return 'https://images.unsplash.com/photo-1534274988757-a28bf1a57c17'; // Yağmur
        case '11d': // gök gürültülü
          return 'https://images.unsplash.com/photo-1605727216801-e27ce1d0cc28'; // Şimşek ve yağmur
        case '13d': // karlı
          return 'https://images.unsplash.com/photo-1418985991508-e47386d96a71'; // Kar yağışı
        case '50d': // sisli
          return 'https://images.unsplash.com/photo-1486184885347-1464b5f10296'; // Sis
        default:
          if (condition.contains('açık')) {
            return 'https://images.unsplash.com/photo-1598717123623-994ab270a08e';
          } else if (condition.contains('parçalı bulut')) {
            return 'https://images.unsplash.com/photo-1501630834273-4b5604d2ee31';
          } else if (condition.contains('bulut')) {
            return 'https://images.unsplash.com/photo-1525087740718-9e0f2c58c7ef';
          } else if (condition.contains('hafif yağmur')) {
            return 'https://images.unsplash.com/photo-1438449805896-28a666819a20';
          } else if (condition.contains('yağmur')) {
            return 'https://images.unsplash.com/photo-1534274988757-a28bf1a57c17';
          } else if (condition.contains('kar')) {
            return 'https://images.unsplash.com/photo-1418985991508-e47386d96a71';
          } else if (condition.contains('sis')) {
            return 'https://images.unsplash.com/photo-1486184885347-1464b5f10296';
          } else if (condition.contains('gök gürültü')) {
            return 'https://images.unsplash.com/photo-1605727216801-e27ce1d0cc28';
          }
      }
    }
    // Gece durumları
    else {
      switch (iconCode) {
        case '01n': // açık hava gece
          return 'https://images.unsplash.com/photo-1507400492013-162706c8c05e'; // Yıldızlı gece
        case '02n': // az bulutlu gece
          return 'https://images.unsplash.com/photo-1504608524841-42fe6f032b4b'; // Az bulutlu gece
        case '03n': // parçalı bulutlu gece
        case '04n': // çok bulutlu gece
          return 'https://images.unsplash.com/photo-1500740516770-92bd004b996e'; // Bulutlu gece
        case '09n': // hafif yağmurlu gece
          return 'https://images.unsplash.com/photo-1509114397022-ed747cca3f65'; // Hafif yağmurlu gece
        case '10n': // yağmurlu gece
          return 'https://images.unsplash.com/photo-1501999635878-71cb5379c2d8'; // Yağmurlu gece
        case '11n': // gök gürültülü gece
          return 'https://images.unsplash.com/photo-1472145246862-b24cf25c4a36'; // Gök gürültülü gece
        case '13n': // karlı gece
          return 'https://images.unsplash.com/photo-1478265409131-1f65c88f965c'; // Karlı gece
        case '50n': // sisli gece
          return 'https://images.unsplash.com/photo-1485236715568-ddc5ee6ca227'; // Sisli gece
        default:
          if (condition.contains('açık')) {
            return 'https://images.unsplash.com/photo-1507400492013-162706c8c05e';
          } else if (condition.contains('bulut')) {
            return 'https://images.unsplash.com/photo-1500740516770-92bd004b996e';
          } else if (condition.contains('yağmur')) {
            return 'https://images.unsplash.com/photo-1501999635878-71cb5379c2d8';
          } else if (condition.contains('kar')) {
            return 'https://images.unsplash.com/photo-1478265409131-1f65c88f965c';
          } else if (condition.contains('sis')) {
            return 'https://images.unsplash.com/photo-1485236715568-ddc5ee6ca227';
          } else if (condition.contains('gök gürültü')) {
            return 'https://images.unsplash.com/photo-1472145246862-b24cf25c4a36';
          }
      }
    }

    return _getDefaultBackgroundUrl();
  }

  String _getDefaultBackgroundUrl() {
    return 'https://images.unsplash.com/photo-1598717123623-994ab270a08e'; // Varsayılan güzel mavi gökyüzü
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
        print(
            'Visibility: ${data['visibility']}, Pressure: ${data['main']['pressure']}'); // Debug için eklendi
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
        print(
            'Visibility: ${data['visibility']}, Pressure: ${data['main']['pressure']}'); // Debug için eklendi
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
      print('Error getting weather by coordinates: $e');
      rethrow;
    }
  }

  String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }
}

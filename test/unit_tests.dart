import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_app/app/data/models/weather_model.dart';
import 'package:flutter_weather_app/app/data/models/hourly_forecast.dart';
import 'package:flutter_weather_app/app/data/models/daily_forecast.dart';
import 'package:flutter_weather_app/app/core/constants/app_constants.dart';

void main() {
  group('Weather App Unit Tests', () {
    group('WeatherModel', () {
      test('should correctly parse JSON data', () {
        // Arrange
        final json = {
          'name': 'Istanbul',
          'main': {
            'temp': 25.5,
            'temp_max': 28.0,
            'temp_min': 22.0,
            'feels_like': 26.0,
            'humidity': 65,
            'pressure': 1013
          },
          'weather': [
            {'description': 'açık', 'icon': '01d'}
          ],
          'wind': {'speed': 3.5},
          'sys': {'sunrise': 1640995200, 'sunset': 1641031200},
          'visibility': 10000
        };

        // Act
        final weather = WeatherModel.fromJson(json);

        // Assert
        expect(weather.cityName, 'Istanbul');
        expect(weather.temperature, 25.5);
        expect(weather.description, 'açık');
        expect(weather.icon, '01d');
        expect(weather.maxTemp, 28.0);
        expect(weather.minTemp, 22.0);
        expect(weather.humidity, 65);
        expect(weather.pressure, 1013);
      });

      test('should correctly convert to JSON', () {
        // Arrange
        final weather = WeatherModel(
          cityName: 'Ankara',
          temperature: 20.0,
          description: 'bulutlu',
          maxTemp: 25.0,
          minTemp: 15.0,
          windSpeed: 5.0,
          sunrise: '06:30',
          sunset: '19:00',
          humidity: 70,
          feelsLike: 22.0,
          icon: '02d',
          visibility: 8,
          pressure: 1010,
        );

        // Act
        final json = weather.toJson();

        // Assert
        expect(json['cityName'], 'Ankara');
        expect(json['temperature'], 20.0);
        expect(json['description'], 'bulutlu');
        expect(json['maxTemp'], 25.0);
        expect(json['minTemp'], 15.0);
      });
    });

    group('HourlyForecast', () {
      test('should correctly parse hourly forecast JSON', () {
        // Arrange
        final json = {
          'dt': 1640998800,
          'main': {'temp': 23.0},
          'weather': [
            {'description': 'yağmurlu', 'icon': '10d'}
          ],
          'rain': {'3h': 2.5}
        };

        // Act
        final forecast = HourlyForecast.fromJson(json);

        // Assert
        expect(forecast.temperature, 23.0);
        expect(forecast.description, 'yağmurlu');
        expect(forecast.icon, '10d');
        expect(forecast.rain, 2.5);
        expect(forecast.time, isA<DateTime>());
        expect(forecast.hour, isA<String>());
      });
    });

    group('DailyForecast', () {
      test('should correctly parse daily forecast JSON', () {
        // Arrange
        final json = {
          'dt': 1640998800,
          'main': {'temp_max': 30.0, 'temp_min': 18.0},
          'weather': [
            {'description': 'güneşli', 'icon': '01d'}
          ],
          'rain': {'3h': 0.0}
        };

        // Act
        final forecast = DailyForecast.fromJson(json);

        // Assert
        expect(forecast.maxTemp, 30.0);
        expect(forecast.minTemp, 18.0);
        expect(forecast.description, 'güneşli');
        expect(forecast.icon, '01d');
        expect(forecast.date, isA<DateTime>());
      });
    });

    group('AppConstants', () {
      test('should have correct application constants', () {
        expect(AppConstants.appName, 'Hava Durumu');
        expect(AppConstants.defaultCity, 'İstanbul');
        expect(AppConstants.httpTimeoutSeconds, 10);
        expect(AppConstants.hourlyForecastLimit, 8);
        expect(AppConstants.dailyForecastLimit, 5);
      });

      test('should have localized error messages', () {
        expect(AppConstants.noInternetError, 'İnternet bağlantısı yok');
        expect(AppConstants.weatherDataError, 'Hava durumu verileri alınamadı');
        expect(AppConstants.locationServiceDisabledError, contains('Konum'));
        expect(AppConstants.locationPermissionDeniedError, contains('izni'));
      });

      test('should have valid timeout configurations', () {
        expect(AppConstants.httpTimeoutSeconds, greaterThan(0));
        expect(AppConstants.locationTimeoutSeconds, greaterThan(0));
        expect(AppConstants.httpTimeoutSeconds, lessThanOrEqualTo(30));
        expect(AppConstants.locationTimeoutSeconds, lessThanOrEqualTo(10));
      });
    });

    group('Temperature Conversion', () {
      test('should correctly convert Celsius to Fahrenheit', () {
        // Celsius to Fahrenheit: (C * 9/5) + 32

        // Freezing point
        double celsius = 0.0;
        double fahrenheit = (celsius * 9 / 5) + 32;
        expect(fahrenheit, 32.0);

        // Boiling point
        celsius = 100.0;
        fahrenheit = (celsius * 9 / 5) + 32;
        expect(fahrenheit, 212.0);

        // Room temperature
        celsius = 25.0;
        fahrenheit = (celsius * 9 / 5) + 32;
        expect(fahrenheit, 77.0);
      });

      test('should handle extreme temperature values', () {
        // Special case where Celsius equals Fahrenheit
        double celsius = -40.0;
        double fahrenheit = (celsius * 9 / 5) + 32;
        expect(fahrenheit, -40.0);

        // Very hot temperature
        celsius = 50.0;
        fahrenheit = (celsius * 9 / 5) + 32;
        expect(fahrenheit, 122.0);
      });
    });

    group('Configuration Validation', () {
      test('should have valid default cities list', () {
        expect(AppConstants.defaultCities, isNotEmpty);
        expect(AppConstants.defaultCities.length, greaterThan(5));
        expect(AppConstants.defaultCities, contains('İstanbul'));
        expect(AppConstants.defaultCities, contains('Ankara'));
        expect(AppConstants.defaultCities, contains('İzmir'));
      });

      test('should have reasonable UI constants', () {
        expect(AppConstants.defaultPadding, 16.0);
        expect(AppConstants.cardBorderRadius, 20.0);
        expect(AppConstants.iconSize, 24.0);
        expect(AppConstants.largeIconSize, 40.0);
        expect(AppConstants.defaultPadding, greaterThan(0));
        expect(AppConstants.cardBorderRadius, greaterThan(0));
      });

      test('should have appropriate animation durations', () {
        expect(AppConstants.animationDurationMs, 300);
        expect(AppConstants.staggerDelayMs, 100);
        expect(AppConstants.animationDurationMs, greaterThan(100));
        expect(AppConstants.animationDurationMs, lessThan(1000));
        expect(AppConstants.staggerDelayMs,
            lessThan(AppConstants.animationDurationMs));
      });

      test('should have valid forecast limits', () {
        expect(AppConstants.hourlyForecastLimit, greaterThan(0));
        expect(AppConstants.dailyForecastLimit, greaterThan(0));
        expect(AppConstants.hourlyForecastLimit, lessThanOrEqualTo(24));
        expect(AppConstants.dailyForecastLimit, lessThanOrEqualTo(7));
      });
    });
  });
}

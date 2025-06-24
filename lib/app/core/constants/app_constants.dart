class AppConstants {
  // App Info
  static const String appName = 'Hava Durumu';
  static const String appVersion = '1.0.0';

  // Default Cities
  static const List<String> defaultCities = [
    'İstanbul',
    'Ankara',
    'İzmir',
    'Antalya',
    'Bursa',
    'Adana',
    'Konya',
    'Gaziantep',
  ];

  // Default Location
  static const String defaultCity = 'İstanbul';

  // Time Constants
  static const int locationTimeoutSeconds = 5;
  static const int httpTimeoutSeconds = 10;
  static const int dialogDelaySeconds = 2;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 20.0;
  static const double iconSize = 24.0;
  static const double largeIconSize = 40.0;

  // Animation Constants
  static const int animationDurationMs = 300;
  static const int staggerDelayMs = 100;

  // Forecast Limits
  static const int hourlyForecastLimit = 8;
  static const int dailyForecastLimit = 5;

  // Error Messages
  static const String noInternetError = 'İnternet bağlantısı yok';
  static const String locationServiceDisabledError =
      'Konum servisi devre dışı.';
  static const String locationPermissionDeniedError = 'Konum izni reddedildi.';
  static const String locationPermissionPermanentlyDeniedError =
      'Konum izni kalıcı olarak reddedildi. Lütfen ayarlardan konum iznini etkinleştirin.';
  static const String weatherDataError = 'Hava durumu verileri alınamadı';
  static const String locationBasedWeatherError =
      'Konum bazlı hava durumu bilgisi alınamadı';
  static const String hourlyForecastError = 'Saatlik tahmin bilgisi alınamadı';
  static const String dailyForecastError = 'Günlük tahmin bilgisi alınamadı';
  static const String backgroundImageError = 'Arka plan resmi alınamadı';
}

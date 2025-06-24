class ApiEndpoints {
  // Base URLs
  static const String openWeatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';
  static const String openWeatherIconBaseUrl =
      'https://openweathermap.org/img/wn';
  static const String unsplashBaseUrl = 'https://images.unsplash.com';

  // Weather API Endpoints
  static const String currentWeather = '/weather';
  static const String forecast = '/forecast';

  // Icon URL Templates
  static String getWeatherIconUrl(String iconCode, {String size = '@2x'}) {
    return '$openWeatherIconBaseUrl/$iconCode$size.png';
  }

  static String getWeatherIconUrlSmall(String iconCode) {
    return '$openWeatherIconBaseUrl/$iconCode.png';
  }

  // Query Parameters
  static const String apiKeyParam = 'appid';
  static const String unitsParam = 'units';
  static const String langParam = 'lang';
  static const String cityParam = 'q';
  static const String latParam = 'lat';
  static const String lonParam = 'lon';

  // Default Values
  static const String defaultUnits = 'metric';
  static const String defaultLang = 'tr';
}

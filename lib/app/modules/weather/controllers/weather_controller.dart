import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../data/models/weather_model.dart';
import '../../../data/models/hourly_forecast.dart';
import '../../../data/models/daily_forecast.dart';
import '../../../data/services/weather_service.dart';
import '../../../data/services/location_service.dart';

class WeatherController extends GetxController {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final _connectivity = Connectivity();

  final currentWeather = Rx<WeatherModel?>(null);
  final hourlyForecast = RxList<HourlyForecast>([]);
  final dailyForecast = RxList<DailyForecast>([]);
  final errorMessage = RxString('');
  final isLoading = RxBool(false);
  final isCelsius = RxBool(true);
  final currentCity = RxString('İstanbul');
  final hasInternetConnection = RxBool(true);
  final backgroundImageUrl = RxString('');

  @override
  void onInit() {
    super.onInit();
    _setupConnectivityStream();
    _initializeWeatherData();
  }

  void _setupConnectivityStream() {
    _connectivity.onConnectivityChanged.listen((result) {
      hasInternetConnection.value = result != ConnectivityResult.none;
      if (hasInternetConnection.value) {
        fetchWeatherData(currentCity.value);
      }
    });
  }

  Future<void> _initializeWeatherData() async {
    isLoading.value = true;
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        // Konum bilgisini şehir adına çevir ve hava durumunu getir
        final response = await _weatherService.getCurrentWeatherByCoordinates(
          position.latitude,
          position.longitude,
        );
        currentCity.value = response.cityName;
      }
    } catch (e) {
      print('Konum alınamadı, varsayılan şehir kullanılıyor: $e');
      currentCity.value = 'İstanbul';
    }
    await fetchWeatherData(currentCity.value);
    isLoading.value = false;
  }

  Future<void> _updateBackgroundImage() async {
    if (currentWeather.value != null) {
      final condition = currentWeather.value!.description;
      final isNight = currentWeather.value!.icon.endsWith('n');
      try {
        final imageUrl =
            await _weatherService.getWeatherBackgroundImage(condition, isNight);
        backgroundImageUrl.value = imageUrl;
      } catch (e) {
        print('Arka plan resmi güncellenirken hata: $e');
      }
    }
  }

  Future<void> fetchWeatherData(String city) async {
    if (!hasInternetConnection.value) {
      errorMessage.value = 'İnternet bağlantısı yok';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final weather = await _weatherService.getCurrentWeather(city);
      currentWeather.value = weather;
      currentCity.value = weather.cityName;

      final hourly = await _weatherService.getHourlyForecast(city);
      hourlyForecast.value = hourly;

      final daily = await _weatherService.getDailyForecast(city);
      dailyForecast.value = daily;

      await _updateBackgroundImage();
    } catch (e) {
      errorMessage.value = 'Hava durumu verileri alınamadı: ${e.toString()}';
      print('Hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleTemperatureUnit() {
    isCelsius.value = !isCelsius.value;
  }

  double convertTemperature(double celsius) {
    return isCelsius.value ? celsius : (celsius * 9 / 5) + 32;
  }

  String getTemperatureUnit() {
    return isCelsius.value ? '°C' : '°F';
  }

  void refreshWeatherData() {
    fetchWeatherData(currentCity.value);
  }
}

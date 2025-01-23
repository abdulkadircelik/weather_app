import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../data/models/weather_model.dart';
import '../../../data/models/hourly_forecast.dart';
import '../../../data/models/daily_forecast.dart';
import '../../../data/repositories/weather_repository.dart';
import '../../../data/services/location_service.dart';

class WeatherController extends GetxController {
  final WeatherRepository _weatherRepository = Get.find<WeatherRepository>();
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

  void toggleTemperatureUnit() {
    isCelsius.toggle();
    if (currentWeather.value != null) {
      currentWeather.refresh();
      hourlyForecast.refresh();
      dailyForecast.refresh();
    }
  }

  double convertTemperature(double celsius) {
    return isCelsius.value ? celsius : (celsius * 9 / 5) + 32;
  }

  String getTemperatureUnit() => isCelsius.value ? '°C' : '°F';

  Future<void> _initializeWeatherData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final position = await _locationService.getCurrentLocation();

      if (position != null) {
        try {
          final response =
              await _weatherRepository.getCurrentWeatherByCoordinates(
            position.latitude,
            position.longitude,
          );
          currentCity.value = response.cityName;
          await fetchWeatherData(currentCity.value);
          return;
        } catch (e) {
          currentCity.value = 'İstanbul';
        }
      } else {
        currentCity.value = 'İstanbul';
      }

      await fetchWeatherData(currentCity.value);
    } catch (e) {
      errorMessage.value = e.toString();
      currentCity.value = 'İstanbul';
      await fetchWeatherData(currentCity.value);
    } finally {
      isLoading.value = false;
    }
  }

  void _setupConnectivityStream() {
    _connectivity.onConnectivityChanged.listen((result) {
      hasInternetConnection.value = result != ConnectivityResult.none;
      if (hasInternetConnection.value) {
        checkLocationAndUpdateWeather();
      }
    });
  }

  Future<void> _updateBackgroundImage() async {
    if (currentWeather.value != null) {
      final condition = currentWeather.value!.description;
      final isNight = currentWeather.value!.icon.endsWith('n');
      try {
        final imageUrl = await _weatherRepository.getWeatherBackgroundImage(
            condition, isNight);
        backgroundImageUrl.value = imageUrl;
      } catch (e) {
        backgroundImageUrl.value = '';
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
      final weather = await _weatherRepository.getCurrentWeather(city);
      currentWeather.value = weather;
      currentCity.value = weather.cityName;

      final hourly = await _weatherRepository.getHourlyForecast(city);
      hourlyForecast.value = hourly;

      final daily = await _weatherRepository.getDailyForecast(city);
      dailyForecast.value = daily;

      await _updateBackgroundImage();
    } catch (e) {
      errorMessage.value = 'Hava durumu verileri alınamadı: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void refreshWeatherData() {
    fetchWeatherData(currentCity.value);
  }

  Future<void> checkLocationAndUpdateWeather() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        isLoading.value = true;
        final response =
            await _weatherRepository.getCurrentWeatherByCoordinates(
          position.latitude,
          position.longitude,
        );
        currentCity.value = response.cityName;
        await fetchWeatherData(currentCity.value);
      }
    } catch (e) {
      print('Konum güncelleme hatası: $e');
      if (currentCity.value.isEmpty) {
        currentCity.value = 'İstanbul';
        await fetchWeatherData(currentCity.value);
      }
    } finally {
      isLoading.value = false;
    }
  }
}

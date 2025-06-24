import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/models/weather_model.dart';
import '../../../data/models/hourly_forecast.dart';
import '../../../data/models/daily_forecast.dart';
import '../../../data/repositories/weather_repository_interface.dart';
import '../../../data/services/location_service.dart';
import '../../../core/constants/app_constants.dart';

class WeatherController extends GetxController {
  final IWeatherRepository _weatherRepository = Get.find<IWeatherRepository>();
  final ILocationService _locationService = Get.find<ILocationService>();
  final _connectivity = Connectivity();

  final currentWeather = Rx<WeatherModel?>(null);
  final hourlyForecast = RxList<HourlyForecast>([]);
  final dailyForecast = RxList<DailyForecast>([]);
  final errorMessage = RxString('');
  final isLoading = RxBool(false);
  final isCelsius = RxBool(true);
  final currentCity = RxString(AppConstants.defaultCity);
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
        } catch (e) {
          errorMessage.value = e.toString();
          currentCity.value = AppConstants.defaultCity;
          await fetchWeatherData(currentCity.value);
        }
      } else {
        currentCity.value = AppConstants.defaultCity;
        await fetchWeatherData(currentCity.value);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      currentCity.value = AppConstants.defaultCity;
      await fetchWeatherData(currentCity.value);
    } finally {
      isLoading.value = false;
    }
  }

  void _setupConnectivityStream() {
    _connectivity.onConnectivityChanged.listen((result) {
      hasInternetConnection.value = result != ConnectivityResult.none;
      if (hasInternetConnection.value) {
        fetchWeatherData(currentCity.value);
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
      errorMessage.value = AppConstants.noInternetError;
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
      errorMessage.value = '${AppConstants.weatherDataError}: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void refreshWeatherData() {
    fetchWeatherData(currentCity.value);
  }

  Future<void> checkLocationAndUpdateWeather() async {
    try {
      isLoading.value = true;
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        final response =
            await _weatherRepository.getCurrentWeatherByCoordinates(
          position.latitude,
          position.longitude,
        );
        currentCity.value = response.cityName;
        await fetchWeatherData(currentCity.value);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      if (currentCity.value.isEmpty) {
        currentCity.value = AppConstants.defaultCity;
        await fetchWeatherData(currentCity.value);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateLocationWeather(Position position) async {
    try {
      final response = await _weatherRepository.getCurrentWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );
      currentCity.value = response.cityName;
      await fetchWeatherData(currentCity.value);
    } catch (e) {
      errorMessage.value = e.toString();
      if (currentCity.value.isEmpty) {
        currentCity.value = AppConstants.defaultCity;
        await fetchWeatherData(currentCity.value);
      }
    }
  }
}

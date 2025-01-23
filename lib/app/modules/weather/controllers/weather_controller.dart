import 'package:get/get.dart';
import '../../../data/models/weather_model.dart';
import '../../../data/services/weather_service.dart';

class WeatherController extends GetxController {
  final WeatherService _weatherService = WeatherService();

  final Rx<WeatherModel?> currentWeather = Rx<WeatherModel?>(null);
  final RxList<HourlyForecast> hourlyForecast = <HourlyForecast>[].obs;
  final RxList<DailyForecast> dailyForecast = <DailyForecast>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCelsius = true.obs;
  final RxString errorMessage = ''.obs;

  Future<void> getWeatherData(String city) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final weather = await _weatherService.getCurrentWeather(city);
      final hourly = await _weatherService.getHourlyForecast(city);
      final daily = await _weatherService.getDailyForecast(city);

      currentWeather.value = weather;
      hourlyForecast.value = hourly;
      dailyForecast.value = daily;
    } catch (e) {
      errorMessage.value =
          'Hava durumu bilgileri alınamadı. Lütfen tekrar deneyin.';
    } finally {
      isLoading.value = false;
    }
  }

  double convertTemperature(double celsius) {
    return isCelsius.value ? celsius : (celsius * 9 / 5) + 32;
  }

  void toggleTemperatureUnit() {
    isCelsius.value = !isCelsius.value;
  }

  String getTemperatureUnit() {
    return isCelsius.value ? '°C' : '°F';
  }
}

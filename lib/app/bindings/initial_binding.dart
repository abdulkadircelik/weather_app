import 'package:get/get.dart';
import '../data/services/weather_service.dart';
import '../data/repositories/weather_repository.dart';
import '../modules/weather/controllers/weather_controller.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<WeatherService>(() => WeatherService(), fenix: true);

    // Repositories
    Get.lazyPut<WeatherRepository>(() => WeatherRepository(), fenix: true);

    // Controllers
    Get.lazyPut<WeatherController>(() => WeatherController(), fenix: true);
  }
}

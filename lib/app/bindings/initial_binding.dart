import 'package:get/get.dart';
import '../data/services/weather_service.dart';
import '../data/services/http_service.dart';
import '../data/services/location_service.dart';
import '../data/repositories/weather_repository.dart';
import '../data/repositories/weather_repository_interface.dart';
import '../modules/weather/controllers/weather_controller.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    // Base Services
    Get.lazyPut<IHttpService>(() => HttpService(), fenix: true);
    Get.lazyPut<IDialogService>(() => DialogService(), fenix: true);

    // Application Services
    Get.lazyPut<IWeatherService>(
      () => WeatherService(httpService: Get.find<IHttpService>()),
      fenix: true,
    );
    Get.lazyPut<ILocationService>(
      () => LocationService(dialogService: Get.find<IDialogService>()),
      fenix: true,
    );

    // Repositories
    Get.lazyPut<IWeatherRepository>(
      () => WeatherRepository(weatherService: Get.find<IWeatherService>()),
      fenix: true,
    );

    // Controllers
    Get.lazyPut<WeatherController>(() => WeatherController(), fenix: true);
  }
}

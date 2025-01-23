import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/weather_controller.dart';
import '../../../widgets/current_weather_card.dart';
import '../../../widgets/hourly_forecast_list.dart';
import '../../../widgets/daily_forecast_list.dart';

class WeatherView extends GetView<WeatherController> {
  const WeatherView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade500,
              Colors.blue.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? screenWidth * 0.1 : 16.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Hava Durumu',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: () {
                            if (controller.currentWeather.value != null) {
                              controller.getWeatherData(
                                  controller.currentWeather.value!.cityName);
                            }
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: InkWell(
                            onTap: controller.toggleTemperatureUnit,
                            child: Obx(() => Text(
                                  controller.getTemperatureUnit(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? screenWidth * 0.1 : 16.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Şehir adı girin',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white70),
                      suffixIcon:
                          const Icon(Icons.location_on, color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        controller.getWeatherData(value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Hava durumu bilgileri alınıyor...',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (controller.errorMessage.isNotEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 64, color: Colors.red.shade300),
                              const SizedBox(height: 16),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  controller.errorMessage.value,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.red.shade300,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (controller.currentWeather.value == null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_outlined,
                                  size: 100, color: Colors.blue.shade200),
                              const SizedBox(height: 16),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  'Hava durumu bilgisi için bir şehir adı girin',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () => controller.getWeatherData(
                          controller.currentWeather.value!.cityName,
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (isTablet) {
                              return SingleChildScrollView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05,
                                  vertical: 20,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            children: const [
                                              CurrentWeatherCard(),
                                              SizedBox(height: 20),
                                              HourlyForecastList(),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        const Expanded(
                                          flex: 2,
                                          child: DailyForecastList(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView(
                              padding: const EdgeInsets.all(16.0),
                              children: const [
                                CurrentWeatherCard(),
                                SizedBox(height: 16.0),
                                HourlyForecastList(),
                                SizedBox(height: 16.0),
                                DailyForecastList(),
                                SizedBox(height: 16.0),
                              ],
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/weather/controllers/weather_controller.dart';

class CurrentWeatherCard extends GetView<WeatherController> {
  const CurrentWeatherCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade300.withOpacity(0.7),
            Colors.blue.shade500.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: const ColorFilter.mode(
            Colors.white10,
            BlendMode.softLight,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              controller.currentWeather.value?.cityName ?? '',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.currentWeather.value?.description
                                  .capitalizeFirst ??
                              '',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Image.network(
                      'https://openweathermap.org/img/w/${controller.currentWeather.value?.icon ?? ''}.png',
                      width: 100,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.error,
                          size: 100,
                          color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      final temp =
                          controller.currentWeather.value?.temperature ?? 0;
                      return Text(
                        controller.convertTemperature(temp).toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                        ),
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Obx(() => Text(
                            controller.getTemperatureUnit(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildWeatherInfo(
                        'Nem',
                        '${controller.currentWeather.value?.humidity ?? 0}%',
                        Icons.water_drop_outlined,
                      ),
                      _buildDivider(),
                      _buildWeatherInfo(
                        'Rüzgar',
                        '${controller.currentWeather.value?.windSpeed ?? 0} m/s',
                        Icons.air_outlined,
                      ),
                      _buildDivider(),
                      Obx(() {
                        final feelsLike =
                            controller.currentWeather.value?.feelsLike ?? 0;
                        return _buildWeatherInfo(
                          'Hissedilen',
                          '${controller.convertTemperature(feelsLike).toStringAsFixed(1)}${controller.getTemperatureUnit()}',
                          Icons.thermostat_outlined,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.white70),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 50,
      width: 1,
      color: Colors.white24,
    );
  }
}

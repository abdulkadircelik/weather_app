import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../modules/weather/controllers/weather_controller.dart';
import '../core/constants/api_endpoints.dart';

class HourlyForecastList extends GetView<WeatherController> {
  // ignore: use_super_parameters
  const HourlyForecastList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(100),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.access_time,
                      size: 24, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 12),
                Text(
                  'Saatlik Tahmin',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 150,
              child: Obx(() {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.hourlyForecast.length,
                  itemBuilder: (context, index) {
                    final forecast = controller.hourlyForecast[index];
                    final isNow = index == 0;
                    return Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        gradient: isNow
                            ? LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade600,
                                ],
                              )
                            : null,
                        color: isNow ? null : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isNow
                                ? Colors.blue.shade200.withAlpha(100)
                                : Colors.grey.withAlpha(100),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              DateFormat('HH:mm').format(forecast.time),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color:
                                    isNow ? Colors.white : Colors.grey.shade700,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isNow
                                    ? Colors.white.withAlpha(100)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.network(
                                ApiEndpoints.getWeatherIconUrlSmall(
                                    forecast.icon),
                                width: 40,
                                height: 40,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.error,
                                        size: 40,
                                        color: isNow
                                            ? Colors.white
                                            : Colors.grey.shade400),
                              ),
                            ),
                            Text(
                              '${controller.convertTemperature(forecast.temperature).toStringAsFixed(1)}${controller.getTemperatureUnit()}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    isNow ? Colors.white : Colors.grey.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

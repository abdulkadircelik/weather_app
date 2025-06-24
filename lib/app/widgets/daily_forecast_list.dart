import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../modules/weather/controllers/weather_controller.dart';
import '../core/constants/api_endpoints.dart';

class DailyForecastList extends GetView<WeatherController> {
  // ignore: use_super_parameters
  const DailyForecastList({Key? key}) : super(key: key);

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
                  child: Icon(Icons.calendar_today,
                      size: 24, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 12),
                Text(
                  '5 Günlük Tahmin',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Obx(() {
              return Column(
                children: controller.dailyForecast.map((forecast) {
                  final isToday = forecast.date.day == DateTime.now().day;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: isToday
                          ? LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade600,
                              ],
                            )
                          : null,
                      color: isToday ? null : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isToday
                              ? Colors.blue.shade200.withAlpha(100)
                              : Colors.grey.withAlpha(100),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? Colors.white.withAlpha(100)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  DateFormat('E', 'tr_TR')
                                      .format(forecast.date)
                                      .substring(0, 3)
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isToday
                                        ? Colors.white
                                        : Colors.blue.shade800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('d MMM', 'tr_TR')
                                    .format(forecast.date),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isToday
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isToday
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
                                      color: isToday
                                          ? Colors.white
                                          : Colors.grey.shade400),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${controller.convertTemperature(forecast.maxTemp).toStringAsFixed(1)}${controller.getTemperatureUnit()}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isToday
                                      ? Colors.white
                                      : Colors.grey.shade900,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${controller.convertTemperature(forecast.minTemp).toStringAsFixed(1)}${controller.getTemperatureUnit()}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isToday
                                      ? Colors.white.withAlpha(100)
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

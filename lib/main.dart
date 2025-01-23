import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/modules/weather/views/weather_view.dart';
import 'app/modules/weather/controllers/weather_controller.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('tr_TR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Hava Durumu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WeatherView(),
      initialBinding: BindingsBuilder(() {
        Get.put(WeatherController());
      }),
    );
  }
}

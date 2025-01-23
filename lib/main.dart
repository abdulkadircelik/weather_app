import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/modules/weather/views/weather_view.dart';
import 'app/core/theme/app_theme.dart';
import 'app/bindings/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      theme: AppTheme.darkTheme,
      home: const WeatherView(),
      initialBinding: InitialBinding(),
      debugShowCheckedModeBanner: false,
    );
  }
}

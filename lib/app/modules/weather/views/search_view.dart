import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/weather_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class SearchView extends GetView<WeatherController> {
  // ignore: use_super_parameters
  const SearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Şehir Ara'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Şehir adı girin',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white60),
                filled: true,
                fillColor: AppTheme.cardColor.withAlpha(100),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  controller.fetchWeatherData(value);
                  Get.back();
                }
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: AppConstants.defaultCities.length,
                itemBuilder: (context, index) {
                  return _buildQuickCityItem(AppConstants.defaultCities[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCityItem(String city) {
    return Card(
      color: AppTheme.cardColor.withAlpha(100),
      child: ListTile(
        title: Text(
          city,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white60,
          size: 16,
        ),
        onTap: () {
          controller.fetchWeatherData(city);
          Get.back();
        },
      ),
    );
  }
}

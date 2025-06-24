import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/weather_controller.dart';
import 'search_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../widgets/loading_widget.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/api_constants.dart';

class WeatherView extends GetView<WeatherController> {
  // ignore: use_super_parameters
  const WeatherView({Key? key}) : super(key: key);

  String _getWeatherIconUrl(String iconCode) {
    return ApiEndpoints.getWeatherIconUrl(iconCode);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final padding = isTablet ? 32.0 : 16.0;
    final cardHeight = isTablet ? size.height * 0.3 : size.height * 0.25;

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshWeatherData,
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        }

        if (!controller.hasInternetConnection.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'İnternet bağlantısı yok',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshWeatherData,
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider(
                controller.backgroundImageUrl.value.isNotEmpty
                    ? controller.backgroundImageUrl.value
                    : ApiConstants.defaultBackgroundUrl,
              ),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withAlpha(100),
                BlendMode.darken,
              ),
            ),
          ),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: () =>
                  controller.fetchWeatherData(controller.currentCity.value),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    floating: true,
                    backgroundColor: Colors.transparent,
                    expandedHeight: isTablet ? 80 : 60,
                    title: Row(
                      children: [
                        const Icon(Icons.location_on, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          controller.currentWeather.value?.cityName ??
                              'Konum Seçin',
                          style: TextStyle(fontSize: isTablet ? 24 : 20),
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          if (controller.currentWeather.value != null) {
                            controller.fetchWeatherData(
                                controller.currentWeather.value!.cityName);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.thermostat),
                        onPressed: controller.toggleTemperatureUnit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => Get.to(
                          () => const SearchView(),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 300),
                        ),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: padding,
                        vertical: padding,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (isTablet) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                    height: cardHeight,
                                    child: _buildMainWeatherCard(),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      _buildHourlyForecast(),
                                      const SizedBox(height: 16),
                                      _buildDailyForecast(),
                                      const SizedBox(height: 16),
                                      _buildWeatherDetails(),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              SizedBox(
                                height: cardHeight,
                                child: _buildMainWeatherCard(),
                              ),
                              const SizedBox(height: 20),
                              _buildHourlyForecast(),
                              const SizedBox(height: 20),
                              _buildDailyForecast(),
                              const SizedBox(height: 20),
                              _buildWeatherDetails(),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMainWeatherCard() {
    final size = MediaQuery.of(Get.context!).size;
    final isTablet = size.width > 600;

    return Card(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24.0 : 16.0,
          vertical: isTablet ? 20.0 : 12.0,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final tempFontSize = isTablet
                ? (maxWidth * 0.15).clamp(40.0, 72.0)
                : (maxWidth * 0.18).clamp(40.0, 56.0);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sol taraf - Sıcaklık ve açıklama
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${controller.convertTemperature(controller.currentWeather.value?.temperature ?? 0).round()}°',
                                    style: TextStyle(
                                      fontSize: tempFontSize,
                                      height: 0.9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    controller.getTemperatureUnit(),
                                    style: TextStyle(
                                      fontSize: tempFontSize * 0.4,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.currentWeather.value?.description
                                      .capitalizeFirst ??
                                  '',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'H:${controller.convertTemperature(controller.currentWeather.value?.maxTemp ?? 0).round()}° L:${controller.convertTemperature(controller.currentWeather.value?.minTemp ?? 0).round()}°',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Sağ taraf - Hava durumu ikonu
                      if (controller.currentWeather.value?.icon != null)
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Image.network(
                              _getWeatherIconUrl(
                                  controller.currentWeather.value!.icon),
                              width: isTablet ? 80 : 60,
                              height: isTablet ? 80 : 60,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                Icons.error_outline,
                                size: isTablet ? 80 : 60,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 16),
                // Alt kısım - Hava detayları
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWeatherInfo(
                      'Nem',
                      '${controller.currentWeather.value?.humidity ?? 0}%',
                      Icons.water_drop_outlined,
                    ),
                    _buildWeatherInfo(
                      'Rüzgar',
                      '${controller.currentWeather.value?.windSpeed ?? 0} km/h',
                      Icons.air_outlined,
                    ),
                    _buildWeatherInfo(
                      'Hissedilen',
                      '${controller.convertTemperature(controller.currentWeather.value?.feelsLike ?? 0).round()}°',
                      Icons.thermostat_outlined,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHourlyForecast() {
    return Hero(
      tag: 'hourly_forecast',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Saatlik Tahmin',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.hourlyForecast.length,
                  itemBuilder: (context, index) {
                    final forecast = controller.hourlyForecast[index];
                    return Card(
                      margin: const EdgeInsets.only(right: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              forecast.hour,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Image.network(
                              _getWeatherIconUrl(forecast.icon),
                              width: 40,
                              height: 40,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.error_outline,
                                size: 40,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${controller.convertTemperature(forecast.temperature).round()}°',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyForecast() {
    return Hero(
      tag: 'daily_forecast',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '5 Günlük Tahmin',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.dailyForecast.length,
                itemBuilder: (context, index) {
                  final forecast = controller.dailyForecast[index];
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    curve: Curves.easeInOut,
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                index == 0
                                    ? 'Bugün'
                                    : _getDayName(forecast.date),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Image.network(
                                _getWeatherIconUrl(forecast.icon),
                                width: 40,
                                height: 40,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.error_outline,
                                  size: 40,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '${controller.convertTemperature(forecast.maxTemp).round()}°',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${controller.convertTemperature(forecast.minTemp).round()}°',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white.withAlpha(100),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetails() {
    return Hero(
      tag: 'weather_details',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hava Detayları',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildDetailCard(
                    'Görünürlük',
                    '${((controller.currentWeather.value?.visibility ?? 0) / 1000).toStringAsFixed(1)} km',
                    Icons.visibility_outlined,
                  ),
                  _buildDetailCard(
                    'Gün Doğumu',
                    controller.currentWeather.value?.sunrise ?? '00:00',
                    Icons.wb_twilight,
                  ),
                  _buildDetailCard(
                    'Gün Batımı',
                    controller.currentWeather.value?.sunset ?? '00:00',
                    Icons.nightlight_round,
                  ),
                  _buildDetailCard(
                    'Basınç',
                    '${controller.currentWeather.value?.pressure ?? 0} hPa',
                    Icons.speed,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.white70),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(DateTime date) {
    final days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar'
    ];
    return days[date.weekday - 1];
  }
}

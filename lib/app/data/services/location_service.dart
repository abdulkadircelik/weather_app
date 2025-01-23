import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../modules/weather/controllers/weather_controller.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        bool? openLocationSettings = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Konum Servisi Kapalı'),
            content: const Text(
                'Konumunuza göre hava durumu bilgisi almak için lütfen konum servisini açın.'),
            actions: [
              TextButton(
                child: const Text('İptal'),
                onPressed: () => Get.back(result: false),
              ),
              TextButton(
                child: const Text('Ayarlara Git'),
                onPressed: () => Get.back(result: true),
              ),
            ],
          ),
          barrierDismissible: false,
        );

        if (openLocationSettings == true) {
          await Geolocator.openLocationSettings();
          // Ayarlar açıldıktan sonra kullanıcıya biraz zaman ver
          await Future.delayed(const Duration(seconds: 2));
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            throw Exception('Konum servisi devre dışı.');
          }
          // Konum servisi açıldıysa, konumu al ve WeatherController'ı güncelle
          final position = await _getPosition();
          await Get.find<WeatherController>().updateLocationWeather(position);
          return position;
        } else {
          throw Exception('Konum servisi gerekli.');
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          bool? openAppSettings = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Konum İzni Gerekli'),
              content: const Text(
                  'Konumunuza göre hava durumu bilgisi almak için lütfen konum iznini verin.'),
              actions: [
                TextButton(
                  child: const Text('İptal'),
                  onPressed: () => Get.back(result: false),
                ),
                TextButton(
                  child: const Text('Ayarlara Git'),
                  onPressed: () => Get.back(result: true),
                ),
              ],
            ),
            barrierDismissible: false,
          );

          if (openAppSettings == true) {
            await Geolocator.openAppSettings();
            await Future.delayed(const Duration(seconds: 2));
            permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.denied) {
              throw Exception('Konum izni reddedildi.');
            }
            // İzin verildiyse, konumu al ve WeatherController'ı güncelle
            final position = await _getPosition();
            await Get.find<WeatherController>().updateLocationWeather(position);
            return position;
          } else {
            throw Exception('Konum izni gerekli.');
          }
        }
      }

      if (permission == LocationPermission.deniedForever) {
        bool? openAppSettings = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Konum İzni Gerekli'),
            content: const Text(
                'Konum izni kalıcı olarak reddedildi. Lütfen uygulama ayarlarından konum iznini etkinleştirin.'),
            actions: [
              TextButton(
                child: const Text('İptal'),
                onPressed: () => Get.back(result: false),
              ),
              TextButton(
                child: const Text('Ayarlara Git'),
                onPressed: () => Get.back(result: true),
              ),
            ],
          ),
          barrierDismissible: false,
        );

        if (openAppSettings == true) {
          await Geolocator.openAppSettings();
          await Future.delayed(const Duration(seconds: 2));
          permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.deniedForever) {
            throw Exception(
                'Konum izni kalıcı olarak reddedildi. Lütfen ayarlardan konum iznini etkinleştirin.');
          }
          // İzin verildiyse, konumu al ve WeatherController'ı güncelle
          final position = await _getPosition();
          await Get.find<WeatherController>().updateLocationWeather(position);
          return position;
        } else {
          throw Exception('Konum izni gerekli.');
        }
      }

      // Normal durumda konumu al ve WeatherController'ı güncelle
      final position = await _getPosition();
      await Get.find<WeatherController>().updateLocationWeather(position);
      return position;
    } catch (e) {
      rethrow;
    }
  }

  Future<Position> _getPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 5),
    );
  }
}

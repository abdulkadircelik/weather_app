import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../modules/weather/controllers/weather_controller.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    try {
      print('Konum servisi kontrolü başlatıldı');

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('Konum servisi durumu: $serviceEnabled');

      if (!serviceEnabled) {
        print('Konum servisi kapalı');
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
          // Ayarlar açıldıktan sonra tekrar kontrol et
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            throw Exception('Konum servisi devre dışı.');
          }
          // Konum servisi açıldıysa, WeatherController'daki checkLocationAndUpdateWeather metodunu çağır
          await Get.find<WeatherController>().checkLocationAndUpdateWeather();
        } else {
          throw Exception('Konum servisi gerekli.');
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      print('Mevcut konum izni: $permission');

      if (permission == LocationPermission.denied) {
        print('Konum izni isteniyor...');
        permission = await Geolocator.requestPermission();
        print('Konum izni yanıtı: $permission');

        if (permission == LocationPermission.denied) {
          print('Konum izni reddedildi');
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
            permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.denied) {
              throw Exception('Konum izni reddedildi.');
            }
            // İzin verildiyse, WeatherController'daki checkLocationAndUpdateWeather metodunu çağır
            await Get.find<WeatherController>().checkLocationAndUpdateWeather();
          } else {
            throw Exception('Konum izni gerekli.');
          }
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Konum izni kalıcı olarak reddedildi');
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
          permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.deniedForever) {
            throw Exception(
                'Konum izni kalıcı olarak reddedildi. Lütfen ayarlardan konum iznini etkinleştirin.');
          }
          // İzin verildiyse, WeatherController'daki checkLocationAndUpdateWeather metodunu çağır
          await Get.find<WeatherController>().checkLocationAndUpdateWeather();
        } else {
          throw Exception('Konum izni gerekli.');
        }
      }

      print('Konum alınıyor...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
      print('Konum alındı: ${position.latitude}, ${position.longitude}');

      return position;
    } catch (e) {
      print('Konum alınırken hata oluştu: $e');
      rethrow;
    }
  }
}

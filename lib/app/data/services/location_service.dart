import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

abstract class ILocationService {
  Future<Position?> getCurrentLocation();
}

abstract class IDialogService {
  Future<bool?> showLocationServiceDialog();
  Future<bool?> showLocationPermissionDialog();
  Future<bool?> showLocationPermissionPermanentlyDeniedDialog();
}

class DialogService implements IDialogService {
  @override
  Future<bool?> showLocationServiceDialog() async {
    return await Get.dialog<bool>(
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
  }

  @override
  Future<bool?> showLocationPermissionDialog() async {
    return await Get.dialog<bool>(
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
  }

  @override
  Future<bool?> showLocationPermissionPermanentlyDeniedDialog() async {
    return await Get.dialog<bool>(
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
  }
}

class LocationService implements ILocationService {
  final IDialogService _dialogService;

  LocationService({
    required IDialogService dialogService,
  }) : _dialogService = dialogService;
  @override
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        bool? openLocationSettings =
            await _dialogService.showLocationServiceDialog();

        if (openLocationSettings == true) {
          await Geolocator.openLocationSettings();
          await Future.delayed(
              Duration(seconds: AppConstants.dialogDelaySeconds));
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            throw Exception(AppConstants.locationServiceDisabledError);
          }
          return await _getPosition();
        } else {
          throw Exception(AppConstants.locationServiceDisabledError);
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          bool? openAppSettings =
              await _dialogService.showLocationPermissionDialog();

          if (openAppSettings == true) {
            await Geolocator.openAppSettings();
            await Future.delayed(
                Duration(seconds: AppConstants.dialogDelaySeconds));
            permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.denied) {
              throw Exception(AppConstants.locationPermissionDeniedError);
            }
            return await _getPosition();
          } else {
            throw Exception(AppConstants.locationPermissionDeniedError);
          }
        }
      }

      if (permission == LocationPermission.deniedForever) {
        bool? openAppSettings = await _dialogService
            .showLocationPermissionPermanentlyDeniedDialog();

        if (openAppSettings == true) {
          await Geolocator.openAppSettings();
          await Future.delayed(
              Duration(seconds: AppConstants.dialogDelaySeconds));
          permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.deniedForever) {
            throw Exception(
                AppConstants.locationPermissionPermanentlyDeniedError);
          }
          return await _getPosition();
        } else {
          throw Exception(AppConstants.locationPermissionDeniedError);
        }
      }

      return await _getPosition();
    } catch (e) {
      rethrow;
    }
  }

  Future<Position> _getPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: AppConstants.locationTimeoutSeconds),
    );
  }
}

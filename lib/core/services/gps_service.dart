import 'package:geolocator/geolocator.dart';

import '../../features/acta_escrutinio/domain/entities/location_entity.dart';

/// Service responsible for acquiring the current GPS coordinates.
class GpsService {
  GpsService._();

  /// Returns the current [LocationEntity].
  ///
  /// Throws a clear exception if location services are disabled or if the
  /// user permanently denied permission.
  static Future<LocationEntity> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('El servicio de ubicación está desactivado.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Permiso de ubicación denegado.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permiso de ubicación denegado permanentemente. Habilítalo desde ajustes.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return LocationEntity(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}

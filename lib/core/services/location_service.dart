import 'package:geolocator/geolocator.dart';

/// Servicio para obtener la ubicación del dispositivo
class LocationService {
  /// Obtiene la ubicación actual del dispositivo
  /// Retorna null si no se pueden obtener los permisos o la ubicación
  static Future<Position?> getCurrentLocation() async {
    try {
      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('LocationService: Location services are disabled');
        return null;
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('LocationService: Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('LocationService: Location permissions are permanently denied');
        return null;
      }

      // Obtener ubicación actual
      print('LocationService: Getting current position...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      print('LocationService: Got position: lat=${position.latitude}, lon=${position.longitude}');
      return position;
    } catch (e) {
      print('LocationService: Error getting location: $e');
      return null;
    }
  }

  /// Obtiene la última ubicación conocida (más rápido pero puede ser antigua)
  static Future<Position?> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        print('LocationService: Got last known position: lat=${position.latitude}, lon=${position.longitude}');
      } else {
        print('LocationService: No last known position available');
      }
      return position;
    } catch (e) {
      print('LocationService: Error getting last known location: $e');
      return null;
    }
  }

  /// Intenta obtener la ubicación actual, y si falla, usa la última conocida
  static Future<Position?> getBestAvailableLocation() async {
    try {
      // Primero intentar la ubicación actual
      final current = await getCurrentLocation();
      if (current != null) {
        return current;
      }

      // Si falla, intentar la última conocida
      print('LocationService: Current location failed, trying last known...');
      return await getLastKnownLocation();
    } catch (e) {
      print('LocationService: Error getting best available location: $e');
      return null;
    }
  }
}

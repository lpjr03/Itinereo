import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:itinereo/exceptions/location_exceptions.dart';

/// A service class that handles retrieving the user's current GPS location.
///
/// This service checks:
/// - If the location services are enabled on the device.
/// - If the app has the necessary permissions to access location data.
///
/// It also throws meaningful, custom exceptions when:
/// - Location services are disabled.
/// - Location permissions are denied.
/// - Location permissions are permanently denied.
///
/// ```
class GeolocatorService {
  /// Retrieves the current GPS position of the device.
  ///
  /// This method:
  /// - Verifies that location services are enabled.
  /// - Checks if permissions are granted; if not, requests them.
  /// - Returns the current position using the highest available accuracy.
  ///
  /// Throws:
  /// - [LocationServicesDisabledException] if location services are turned off.
  /// - [LocationPermissionDeniedException] if the user denies the permission request.
  /// - [LocationPermissionPermanentlyDeniedException] if the user has permanently denied permissions.
  ///
  /// Returns:
  /// - A [Position] object containing the latitude, longitude, and other details.
  ///
  /// Example:
  /// ```dart
  /// final position = await GeolocatorService().getCurrentLocation();
  /// ```
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServicesDisabledException();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationPermissionDeniedException();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionPermanentlyDeniedException();
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );
  }

Future<String> getCityAndCountryFromPosition(Position position) async {
  final lat = position.latitude;
  final lng = position.longitude;
  final apiKey = 'AIzaSyBXDRFaSOLLb5z0peibW6wLRk9zfYNQ_O8';
  final url = Uri.parse(
    'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey',
  );

  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['results'] != null && data['results'].isNotEmpty) {
      String? city;
      String? country;

      for (var result in data['results']) {
        for (var component in result['address_components']) {
          final types = List<String>.from(component['types']);

          if (types.contains('locality')) {
            city ??= component['long_name'];
          } else if (types.contains('sublocality')) {
            city ??= component['long_name'];
          } else if (types.contains('administrative_area_level_3')) {
            city ??= component['long_name'];
          }

          if (types.contains('country')) {
            country ??= component['long_name'];
          }
        }
        if (city != null && country != null) break;
      }

      if (city != null && country != null) return '$city, $country';
      if (country != null) return country;
    }
    return 'Unknown location';
  } else {
    throw Exception('Failed to fetch location: ${response.statusCode}');
  }
}

}

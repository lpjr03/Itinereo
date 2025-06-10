import 'dart:convert';
import 'dart:ui';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:itinereo/exceptions/location_exceptions.dart';
import 'package:itinereo/screens/custom_map_page.dart';

/// A service for handling geolocation and location-based data retrieval.
///
/// This service provides:
/// - Access to the user's current position with permission handling.
/// - Reverse geocoding to get city and country from coordinates.
/// - Integration with the Google Places API to fetch nearby locations
///   and generate a [CustomMapPage] widget with markers.
class GeolocatorService {
  /// Retrieves the user's current GPS position.
  ///
  /// This method:
  /// - Checks whether location services are enabled.
  /// - Verifies and requests permissions if necessary.
  /// - Returns a [Position] with high accuracy.
  ///
  /// Throws:
  /// - [LocationServicesDisabledException] if location services are turned off.
  /// - [LocationPermissionDeniedException] if the user denies the permission request.
  /// - [LocationPermissionPermanentlyDeniedException] if permission is permanently denied.
  ///
  /// Example:
  /// ```dart
  /// final position = await GeolocatorService().getCurrentLocation();
  /// ```
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw LocationServicesDisabledException();

    LocationPermission permission = await Geolocator.checkPermission();
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

  /// Returns a human-readable string containing the city and country
  /// from the provided [Position] using the Google Geocoding API.
  ///
  /// Returns:
  /// - A string in the format `"City, Country"` or `"Country"` if city is not found.
  /// - `"Unknown location"` if the response is invalid or empty.
  ///
  /// Throws:
  /// - A generic [Exception] if the HTTP request fails.
  Future<String> getCityAndCountryFromPosition(Position position) async {
    final lat = position.latitude;
    final lng = position.longitude;
    final apiKey = dotenv.env['API_KEY'];

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch location: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    if (data['results'] == null || data['results'].isEmpty) {
      return 'Unknown location';
    }

    String? city;
    String? country;

    for (var result in data['results']) {
      for (var component in result['address_components']) {
        final types = List<String>.from(component['types']);

        if (types.contains('locality') ||
            types.contains('sublocality') ||
            types.contains('administrative_area_level_3')) {
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
    return 'Unknown location';
  }

  /// Retrieves nearby places from the Google Places API and returns a [CustomMapPage].
  ///
  /// Parameters:
  /// - [position]: User's current GPS position.
  /// - [radius]: Search radius in meters (default: 1500).
  /// - [type]: Optional place type (e.g. `'restaurant'`, `'museum'`).
  /// - [title]: Title to show at the top of the map.
  /// - [onBack]: Callback for the back button on the map page.
  /// - [fallbackPosition]: Used if no places are found; defaults to user's location.
  ///
  /// Returns:
  /// - A [CustomMapPage] containing markers for each nearby place.
  ///
  /// Throws:
  /// - A generic [Exception] if the API call fails or the response status is not OK.
  Future<CustomMapPage> getNearbyPlacesMap({
    required Position position,
    int radius = 50000,
    String? type,
    required String title,
    required VoidCallback? onBack,
    LatLng? fallbackPosition,
  }) async {
    final apiKey = dotenv.env['API_KEY'];
    final lat = position.latitude;
    final lng = position.longitude;

    var url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
      'location=$lat,$lng'
      '&radius=$radius'
      '&type=$type'
      '&keyword=$title'
      '&key=$apiKey',
    );

    if (type != null) {
      url = Uri.parse('$url&type=$type');
    }

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw PlacesApiException('HTTP error: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    if (data['status'] != 'OK') {
      throw PlacesApiException('Places API error: ${data['status']}');
    }

    final markers = <Marker>[];
    int markerId = 0;

    for (var place in data['results']) {
      final placeLat = place['geometry']['location']['lat'];
      final placeLng = place['geometry']['location']['lng'];
      final placeId = place['place_id'];
      final name = place['name'];

      markers.add(
        Marker(
          markerId: MarkerId('place_${markerId++}_$placeId'),
          position: LatLng(placeLat, placeLng),
          infoWindow: InfoWindow(title: name),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    }

    return CustomMapPage(
      title: title,
      markers: markers,
      onBack: onBack,
      fallbackPosition: fallbackPosition ?? LatLng(lat, lng),
    );
  }
}

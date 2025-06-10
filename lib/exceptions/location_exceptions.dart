/// Base class for all location-related exceptions.
class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => 'LocationException: $message';
}

/// Exception thrown when location services are disabled.
class LocationServicesDisabledException extends LocationException {
  LocationServicesDisabledException() : super('Location services are disabled.');
}

/// Exception thrown when location permissions are denied.
class LocationPermissionDeniedException extends LocationException {
  LocationPermissionDeniedException() : super('Location permissions are denied.');
}

/// Exception thrown when location permissions are permanently denied.
class LocationPermissionPermanentlyDeniedException extends LocationException {
  LocationPermissionPermanentlyDeniedException()
      : super('Location permissions are permanently denied.');
}

/// Exception thrown when using Places API by Google Maps.
class PlacesApiException implements Exception {
  final String message;
  PlacesApiException(this.message);

  @override
  String toString() => message;
}

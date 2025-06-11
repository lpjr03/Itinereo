import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A reusable map screen that displays a set of [Marker]s and optionally a polyline.
///
/// This widget is designed for flexible use cases where a set of locations needs
/// to be visualized on a Google Map. It supports an optional route line (polyline),
/// custom markers, and a back button.
///
/// If no markers are provided, it uses [fallbackPosition] or defaults to Rome (41.9028, 12.4964).
class CustomMapPage extends StatelessWidget {
  /// The title of the screen (not currently displayed in the UI).
  final String title;

  /// The list of markers to be shown on the map.
  final List<Marker> markers;

  /// Whether to display a connecting polyline between the markers.
  final bool showPolyline;

  /// Callback triggered when the back button is pressed.
  final VoidCallback? onBack;

  /// Fallback position for the map if no markers are available.
  final LatLng? fallbackPosition;

  /// Constructs a [CustomMapPage] with configurable map elements and behavior.
  ///
  /// [title] and [markers] are required. If [markers] is empty and [fallbackPosition]
  /// is not provided, the map centers on Rome by default.
  const CustomMapPage({
    super.key,
    required this.title,
    required this.markers,
    this.showPolyline = false,
    required this.onBack,
    this.fallbackPosition,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng initialPosition =
        markers.isNotEmpty
            ? markers.first.position
            : (fallbackPosition ?? const LatLng(41.9028, 12.4964));

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 12,
            ),
            markers: Set<Marker>.of(markers),
            polylines:
                showPolyline
                    ? {
                      Polyline(
                        polylineId: const PolylineId('route'),
                        points: markers.map((m) => m.position).toList(),
                        color: Colors.blueAccent,
                        width: 5,
                      ),
                    }
                    : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
          ),

          // Back button in the top-left corner
          Positioned(
            top: 5,
            left: 16,
            child: SafeArea(
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                onPressed: onBack,
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

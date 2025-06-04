import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMapPage extends StatelessWidget {
  final String title;
  final List<Marker> markers;
  final bool showPolyline;
  final VoidCallback? onBack;
  final LatLng? fallbackPosition;

  const CustomMapPage({
    Key? key,
    required this.title,
    required this.markers,
    this.showPolyline = false,
    required this.onBack,
    this.fallbackPosition,
  }) : super(key: key);

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

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:share_plus/share_plus.dart';

// CustomMapPage shows a Google Map with markers, optional polylines, and custom controls
class CustomMapPage extends StatefulWidget {
  final String title; // (Not used in the UI anymore)
  final List<Marker> markers; // List of markers to display on the map
  final bool showPolyline; // Whether to draw a polyline between markers
  final VoidCallback? onBack; // Callback for back button
  final LatLng? fallbackPosition; // Fallback map center if no markers
  final bool showUserLocation; // Whether to show the user’s location

  const CustomMapPage({
    Key? key,
    required this.title,
    required this.markers,
    this.showPolyline = false,
    this.onBack,
    this.fallbackPosition,
    this.showUserLocation = true,
  }) : super(key: key);

  @override
  _CustomMapPageState createState() => _CustomMapPageState();
}

class _CustomMapPageState extends State<CustomMapPage> {
  late GoogleMapController _mapController;
  final Set<Polyline> _polylines = {};
  String? _selectedPlaceId;
  bool _showSatelliteView = false;
  double _mapPaddingBottom = 0;
  final double _infoCardHeight = 120;
  String? _mapStyle; // Custom map style (e.g., dark theme)

  @override
  void initState() {
    super.initState();
    timeDilation = 1.5; // Slow down animations for better UX
    _setupPolylines(); // Prepare polyline if needed
  }

  // Create polyline connecting all markers
  void _setupPolylines() {
    if (widget.showPolyline && widget.markers.length > 1) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: widget.markers.map((m) => m.position).toList(),
          color: Colors.lightBlueAccent,
          width: 5,
          patterns: [PatternItem.dash(15), PatternItem.gap(10)],
        ),
      );
    }
  }

  // Toggle satellite/normal view
  void _toggleMapStyle() {
    setState(() {
      _showSatelliteView = !_showSatelliteView;
    });
  }

  // Build floating map control buttons (top-right)
  Widget _buildMapControls() {
    return Positioned(
      right: 10,
      top: 70,
      child: Column(
        children: [
          _buildControlButton(
            icon: _showSatelliteView ? Icons.map : Icons.satellite,
            onPressed: _toggleMapStyle,
            tooltip: 'Toggle Map Type',
          ),
          const SizedBox(height: 16),
          _buildControlButton(
            icon: Icons.zoom_out_map,
            onPressed: _zoomToFitAllMarkers,
            tooltip: 'Fit Markers',
          ),
          if (_selectedPlaceId != null) ...[
            const SizedBox(height: 16),
            _buildControlButton(
              icon: Icons.share,
              onPressed: () {
                final marker = widget.markers.firstWhere(
                  (m) => m.markerId.value == _selectedPlaceId,
                );
                _shareLocation(marker);
              },
              tooltip: 'Share Location',
            ),
          ],
        ],
      ),
    );
  }

  // Custom reusable square control button
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return Material(
      color: Colors.white70,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Color(0xFF5E9C95),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: Colors.black),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialPosition =
        widget.markers.isNotEmpty
            ? widget.markers.first.position
            : widget.fallbackPosition ??
                const LatLng(41.9028, 12.4964); // Rome by default

    return Scaffold(
      body: Stack(
        children: [
          // Google Map widget
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 12,
            ),
            markers:
                widget.markers.map((marker) {
                  return marker.copyWith(
                    onTapParam: () {
                      setState(() {
                        _selectedPlaceId = marker.markerId.value;
                      });
                    },
                  );
                }).toSet(),
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
              _adjustMapPadding();
            },
            onTap: (_) => setState(() => _selectedPlaceId = null),
            myLocationEnabled: widget.showUserLocation,
            myLocationButtonEnabled: widget.showUserLocation,
            zoomControlsEnabled: false,
            mapType: _showSatelliteView ? MapType.hybrid : MapType.normal,
            style: _mapStyle, // Custom map style applied here
            padding: EdgeInsets.only(bottom: _mapPaddingBottom),
          ),

          // Back button (top-left)
          Positioned(
            top: 10,
            left: 16,
            child: SafeArea(
              child: FloatingActionButton(
                heroTag: 'backBtn',
                mini: true,
                backgroundColor: Colors.white70,
                foregroundColor: Colors.black87,
                onPressed: widget.onBack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.transparent),
                ),
                child: const Icon(Icons.arrow_back, size: 25),
              ),
            ),
          ),

          // Map control buttons
          _buildMapControls(),
        ],
      ),
    );
  }

  // Adjusts map bottom padding and map style when necessary
  void _adjustMapPadding() {
    setState(() {
      _mapPaddingBottom = _selectedPlaceId != null ? _infoCardHeight + 32 : 0;
      _mapStyle = _showSatelliteView ? _getMapStyle('dark') : null;
    });
  }

  // Returns custom JSON style for Google Map (optional)
  String _getMapStyle(String theme) {
    return '''[]'''; // Default = no style
  }

  // Fits all markers into the visible area of the map
  void _zoomToFitAllMarkers() {
    if (widget.markers.isEmpty) return;
    final bounds = _calculateBounds();
    _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  // Calculates LatLngBounds to fit all markers
  LatLngBounds _calculateBounds() {
    var southwest = widget.markers.first.position;
    var northeast = widget.markers.first.position;

    for (var marker in widget.markers) {
      southwest = LatLng(
        southwest.latitude < marker.position.latitude
            ? southwest.latitude
            : marker.position.latitude,
        southwest.longitude < marker.position.longitude
            ? southwest.longitude
            : marker.position.longitude,
      );
      northeast = LatLng(
        northeast.latitude > marker.position.latitude
            ? northeast.latitude
            : marker.position.latitude,
        northeast.longitude > marker.position.longitude
            ? northeast.longitude
            : marker.position.longitude,
      );
    }

    return LatLngBounds(southwest: southwest, northeast: northeast);
  }

  // Shares the selected marker's location using share_plus
  void _shareLocation(Marker marker) {
    final lat = marker.position.latitude;
    final lng = marker.position.longitude;
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    SharePlus.instance.share(
      ShareParams(
        text: 'Check out this place on the map:\n$url',
        subject: marker.infoWindow.title ?? 'Shared location',
      ),
    );
  }
}

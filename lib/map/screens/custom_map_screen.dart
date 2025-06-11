import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:share_plus/share_plus.dart';

/// A customizable page that displays a Google Map with optional markers,
/// polylines, and control buttons for map interactions.
///
/// This widget is suitable for showing a set of locations, optionally
/// connecting them with a route (polyline), sharing a location, and
/// toggling map style.
class CustomMapPage extends StatefulWidget {
  /// Title of the map page (currently unused in UI).
  final String title;

  /// List of markers to display on the map.
  final List<Marker> markers;

  /// Whether to draw a polyline connecting all markers.
  final bool showPolyline;

  /// Callback function triggered when the back button is pressed.
  final VoidCallback? onBack;

  /// Map fallback center position in case the marker list is empty.
  final LatLng? fallbackPosition;

  /// Whether to show the user’s location on the map.
  final bool showUserLocation;

  /// Creates a [CustomMapPage] with configurable map features.
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

/// Internal state of [CustomMapPage], handling map behavior and controls.
class _CustomMapPageState extends State<CustomMapPage> {
  late GoogleMapController _mapController;
  final Set<Polyline> _polylines = {};
  String? _selectedPlaceId;
  bool _showSatelliteView = false;
  double _mapPaddingBottom = 0;
  final double _infoCardHeight = 120;
  String? _mapStyle;

  @override
  void initState() {
    super.initState();
    timeDilation = 1.5; // Slows animations for UX/testing
    _setupPolylines();
  }

  /// Builds a polyline connecting all markers (if enabled).
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

  /// Toggles between normal and satellite map view.
  void _toggleMapStyle() {
    setState(() {
      _showSatelliteView = !_showSatelliteView;
    });
  }

  /// Builds floating control buttons for the map (top-right).
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

  /// Builds a stylized square floating button for map controls.
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
            : widget.fallbackPosition ?? const LatLng(41.9028, 12.4964); // Rome

    return Scaffold(
      body: Stack(
        children: [
          /// Main Google Map widget
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
            style: _mapStyle,
            padding: EdgeInsets.only(bottom: _mapPaddingBottom),
          ),

          /// Floating back button (top-left corner)
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

          /// Control buttons stack
          _buildMapControls(),
        ],
      ),
    );
  }

  /// Adjusts map bottom padding and custom map style based on state.
  void _adjustMapPadding() {
    setState(() {
      _mapPaddingBottom = _selectedPlaceId != null ? _infoCardHeight + 32 : 0;
      _mapStyle = _showSatelliteView ? _getMapStyle('dark') : null;
    });
  }

  /// Returns a JSON string defining the visual style of the map.
  String _getMapStyle(String theme) {
    return '''[]'''; // Default = no custom style
  }

  /// Animates the camera to fit all markers within the visible area.
  void _zoomToFitAllMarkers() {
    if (widget.markers.isEmpty) return;
    final bounds = _calculateBounds();
    _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  /// Calculates a bounding box that includes all markers.
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

  /// Shares the location of the selected marker using a Google Maps link.
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

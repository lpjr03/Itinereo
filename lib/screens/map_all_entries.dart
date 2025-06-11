import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:itinereo/services/local_diary_db.dart';

/// A screen that displays diary entries as markers on a Google Map.
///
/// This screen allows users to:
/// - View all diary entries with geographic coordinates as pins.
/// - Tap on a marker to trigger an optional callback.
/// - Return to the previous screen via a floating back button.
class DiaryMapPage extends StatefulWidget {
  /// Callback triggered when the back button is pressed.
  final VoidCallback? onBack;

  /// Callback triggered when a marker corresponding to an entry is tapped.
  final void Function(String entryId)? onEntrySelected;

  /// Creates the DiaryMapPage with optional [onBack] and [onEntrySelected] handlers.
  const DiaryMapPage({
    Key? key,
    required this.onBack,
    required this.onEntrySelected,
  }) : super(key: key);

  @override
  State<DiaryMapPage> createState() => _DiaryMapPageState();
}

class _DiaryMapPageState extends State<DiaryMapPage> {
  /// Set of markers to display on the map.
  final Set<Marker> _markers = {};

  /// Initial camera position, defaults to Rome if no entries found.
  LatLng _initialPosition = const LatLng(41.9028, 12.4964); // Rome

  /// Whether the map has finished loading entries.
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  /// Loads all diary entries for the current user and creates map markers.
  ///
  /// Only entries with valid latitude and longitude are considered.
  Future<void> _loadMarkers() async {
    final entries = await LocalDiaryDatabase().getAllEntries(
      userId: FirebaseAuth.instance.currentUser!.uid,
    );

    final List<Marker> loadedMarkers = [];

    for (var entry in entries) {
      if (entry.latitude != 0 && entry.longitude != 0) {
        loadedMarkers.add(
          Marker(
            markerId: MarkerId(entry.id),
            position: LatLng(entry.latitude, entry.longitude),
            infoWindow: InfoWindow(title: entry.title),
            onTap: () {
              if (widget.onEntrySelected != null) {
                widget.onEntrySelected!(entry.id);
              }
            },
          ),
        );
      }
    }

    if (loadedMarkers.isNotEmpty) {
      setState(() {
        _markers.addAll(loadedMarkers);
        _initialPosition = LatLng(
          entries.first.latitude,
          entries.first.longitude,
        );
        _isMapReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Main Google Map widget, or loading spinner if not ready.
          _isMapReady
              ? GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 12,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                onMapCreated: (controller) {},
              )
              : const Center(child: CircularProgressIndicator()),

          /// Back button floating on top-left corner.
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
        ],
      ),
    );
  }
}

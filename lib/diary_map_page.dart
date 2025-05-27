import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:itinereo/models/diary_entry.dart';
import 'package:itinereo/services/local_diary_db.dart';

class DiaryMapPage extends StatefulWidget {
  final VoidCallback? onBack;
  const DiaryMapPage({Key? key, required this.onBack}) : super(key: key);

  @override
  State<DiaryMapPage> createState() => _DiaryMapPageState();
}

class _DiaryMapPageState extends State<DiaryMapPage> {
  final Set<Marker> _markers = {};
  LatLng _initialPosition = const LatLng(41.9028, 12.4964); // Roma default
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    final entries = await LocalDiaryDatabase().getAllEntries(userId: FirebaseAuth.instance.currentUser!.uid);

    final List<Marker> loadedMarkers = [];
    for (var entry in entries) {
      if (entry.latitude != 0 && entry.longitude != 0) {
        loadedMarkers.add(
          Marker(
            markerId: MarkerId(entry.id),
            position: LatLng(entry.latitude, entry.longitude),
            infoWindow: InfoWindow(title: entry.title),
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

        Positioned(
          top: 5,
          left: 16,
          child: SafeArea(
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              onPressed: () {
                widget.onBack?.call();
              },
              child: const Icon(Icons.arrow_back),
            ),
          ),
        ),
      ],
    ),
  );
}

}
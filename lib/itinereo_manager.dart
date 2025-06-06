import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:itinereo/models/card_entry.dart';
import 'package:itinereo/screens/add_diary_page.dart';
import 'package:itinereo/screens/camera_screen.dart';
import 'package:itinereo/screens/custom_map_page.dart';
import 'package:itinereo/screens/map_all_entries.dart';
import 'package:itinereo/screens/diary_preview.dart';
import 'package:itinereo/screens/diary_screen.dart';
import 'package:itinereo/screens/get_diary_page.dart';
import 'package:itinereo/screens/home_screen.dart';
import 'package:itinereo/services/local_diary_db.dart';
import 'package:itinereo/widgets/snackbar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// A widget that manages the navigation between different screens
/// of the Itinereo application using state lifting.
///
/// This widget:
/// - Starts with the [HomeScreen] by default.
/// - Switches to [DiaryScreen] when `switchToDiary()` is called.
/// - Switches to [DiaryPreview] when `switchToEntriesPreview()` is called.
/// - Switches to [AddDiaryEntryPage] when `switchToAddDiaryPage()` is called.
/// - Switches to [CameraScreen] when `switchToCameraScreen()` is called.
/// - Switches to [DiaryEntryDetailPage] when `switchToDetailPage()` is called.
/// - Switches to [DiaryMapPage] when `switchToMapPage()` is called.
///
/// The navigation state is lifted up to this parent widget,
/// which controls which screen is currently shown.
///
/// Example usage:
/// ```dart
/// ItinereoManager()
/// ```
class ItinereoManager extends StatefulWidget {
  const ItinereoManager({super.key});

  @override
  State<ItinereoManager> createState() => _ItinereoState();
}

class _ItinereoState extends State<ItinereoManager>
    with WidgetsBindingObserver {
  /// Stores the identifier of the currently active screen.
  String activeScreen = 'home-screen';

  /// A list of photo URLs that are pending to be saved in the diary entry.
  List<String> _pendingPhotoUrls = [];

  /// The identifier of the diary entry currently selected for detail view.
  String? _selectedEntryId;

  // Cached itineraries generated once the app starts.
  Future<List<List<Marker>>>? _cachedItineraries;

  bool _hasStoragePermission = false;

  Future<List<DiaryCard>> _latestDiaryCards = Future.value([]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStoragePermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkStoragePermission();
    }
  }

  Future<void> _checkStoragePermission() async {
    final status = await Permission.photos.status;
    setState(() {
      _hasStoragePermission = status.isGranted;
    });
  }

  Future<List<DiaryCard>> _refreshDiaryCards() {
    final future = LocalDiaryDatabase().getDiaryCardsFromLocalDb(
      userId: FirebaseAuth.instance.currentUser!.uid,
      limit: 10,
      offset: 0,
    );

    _latestDiaryCards = future;
    return future;
  }

  /// Handles taps on the bottom navigation bar.
  void handleBottomNavTap(int index) {
    if (index == 0) {
      switchToMapPage();
    } else if (index == 1) {
      switchToHome();
    } else if (index == 2) {
      switchToEntriesPreview();
    }
  }

  /// Switches the active screen to the home screen.
  void switchToHome() => setState(() => activeScreen = 'home-screen');

  /// Switches the active screen to the diary screen.
  void switchToDiary() => setState(() => activeScreen = 'diary-screen');

  /// Switches the active screen to the diary entries preview screen.
  void switchToEntriesPreview() =>
      setState(() => activeScreen = 'preview-screen');

  /// Switches the active screen to the add diary page screen.
  void switchToAddDiaryPage() =>
      setState(() => activeScreen = 'add-diary-page-screen');

  /// Switches the active screen to the camera screen.
  void switchToCameraScreen() => setState(() => activeScreen = 'camera-screen');

  /// Switches the active screen to the detail page of a diary entry.
  void switchToDetailPage(String entryId) => setState(() {
    _selectedEntryId = entryId;
    activeScreen = 'detail-page';
  });

  /// Switches the active screen to the map page screen.
  void switchToMapPage() => setState(() => activeScreen = 'map-page-screen');

  /// Method to update the cached itineraries.
  void updateCachedItineraries(Future<List<List<Marker>>> itinerariesFuture) {
    _cachedItineraries = itinerariesFuture;
  }

  List<Marker> _customMapMarkers = [];
  String _customMapTitle = '';
  bool _showPolyline = false;

  void switchToCustomMap({
    required List<Marker> markers,
    required String title,
    bool polyline = false,
  }) {
    setState(() {
      _customMapMarkers = markers;
      _customMapTitle = title;
      _showPolyline = polyline;
      activeScreen = 'custom-map-screen';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Selects the widget to display based on the active screen.
    Widget screenWidget = HomeScreen(
      switchScreen: switchToDiary,
      cachedItineraries: _cachedItineraries,
      setCachedItineraries: updateCachedItineraries,
      switchToCustomMap: (markers, title, {polyline = false}) {
        switchToCustomMap(markers: markers, title: title, polyline: polyline);
      },
      switchToDetailPage: switchToDetailPage,
      hasStoragePermission: _hasStoragePermission,
    );

    if (activeScreen == 'diary-screen') {
      screenWidget = DiaryScreen(
        switchToPreview: switchToEntriesPreview,
        switchToAddDiaryPage: switchToAddDiaryPage,
        switchToMapPage: () async {
          final hasConnection = await hasInternetConnection();

          if (!hasConnection) {
            ItinereoSnackBar.show(
              context,
              'No internet connection. Please connect and try again.',
            );
            return;
          }

          _refreshDiaryCards().then((cards) {
            if (cards.isEmpty) {
              ItinereoSnackBar.show(
                context,
                'No precise locations found in your diary.',
              );
            } else {
              switchToMapPage();
            }
          });
        },
      );
    } else if (activeScreen == 'preview-screen') {
      screenWidget = DiaryPreview(
        onViewPage: switchToDetailPage,
        onBack: switchToDiary,
        onBottomTap: handleBottomNavTap,
      );
    } else if (activeScreen == 'add-diary-page-screen') {
      screenWidget = AddDiaryEntryPage(
        onSave: () {
          _pendingPhotoUrls.clear();
          setState(() {
            switchToEntriesPreview();
          });
        },
        switchToCameraScreen: switchToCameraScreen,
        switchToDiaryScreen: () {
          _pendingPhotoUrls.clear();
          switchToDiary();
        },
        initialPhotoUrls: _pendingPhotoUrls,
        deletePhoto: (photoUrl) {
          setState(() {
            _pendingPhotoUrls.remove(photoUrl);
            activeScreen = 'add-diary-page-screen';
          });
        },
      );
    } else if (activeScreen == 'camera-screen') {
      screenWidget = CameraScreen(
        onBack: switchToAddDiaryPage,
        onPhotoCaptured: (photoUrl) {
          setState(() {
            _pendingPhotoUrls.add(photoUrl);
            activeScreen = 'add-diary-page-screen';
          });
        },
        saveToGallery: false,
      );
    } else if (activeScreen == 'detail-page') {
      screenWidget = DiaryEntryDetailPage(entryId: _selectedEntryId!);
    } else if (activeScreen == 'map-page-screen') {
      screenWidget = DiaryMapPage(
        onBack: switchToDiary,
        onEntrySelected: switchToDetailPage,
      );
    } else if (activeScreen == 'custom-map-screen') {
      screenWidget = CustomMapPage(
        title: _customMapTitle,
        markers: _customMapMarkers,
        showPolyline: _showPolyline,
        onBack: switchToHome,
      );
    }

    return MaterialApp(
      title: "Itinerèo",
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: [Colors.white, Color.fromARGB(255, 22, 60, 118)],
              ),
            ),
            child: screenWidget,
          ),
        ),
      ),
    );
  }

  Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}

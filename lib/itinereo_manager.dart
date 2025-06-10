import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:itinereo/models/card_entry.dart';
import 'package:itinereo/screens/add_diary_page.dart';
import 'package:itinereo/screens/camera_screen.dart';
import 'package:itinereo/screens/custom_map_page.dart';
import 'package:itinereo/screens/explore_screen.dart';
import 'package:itinereo/screens/map_all_entries.dart';
import 'package:itinereo/screens/diary_preview.dart';
import 'package:itinereo/screens/diary_screen.dart';
import 'package:itinereo/screens/get_diary_page.dart';
import 'package:itinereo/screens/home_screen.dart';
import 'package:itinereo/services/diary_service.dart';
import 'package:itinereo/services/google_service.dart';
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
  Future<List<Map<String, dynamic>>>? _cachedItineraries;

  bool _hasStoragePermission = false;

  int _lastEntryCount = -1;

  Future<List<DiaryCard>> _latestDiaryCards = Future.value([]);

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  bool _isAiGenerated = false;

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

  void _clearFormFields() {
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _dateController.clear();
    _isAiGenerated = false;
  }

  /// Handles taps on the bottom navigation bar.
  void handleBottomNavTap(int index) {
    if (index == 0) {
      switchToExplore();
    } else if (index == 1) {
      switchToHome();
    } else if (index == 2) {
      switchToEntriesPreview();
    }
  }

  /// Switches the active screen to the home screen.
  void switchToHome() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final entries = await LocalDiaryDatabase().getAllEntries(userId: userId);
    final currentCount = entries.length;

    if (currentCount != _lastEntryCount) {
      final newItineraries =
          currentCount == 0
              ? null
              : GoogleService.generateItinerariesFromEntries(entries);

      if (newItineraries == null) {
        _cachedItineraries = Future.value([]);
      } else {
        updateCachedItineraries(newItineraries);
        _lastEntryCount = currentCount;
      }
    }

    setState(() => activeScreen = 'home-screen');
  }

  /// Switches the active screen to the diary screen.
  void switchToDiary() => setState(() => activeScreen = 'diary-screen');

  /// Switches the active screen to the diary entries preview screen.
  void switchToEntriesPreview() =>
      setState(() => activeScreen = 'preview-screen');

  /// Switches the active screen to the add diary page screen.
  void switchToAddDiaryPage() =>
      setState(() => activeScreen = 'add-diary-page-screen');

  /// Switches the active screen to the explore screen.
  void switchToExplore() => setState(() => activeScreen = 'explore-screen');

  /// Switches the active screen to the camera screen.
  void switchToCameraScreen() => setState(() => activeScreen = 'camera-screen');

  /// Switches the active screen to the detail page of a diary entry.
  void switchToDetailPage(String entryId) => setState(() {
    _selectedEntryId = entryId;
    activeScreen = 'detail-page';
  });

  /// Switches the active screen to the map page screen.
  void switchToMapPage() async {
    final hasConnection = await hasInternetAccess();

    if (!hasConnection) {
      ItinereoSnackBar.show(
        context,
        'No internet connection. Please connect and try again.',
      );
      return;
    }

    final cards = await _refreshDiaryCards();

    if (cards.isEmpty) {
      ItinereoSnackBar.show(context, 'No diary entries found.');
      return;
    }

    final entries = await Future.wait(
      cards.map((card) => DiaryService.instance.getEntryById(card.id)),
    );

    final hasValidLocation = entries.any(
      (entry) => entry!.latitude != 0.0 && entry.longitude != 0.0,
    );

    if (!hasValidLocation) {
      ItinereoSnackBar.show(
        context,
        'No precise locations found in your diary.',
      );
      return;
    }

    setState(() => activeScreen = 'map-page-screen');
  }

  /// Method to update the cached itineraries.
  void updateCachedItineraries(
    Future<List<Map<String, dynamic>>> itinerariesFuture,
  ) {
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

  Future<List<DiaryCard>> _refreshDiaryCards() {
    final future = LocalDiaryDatabase().getDiaryCardsFromLocalDb(
      userId: FirebaseAuth.instance.currentUser!.uid,
      limit: 10,
      offset: 0,
    );

    _latestDiaryCards = future;
    return future;
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
      onBottomTap: handleBottomNavTap,
    );

    if (activeScreen == 'diary-screen') {
      screenWidget = DiaryScreen(
        switchToPreview: switchToEntriesPreview,
        switchToAddDiaryPage: switchToAddDiaryPage,
        switchToMapPage: switchToMapPage,
        switchToHome: switchToHome,
      );
    } else if (activeScreen == 'preview-screen') {
      screenWidget = DiaryPreview(
        onViewPage: switchToDetailPage,
        onBack: switchToDiary,
        onBottomTap: handleBottomNavTap,
        permission: _hasStoragePermission,
      );
    } else if (activeScreen == 'add-diary-page-screen') {
      screenWidget = AddDiaryEntryPage(
        onSave: () {
          _pendingPhotoUrls.clear();
          setState(() {
            switchToEntriesPreview();
          });
          _clearFormFields();
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
        titleController: _titleController,
        descriptionController: _descriptionController,
        locationController: _locationController,
        dateController: _dateController,
        isAiGenerated: _isAiGenerated,
        onAiGeneratedChanged: (value) {
          setState(() => _isAiGenerated = value);
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
      screenWidget = DiaryEntryDetailPage(
        entryId: _selectedEntryId!,
        onBack: switchToEntriesPreview,
      );
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
    } else if (activeScreen == 'explore-screen') {
      screenWidget = ExploreScreen(
        switchScreen: switchToHome,
        switchToDiary: switchToDiary,
        onBottomTap: handleBottomNavTap,
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

  Future<bool> hasInternetAccess() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    try {
      final result = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      return result.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

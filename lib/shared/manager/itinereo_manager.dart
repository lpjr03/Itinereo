import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:itinereo/models/diary_card.dart';
import 'package:itinereo/diary/screens/add_entry_screen.dart';
import 'package:itinereo/diary/screens/camera_screen.dart';
import 'package:itinereo/map/screens/custom_map_screen.dart';
import 'package:itinereo/explore/screens/explore_screen.dart';
import 'package:itinereo/diary/screens/map_entries_screen.dart';
import 'package:itinereo/diary/screens/diary_preview.dart';
import 'package:itinereo/diary/screens/diary_screen.dart';
import 'package:itinereo/diary/screens/get_entry_screen.dart';
import 'package:itinereo/home_page/screens/home_screen.dart';
import 'package:itinereo/services/diary_service.dart';
import 'package:itinereo/services/google_service.dart';
import 'package:itinereo/services/local_storage_service.dart';
import 'package:itinereo/shared/widgets/snackbar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// The main app controller and router after login.
///
/// This widget uses lifted state to manage navigation between the main
/// features of the Itinereo app, such as:
/// - Home
/// - Diary
/// - Camera
/// - Add Entry
/// - Preview entries
/// - Maps (standard and custom)
/// - Explore
///
/// It also handles app lifecycle observation, cached itineraries, and
/// permission checking.
class ItinereoManager extends StatefulWidget {
  /// Creates the [ItinereoManager].
  const ItinereoManager({super.key});

  @override
  State<ItinereoManager> createState() => _ItinereoState();
}

class _ItinereoState extends State<ItinereoManager>
    with WidgetsBindingObserver {
  /// Identifier for the current active screen.
  String activeScreen = 'home-screen';

  /// URLs of photos selected for a new diary entry (unsaved).
  List<String> _pendingPhotoUrls = [];

  /// ID of the diary entry selected for detail view.
  String? _selectedEntryId;

  /// Cached itineraries shown in the HomeScreen.
  Future<List<Map<String, dynamic>>>? _cachedItineraries;

  /// True if the app has photo storage permission.
  bool _hasStoragePermission = false;

  /// Last known number of diary entries (for cache invalidation).
  int _lastEntryCount = -1;

  // Form controllers for AddDiaryEntryPage.
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

  /// Checks the current permission to access device photos.
  Future<void> _checkStoragePermission() async {
    final status = await Permission.photos.status;
    setState(() {
      _hasStoragePermission = status.isGranted;
    });
  }

  /// Clears the form fields for a new diary entry.
  void _clearFormFields() {
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _dateController.clear();
    _isAiGenerated = false;
  }

  /// Handles taps on the bottom navigation bar and routes accordingly.
  void handleBottomNavTap(int index) {
    if (index == 0) {
      switchToExplore();
    } else if (index == 1) {
      switchToHome();
    } else if (index == 2) {
      switchToDiary();
    }
  }

  /// Switches to the home screen and refreshes itineraries if needed.
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

  /// Switches to the diary screen.
  void switchToDiary() => setState(() => activeScreen = 'diary-screen');

  /// Switches to the diary entries preview screen.
  void switchToEntriesPreview() =>
      setState(() => activeScreen = 'preview-screen');

  /// Switches to the add diary entry screen.
  void switchToAddDiaryPage() =>
      setState(() => activeScreen = 'add-diary-page-screen');

  /// Switches to the explore screen.
  void switchToExplore() => setState(() => activeScreen = 'explore-screen');

  /// Switches to the camera screen.
  void switchToCameraScreen() => setState(() => activeScreen = 'camera-screen');

  /// Switches to the diary entry detail screen.
  void switchToDetailPage(String entryId) => setState(() {
    _selectedEntryId = entryId;
    activeScreen = 'detail-page';
  });

  /// Switches to the diary map screen (entries with coordinates).
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

  /// Updates the cached itineraries in memory.
  void updateCachedItineraries(
    Future<List<Map<String, dynamic>>> itinerariesFuture,
  ) {
    _cachedItineraries = itinerariesFuture;
  }

  // State for custom map screen.
  List<Marker> _customMapMarkers = [];
  String _customMapTitle = '';
  bool _showPolyline = false;

  /// Switches to a custom map screen with given markers and title.
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

  /// Retrieves the latest diary cards from the local database.
  Future<List<DiaryCard>> _refreshDiaryCards() {
    final future = LocalDiaryDatabase().getDiaryCardsFromLocalDb(
      userId: FirebaseAuth.instance.currentUser!.uid,
      limit: 10,
      offset: 0,
    );
    return future;
  }

  @override
  Widget build(BuildContext context) {
    /// Selects the screen to display based on `activeScreen`.
    Widget screenWidget = HomeScreen(
      cachedItineraries: _cachedItineraries,
      setCachedItineraries: updateCachedItineraries,
      switchToCustomMap: (markers, title, {polyline = false}) {
        switchToCustomMap(markers: markers, title: title, polyline: polyline);
      },
      switchToDetailPage: switchToDetailPage,
      onBottomTap: handleBottomNavTap,
    );

    switch (activeScreen) {
      case 'diary-screen':
        screenWidget = DiaryScreen(
          switchToPreview: switchToEntriesPreview,
          switchToAddDiaryPage: switchToAddDiaryPage,
          switchToMapPage: switchToMapPage,
          switchToHome: switchToHome,
        );
        break;

      case 'preview-screen':
        screenWidget = DiaryPreview(
          onViewPage: switchToDetailPage,
          onBack: switchToDiary,
          onBottomTap: handleBottomNavTap,
        );
        break;

      case 'add-diary-page-screen':
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
        break;

      case 'camera-screen':
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
        break;

      case 'detail-page':
        screenWidget = DiaryEntryDetailPage(
          entryId: _selectedEntryId!,
          onBack: switchToEntriesPreview,
        );
        break;

      case 'map-page-screen':
        screenWidget = DiaryMapPage(
          onBack: switchToDiary,
          onEntrySelected: switchToDetailPage,
        );
        break;

      case 'custom-map-screen':
        screenWidget = CustomMapPage(
          title: _customMapTitle,
          markers: _customMapMarkers,
          showPolyline: _showPolyline,
          onBack: switchToHome,
        );
        break;

      case 'explore-screen':
        screenWidget = ExploreScreen(onBottomTap: handleBottomNavTap);
        break;
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

  /// Checks whether the device has an active internet connection.
  Future<bool> hasInternetAccess() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return false;

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

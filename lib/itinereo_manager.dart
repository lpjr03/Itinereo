import 'package:flutter/material.dart';
import 'package:itinereo/screens/add_diary_page.dart';
import 'package:itinereo/screens/camera_screen.dart';
import 'package:itinereo/screens/diary_map_page.dart';
import 'package:itinereo/screens/diary_preview.dart';
import 'package:itinereo/screens/diary_screen.dart';
import 'package:itinereo/screens/get_diary_page.dart';
import 'package:itinereo/screens/home_screen.dart';

/// A widget that manages the navigation between different screens
/// of the Itinereo application using state lifting.
///
/// This widget:
/// - Starts with the [HomeScreen] by default.
/// - Switches to [DiaryScreen] when `switchToDiary()` is called.
/// - Switches to [DiaryPreview] when `switchToEntriesPreview()` is called.
///
/// The navigation state is lifted up to this parent widget,
/// which controls which screen is currently shown.
///
/// Example usage:
/// ```dart
/// ItinereoManager()
/// ```
class ItinereoManager extends StatefulWidget {
  /// Creates an [ItinereoManager] widget.
  const ItinereoManager({super.key});

  @override
  State<ItinereoManager> createState() => _ItinereoState();
}

class _ItinereoState extends State<ItinereoManager> {
  /// Stores the identifier of the currently active screen.
  var activeScreen = 'home-screen';
  List<String> _pendingPhotoUrls = [];
  String? _selectedEntryId;

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
  void switchToHome() {
    setState(() {
      activeScreen = 'home-screen';
    });
  }

  /// Switches the active screen to the diary screen.
  void switchToDiary() {
    setState(() {
      activeScreen = 'diary-screen';
    });
  }

  /// Switches the active screen to the diary entries preview screen.
  void switchToEntriesPreview() {
    setState(() {
      activeScreen = 'preview-screen';
    });
  }

  /// Switches the active screen to the add diary page screen.
  void switchToAddDiaryPage() {
    setState(() {
      activeScreen = 'add-diary-page-screen';
    });
  }

  /// Switches the active screen to the camera screen.
  void switchToCameraScreen() async {
    setState(() {
      activeScreen = 'camera-screen';
    });
  }

  /// Switches the active screen to the detail page of a diary entry.
  void switchToDetailPage(String entryId) {
    setState(() {
      _selectedEntryId = entryId;
      activeScreen = 'detail-page';
    });
  }

  void switchToMapPage() async {
    setState(() {
      activeScreen = 'map-page-screen';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Selects the widget to display based on the active screen.
    Widget screenWidget = HomeScreen(switchToDiary);
    if (activeScreen == 'diary-screen') {
      screenWidget = DiaryScreen(
        switchToPreview: switchToEntriesPreview,
        switchToAddDiaryPage: switchToAddDiaryPage,
        switchToMapPage: switchToMapPage,
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
          switchToEntriesPreview();
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
      screenWidget = DiaryMapPage(onBack: switchToDiary);
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
}

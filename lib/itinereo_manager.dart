import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:itinereo/add_diary_page.dart';
import 'package:itinereo/camera_screen.dart';
import 'package:itinereo/diary_preview.dart';
import 'package:itinereo/diary_screen.dart';
import 'package:itinereo/home_screen.dart';

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
  CameraDescription? selectedCamera;
  List<String> _pendingPhotoUrls = [];

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
    final cameras = await availableCameras();
    setState(() {
      selectedCamera = cameras.first;
      activeScreen = 'camera-screen';
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
      );
    } else if (activeScreen == 'preview-screen') {
      screenWidget = const DiaryPreview();
    } else if (activeScreen == 'add-diary-page-screen') {
      screenWidget = AddDiaryEntryPage(
        onSave: switchToEntriesPreview,
        switchToCameraScreen: switchToCameraScreen,
        initialPhotoUrls: _pendingPhotoUrls,
      );
    } else if (activeScreen == 'camera-screen') {
      screenWidget = CameraScreen(
        camera: selectedCamera,
        onBack: switchToAddDiaryPage,
        onPhotoCaptured: (photoUrl) {
          setState(() {
            _pendingPhotoUrls.add(photoUrl);
            activeScreen = 'add-diary-page-screen';
          });
        },
      );
    }

    return MaterialApp(
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

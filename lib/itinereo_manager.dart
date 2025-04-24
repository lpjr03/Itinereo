import 'package:flutter/material.dart';
import 'package:itinereo/diary_preview.dart';
import 'package:itinereo/diary_screen.dart';
import 'package:itinereo/home_screen.dart';

class ItinereoManager extends StatefulWidget {
  const ItinereoManager({super.key});

  @override
  State<ItinereoManager> createState() => _ItinereoState();
}

class _ItinereoState extends State<ItinereoManager> {
  var activeScreen = 'home-screen';

  void switchToDiary() {
    setState(() {
      activeScreen = 'diary-screen';
    });
  }

  void switchToEntriesPreview() {
    setState(() {
      activeScreen = 'preview-screen';
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget screenWidget = HomeScreen(switchToDiary);
    if (activeScreen == 'diary-screen') {
      screenWidget = DiaryScreen(switchToEntriesPreview);
    }else if (activeScreen == 'preview-screen') {
      screenWidget = DiaryPreview();
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

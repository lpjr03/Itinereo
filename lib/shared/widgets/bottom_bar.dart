import 'package:flutter/material.dart';

/// A custom bottom navigation bar used in the Itinereo app.
///
/// Displays three fixed icons: Explore, Home, and Diary.
/// - Custom color scheme consistent with the Itinereo visual identity.
/// - Callback triggered on index tap allows parent widget to handle navigation.
/// ```
class ItinereoBottomBar extends StatelessWidget {
  /// Index of the currently selected navigation item.
  final int currentIndex;

  /// Callback triggered when an item is tapped.
  /// Provides the tapped index as parameter.
  final Function(int)? onTap;

  /// Creates an [ItinereoBottomBar] with the given current index and tap handler.
  const ItinereoBottomBar({super.key, required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Color(0xFFF6E1C4),
      elevation: 0,
      selectedItemColor: Color(0xFF385A55),
      unselectedItemColor: Color(0xFF385A55),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: currentIndex,
      onTap: onTap,
      iconSize: 30,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_rounded),
          label: 'Explore',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Diary'),
      ],
    );
  }
}

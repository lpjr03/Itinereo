import 'package:flutter/material.dart';

class ItinereoBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const ItinereoBottomBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

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

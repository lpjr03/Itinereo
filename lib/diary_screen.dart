import 'package:flutter/material.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen(this.switchScreen, {super.key});

  final Function() switchScreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Contenuto principale della schermata
          Expanded(
            child: Center(
              child: Text('Contenuto diario', style: TextStyle(fontSize: 24)),
            ),
          ),
          const VerticalDivider(width: 1),
          // NavigationRail sulla destra
          NavigationRail(
            selectedIndex: 0, // o una variabile se vuoi renderlo dinamico
            onDestinationSelected: (int index) {
              if (index == 1) {
                switchScreen();
              }
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.travel_explore_outlined),
                selectedIcon: Icon(Icons.travel_explore),
                label: Text('Map'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.create_outlined),
                selectedIcon: Icon(Icons.create_rounded),
                label: Text('Journal'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

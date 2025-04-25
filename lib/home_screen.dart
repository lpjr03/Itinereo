import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen(this.switchScreen, {super.key});

  final Function() switchScreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.transparent, // importante per non coprire il gradient
      appBar: AppBar(title: const Text("Itinereo")),
      body: const Center(child: Text("HomescreenPage")),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'Explore',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Diary'),
        ],
        selectedItemColor: Colors.amber[800],
        onTap: (index) {
          if (index == 2) {
            switchScreen();
          }
        },
      ),
    );
  }
}


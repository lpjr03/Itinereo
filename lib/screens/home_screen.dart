import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:itinereo/services/google_service.dart';
import 'package:itinereo/services/local_diary_db.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.switchScreen,
    required this.cachedItineraries,
    required this.setCachedItineraries,
    required this.switchToCustomMap,
  });

  final Function() switchScreen;
  final Function(List<Marker> markers, String title, {bool polyline})
  switchToCustomMap;
  final Future<List<List<Marker>>>? cachedItineraries;
  final void Function(Future<List<List<Marker>>>) setCachedItineraries;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<List<Marker>>> itineraries;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    if (widget.cachedItineraries != null) {
      itineraries = widget.cachedItineraries!;
    } else {
      itineraries = _loadItineraries();
      widget.setCachedItineraries(itineraries);
    }
  }

  Future<List<List<Marker>>> _loadItineraries() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final entries = await LocalDiaryDatabase().getRecentDiaryEntries(
      userId: userId,
    );

    if (entries.isEmpty) throw Exception("Nessuna entry trovata.");
    return await GoogleService.generateItinerariesFromEntries(entries);
  }

  void refreshItineraries() {
    final newItineraries = _loadItineraries();
    setState(() {
      itineraries = newItineraries;
      widget.setCachedItineraries(newItineraries);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Itinereo"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Rigenera itinerari",
            onPressed: refreshItineraries,
          ),
        ],
      ),
      body: FutureBuilder<List<List<Marker>>>(
        future: itineraries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nessun itinerario trovato.'));
          }

          final itinerariesData = snapshot.data!;

          return ListView.builder(
            itemCount: itinerariesData.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.all(12),
                color: const Color(0xFFF6ECD4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    'Itinerary ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  trailing: const Icon(Icons.map, color: Color(0xFF385A55)),
                  onTap: () {
                    widget.switchToCustomMap(
                      itinerariesData[index],
                      'Itinerary ${index + 1}',
                      polyline: true,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'Explore',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Diary'),
        ],
        selectedItemColor: Colors.amber[800],
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 2) widget.switchScreen();
        },
      ),
    );
  }
}

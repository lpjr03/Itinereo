import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import 'diary_service.dart';

class DiaryEntryDetailPage extends StatelessWidget {
  final String entryId;

  const DiaryEntryDetailPage({super.key, required this.entryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dettagli Voce Diario')),
      body: FutureBuilder<DiaryEntry?>(
        future: DiaryService().getEntryById(entryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          final entry = snapshot.data;
          if (entry == null) {
            return const Center(child: Text('Voce non trovata.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(entry.title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(entry.date.toLocal().toString(), style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 16),
                Text(entry.description),
                const SizedBox(height: 16),
                Text("Coordinate: ${entry.latitude}, ${entry.longitude}"),
                const SizedBox(height: 16),
                if (entry.photoUrls.isNotEmpty) ...[
                  const Text("Foto:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: entry.photoUrls.map((url) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Image.network(url),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import 'diary_service.dart';

class AllDiaryEntriesPage extends StatefulWidget {
  const AllDiaryEntriesPage({super.key});

  @override
  State<AllDiaryEntriesPage> createState() => _AllDiaryEntriesPageState();
}

class _AllDiaryEntriesPageState extends State<AllDiaryEntriesPage> {
  late Future<List<DiaryEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = DiaryService().getEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutte le Note')),
      body: FutureBuilder<List<DiaryEntry>>(
        future: _entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Errore: ${snapshot.error}'),
            );
          }

          final entries = snapshot.data ?? [];

          if (entries.isEmpty) {
            return const Center(child: Text('Nessuna voce trovata.'));
          }

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return ListTile(
                title: Text(entry.title),
                subtitle: Text(entry.date.toIso8601String()),
                onTap: () {
                  // Puoi navigare a una schermata dettagliata qui
                },
              );
            },
          );
        },
      ),
    );
  }
}

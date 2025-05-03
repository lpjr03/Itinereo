import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/diary_entry.dart';
import 'diary_service.dart';

class AddDiaryEntryPage extends StatefulWidget {
  const AddDiaryEntryPage({super.key});

  @override
  State<AddDiaryEntryPage> createState() => _AddDiaryEntryPageState();
}

class _AddDiaryEntryPageState extends State<AddDiaryEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _photoUrlController = TextEditingController();
  double _latitude = 0.0;
  double _longitude = 0.0;

  bool _isSubmitting = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final newEntry = DiaryEntry(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      date: DateTime.now(),
      latitude: _latitude,
      longitude: _longitude,
      photoUrls: _photoUrlController.text
          .split(',')
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .toList(),
    );

    try {
      await DiaryService().addEntry(newEntry);
      if (context.mounted) {
        Navigator.pop(context); // Torna indietro dopo l'aggiunta
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante il salvataggio: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuovo Diario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titolo'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obbligatorio' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrizione'),
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Salva'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
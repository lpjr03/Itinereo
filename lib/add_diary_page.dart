import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinereo/services/geolocator_service.dart';
import 'package:uuid/uuid.dart';
import '../models/diary_entry.dart';
import 'services/diary_service.dart';

class AddDiaryEntryPage extends StatefulWidget {
  final void Function()? onSave;
  final void Function()? switchToCameraScreen;

   const AddDiaryEntryPage({
    super.key,
    required this.onSave,
    required this.switchToCameraScreen,
  });

  @override
  State<AddDiaryEntryPage> createState() => _AddDiaryEntryPageState();
}

class _AddDiaryEntryPageState extends State<AddDiaryEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _photoUrlController = TextEditingController();

  bool _isSubmitting = false;
  double _latitude = 0.0;
  double _longitude = 0.0;

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
      photoUrls:
          _photoUrlController.text
              .split(',')
              .map((url) => url.trim())
              .where((url) => url.isNotEmpty)
              .toList(),
    );

    try {
      await DiaryService().addEntry(newEntry);
      if (context.mounted) Navigator.pop(context);
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
      backgroundColor: Color(0xFFBBBEBF),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.centerLeft,
              height: MediaQuery.of(context).size.height,
              color: Color(0xFF649991),
              child: Container(
                padding: EdgeInsets.all(16),

                color: Color(0xFFF6E1C4),

                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.deliciousHandrawn(
                          textStyle: const TextStyle(
                            height: 2,
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E5355),
                          ),
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          hintText: 'Title',
                          hintStyle: GoogleFonts.deliciousHandrawn(
                            textStyle: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E5355),
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9EDD2),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFD8CCB1),
                              width: 9,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFD8CCB1),
                              width: 9,
                            ),
                          ),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Inserisci un titolo'
                                    : null,
                      ),

                      Container(
                        padding: EdgeInsets.all(20),
                        margin: EdgeInsets.symmetric(vertical: 5),
                        alignment: Alignment.center,

                        decoration: BoxDecoration(
                          color: Color(0xFFFFEED2),
                          border: Border.all(
                            color: Color(0xFFFFF9EA),
                            width: 20,
                          ),
                        ),
                        child: Center(
                          child: IconButton(
                            icon: Icon(Icons.add_a_photo),
                            color: Color(0xFF2E5355),
                            iconSize: 120,
                            onPressed: () {
                              widget.switchToCameraScreen!();
                            },
                            splashRadius: 1,
                          ),
                        ),
                      ),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: DateField()),

                          const SizedBox(width: 12),

                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _handleMapButtonPressed(context);
                              },
                              icon: const Icon(
                                Icons.location_on,
                                size: 18,
                                color: Color(0xFF2E5355),
                              ),
                              label: const Text(
                                'Find me',
                                style: TextStyle(
                                  color: Color(0xFF2E5355),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE8A951),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: Color(0xFFA75119),
                                    width: 2,
                                  ),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),

                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF6ECD4),
                          hintText: 'Location',
                          hintStyle: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2E5355),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD8CCB1),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD8CCB1),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: 'Write your story...',
                          hintStyle: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF2E5355),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF6ECD4),
                          contentPadding: const EdgeInsets.fromLTRB(
                            12,
                            16,
                            12,
                            40,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD8CCB1),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD8CCB1),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            //@todo
                          },
                          icon: const Icon(
                            Icons.auto_fix_high,
                            size: 20,
                            color: Color(0xFF2E5355),
                          ),
                          label: const Text(
                            'AI Writer',
                            style: TextStyle(
                              color: Color(0xFF2E5355),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFBEE2F5),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                color: Color(0xFF3194B4),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          _submit();
                          if (widget.onSave != null) widget.onSave!();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF385A55,
                          ), // verde scuro
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Salva',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Raleway',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
void _handleMapButtonPressed(BuildContext context) async {
  try {
    final position = await GeolocatorService().getCurrentLocation();
    final String location = await GeolocatorService().getCityAndCountryFromPosition(position);

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _locationController.text = location;
    });

  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }
}

}

class DateField extends StatefulWidget {
  const DateField({super.key});

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(DateTime.now());
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = _formatDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      onTap: _pickDate,
      style: const TextStyle(fontStyle: FontStyle.italic),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF6ECD4),
        hintText: 'Select date',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFD8CCB1), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFD8CCB1), width: 2),
        ),
      ),
    );
  }

}

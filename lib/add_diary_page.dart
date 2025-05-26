import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinereo/services/geolocator_service.dart';
import 'package:itinereo/services/google_service.dart';
import 'package:itinereo/services/local_diary_db.dart';
import 'package:itinereo/widgets/alert_widget.dart';
import 'package:itinereo/widgets/loading_dialog.dart';
import 'package:uuid/uuid.dart';
import '../models/diary_entry.dart';
import 'services/diary_service.dart';

class AddDiaryEntryPage extends StatefulWidget {
  final void Function()? onSave;
  final void Function()? switchToCameraScreen;

  final List<String> initialPhotoUrls;

  const AddDiaryEntryPage({
    Key? key,
    required this.onSave,
    required this.switchToCameraScreen,
    this.initialPhotoUrls = const [],
  }) : super(key: key);

  @override
  State<AddDiaryEntryPage> createState() => _AddDiaryEntryPageState();
}

class _AddDiaryEntryPageState extends State<AddDiaryEntryPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentIndex = 0;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  late List<String> _photoUrls = [];
  final PageController _pageController = PageController(viewportFraction: 0.95);

  bool _isSubmitting = false;
  double _latitude = 0.0;
  double _longitude = 0.0;

  @override
  void initState() {
    super.initState();
    _photoUrls = List<String>.from(widget.initialPhotoUrls);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
      photoUrls: _photoUrls,
    );

    try {
      await DiaryService().addEntry(newEntry);
      await LocalDiaryDatabase().insertEntry(newEntry);
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
                        maxLines: 2,
                        inputFormatters: [LengthLimitingTextInputFormatter(38)],
                        style: GoogleFonts.deliciousHandrawn(
                          textStyle: const TextStyle(
                            height: 1.3,
                            fontSize: 30,
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
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E5355),
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9EDD2),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: const BorderSide(
                              color: Color(0xFFD8CCB1),
                              width: 9,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: const BorderSide(
                              color: Color(0xFFD8CCB1),
                              width: 9,
                            ),
                          ),
                        ),
                      ),

                      CarouselSlider(
                        options: CarouselOptions(
                          height: 180,
                          enableInfiniteScroll: false,
                          viewportFraction: 1.0,
                          enlargeCenterPage: true,
                          scrollPhysics: const BouncingScrollPhysics(),
                        ),
                        items: List.generate(
                          _photoUrls.length < 5 ? _photoUrls.length + 1 : 5,
                          (index) {
                            final isAddCard =
                                index == _photoUrls.length &&
                                _photoUrls.length < 5;

                            if (isAddCard) {
                              return GestureDetector(
                                onTap: () {
                                  widget.switchToCameraScreen?.call();
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF2D8),
                                    border: Border.all(
                                      color: const Color(0xFFD8CCB1),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.add_a_photo,
                                      size: 48,
                                      color: Color(0xFF2E5355),
                                    ),
                                  ),
                                ),
                              );
                            }

                            final photoUrl = _photoUrls[index];
                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (_) => Dialog(
                                            backgroundColor: Colors.black,
                                            insetPadding: const EdgeInsets.all(
                                              16,
                                            ),
                                            child: InteractiveViewer(
                                              child: Image.file(
                                                File(photoUrl),
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: FileImage(File(photoUrl)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _photoUrls.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DateField(dateController: _dateController),
                          ),
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
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

                      const SizedBox(height: 12),
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
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Write your story...',
                          hintStyle: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2E5355),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF6ECD4),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
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
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_titleController.text.isEmpty ||
                                _photoUrls.isEmpty ||
                                _locationController.text.isEmpty ||
                                _dateController.text.isEmpty ||
                                _descriptionController.text.isNotEmpty) {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => const ErrorDialog(
                                      message:
                                          "Please fill every field except for the description.",
                                    ),
                              );
                            } else {
                              _callAiWriter(
                                context,
                                _titleController.text,
                                _photoUrls,
                                DateTime.now(),
                                _latitude,
                                _longitude,
                                _locationController.text,
                              );
                            }
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
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (_titleController.text.isEmpty ||
                              _photoUrls.isEmpty ||
                              _locationController.text.isEmpty ||
                              _dateController.text.isEmpty) {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => const ErrorDialog(
                                    message:
                                        "Please fill all fields before saving.",
                                  ),
                            );
                          } else {
                            _submit();
                            if (widget.onSave != null) widget.onSave!();
                          }
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
  showLoadingDialog(context, "Where in the world are you? Almost there...");
  try {
    final position = await GeolocatorService().getCurrentLocation();
    final location = await GeolocatorService().getCityAndCountryFromPosition(position);

    Navigator.of(context, rootNavigator: true).pop(); // chiudi il dialog

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _locationController.text = location;
    });
  } catch (e) {
    Navigator.of(context, rootNavigator: true).pop(); // chiudi in ogni caso

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Errore: ${e.toString()}")),
    );
  }
}


void _callAiWriter(
  BuildContext context,
  String title,
  List<String> photoUrls,
  DateTime date,
  latitude,
  double longitude,
  String optionalLocation
) async {
  showLoadingDialog(context, "Give it a sec, AI's on deck!");
String location='';
if(latitude != 0.0 && longitude != 0.0) {
    // Crea un oggetto Position con le coordinate fornite
Position position = Position(latitude: latitude, longitude: longitude, timestamp: DateTime.now() , accuracy: 0, altitude: 0, speed: 0, speedAccuracy: 0, heading: 0, altitudeAccuracy: 0, headingAccuracy: 0);

    try {
      location = await GeolocatorService().getCityAndCountryFromPosition(position);
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore nel recupero della posizione: ${e.toString()}")),
      );
      return;
  }
} else {
location = optionalLocation;
  if (location.isEmpty) {
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Errore: posizione non valida.")),
    );
    return;
  }
}
  try {
    String response = await GoogleService.generateDescriptionFromEntry(
      DiaryEntry(
        id: '',
        title: title,
        description: '',
        date: date,
        latitude: latitude,
        longitude: longitude,
        photoUrls: photoUrls,
      ),
    location,
    );

    Navigator.of(context, rootNavigator: true).pop();

    setState(() {
      _descriptionController.text = response;
    });
  } catch (e) {
    Navigator.of(context, rootNavigator: true).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Errore: ${e.toString()}")),
    );
  }
}
}

class DateField extends StatefulWidget {
  final TextEditingController dateController;
  const DateField({super.key, required this.dateController});

  @override
  State<DateField> createState() =>
      _DateFieldState(dateController: dateController);
}

class _DateFieldState extends State<DateField> {
  final TextEditingController dateController;

  _DateFieldState({required this.dateController});
  @override
  void initState() {
    super.initState();
    dateController.text = _formatDate(DateTime.now());
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
        dateController.text = _formatDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: dateController,
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

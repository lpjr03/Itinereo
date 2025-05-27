import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinereo/services/geolocator_service.dart';
import 'package:itinereo/services/google_service.dart';
import 'package:itinereo/services/local_diary_db.dart';
import 'package:itinereo/widgets/alert_widget.dart';
import 'package:itinereo/widgets/custom_input_field.dart';
import 'package:itinereo/widgets/date_field.dart';
import 'package:itinereo/widgets/diary_action_button.dart';
import 'package:itinereo/widgets/diary_add_carousel.dart';
import 'package:itinereo/widgets/loading_dialog.dart';
import 'package:itinereo/widgets/snackbar.dart';
import 'package:uuid/uuid.dart';
import '../../models/diary_entry.dart';
import '../services/diary_service.dart';

class AddDiaryEntryPage extends StatefulWidget {
  final void Function()? onSave;
  final void Function()? switchToCameraScreen;

  final List<String> initialPhotoUrls;

  const AddDiaryEntryPage({
    super.key,
    required this.onSave,
    required this.switchToCameraScreen,
    this.initialPhotoUrls = const [],
  });

  @override
  State<AddDiaryEntryPage> createState() => _AddDiaryEntryPageState();
}

class _AddDiaryEntryPageState extends State<AddDiaryEntryPage> {
  final _formKey = GlobalKey<FormState>();
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
      await LocalDiaryDatabase().insertEntry(
        newEntry,
        FirebaseAuth.instance.currentUser!.uid,
      );
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isSubmitting = false);
      ItinereoSnackBar.show(context, "Error saving entry: ${e.toString()}");
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextFormField(
                        controller: _titleController,
                        hintText: 'Title',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        inputFormatters: [LengthLimitingTextInputFormatter(38)],
                        textStyle: GoogleFonts.libreBaskerville(
                          textStyle: const TextStyle(
                            height: 2,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E5355),
                          ),
                        ),
                        hintStyle: GoogleFonts.libreBaskerville(
                          textStyle: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w400, 
                            color: Color(0xFF2E5355),
                          ),
                        ).copyWith(
                          color: const Color.fromARGB(255, 84, 124, 126),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFD8CCB1),
                            width: 9,
                          ),
                        ),
                      ),

                      DiaryPhotoCarousel(
                        photoUrls: widget.initialPhotoUrls,
                        onAddPhoto: () => widget.switchToCameraScreen?.call(),
                        onRemovePhoto: (index) {
                          setState(() {
                            _photoUrls.removeAt(index);
                          });
                        },
                      ),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DateField(dateController: _dateController),
                          ),
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: DiaryActionButton(
                              onPressed: () => _handleMapButtonPressed(context),
                              icon: Icons.location_on,
                              iconColor: Color(0xFFC97F4F),
                              backgroundColor: Color(0xFFEAB054),
                              borderColor: Color(0xFFC97F4F),
                              label: 'Find me', textColor: Color(0xFF373737),
                            ),
                          ),
                        ],
                      ),

                      CustomTextFormField(
                        controller: _locationController,
                        hintText: 'Location',
                        hintStyle: GoogleFonts.playpenSans(
                          textStyle: TextStyle(
                            fontSize: 21,
                            height: 28 / 21,
                            letterSpacing: -0.04 * 21,
                            color: Color(0xFF4D4C48),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        fillColor: const Color(0xFFF6ECD4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFD8CCB1),
                            width: 2,
                          ),
                        ),
                      ),

                      CustomTextFormField(
                        controller: _descriptionController,
                        hintText: 'Write your story...',
                        multiline: true,
                        hintStyle: GoogleFonts.playpenSans(
                          textStyle: TextStyle(
                            fontSize: 21,
                            height: 28 / 21,
                            letterSpacing: -0.04 * 21,
                            color: Color(0xFF4D4C48),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        fillColor: const Color(0xFFF6ECD4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFD8CCB1),
                            width: 2,
                          ),
                        ),
                      ),

                      Align(
                        alignment: Alignment.bottomRight,
                        child: DiaryActionButton(
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
                          icon: Icons.auto_fix_high,
                          label: 'AI Writer',
                          backgroundColor: const Color(0xFFBEE2F5),
                          borderColor: const Color(0xFF3194B4), iconColor: Color(0xFF4F90C8), textColor: Color(0xFF373737),
                        ),
                      ),

                     Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 12,
                              bottom: 12,
                            ),
                            child: ElevatedButton(
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
                                backgroundColor: const Color(0xFF2E5355),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Salva',
                                style: GoogleFonts.playpenSans(
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
      final location = await GeolocatorService().getCityAndCountryFromPosition(
        position,
      );

      Navigator.of(context, rootNavigator: true).pop();

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationController.text = location;
      });
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ItinereoSnackBar.show(
        context,
        "Error retrieving location: ${e.toString()}",
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
    String optionalLocation,
  ) async {
    showLoadingDialog(context, "Give it a sec, AI's on deck!");
    String location = '';
    if (latitude != 0.0 && longitude != 0.0) {
      Position position = Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        speed: 0,
        speedAccuracy: 0,
        heading: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      try {
        location = await GeolocatorService().getCityAndCountryFromPosition(
          position,
        );
      } catch (e) {
        Navigator.of(context, rootNavigator: true).pop();
        ItinereoSnackBar.show(
          context,
          "Error retrieving location: ${e.toString()}",
        );
        return;
      }
    } else {
      location = optionalLocation;
      if (location.isEmpty) {
        Navigator.of(context, rootNavigator: true).pop();
        ItinereoSnackBar.show(
          context,
          "Error retrieving location: please provide a valid location.",
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

      ItinereoSnackBar.show(
        context,
        "Error generating description: ${e.toString()}",
      );
    }
  }
}

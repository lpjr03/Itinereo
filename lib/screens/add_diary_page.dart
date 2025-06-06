import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinereo/screens/camera_screen.dart';
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
import 'package:itinereo/widgets/text_widget.dart';
import 'package:uuid/uuid.dart';
import '../../models/diary_entry.dart';
import '../services/diary_service.dart';

class AddDiaryEntryPage extends StatefulWidget {
  final void Function()? onSave;
  final void Function()? switchToCameraScreen;
  final void Function()? switchToDiaryScreen;
  final void Function(String photoPath)? deletePhoto;

  final List<String> initialPhotoUrls;

  const AddDiaryEntryPage({
    super.key,
    required this.onSave,
    required this.switchToCameraScreen,
    required this.switchToDiaryScreen,
    required this.deletePhoto,
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
  bool _isAiGenerated = false;
  String _previousLocationValue = '';

  bool _isSubmitting = false;
  double _latitude = 0.0;
  double _longitude = 0.0;

  @override
  void initState() {
    super.initState();
    _previousLocationValue = _locationController.text;
    _photoUrls = List<String>.from(widget.initialPhotoUrls);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    List<String> finalGalleryPaths = [];

    for (String tempPath in _photoUrls) {
      final tempFile = File(tempPath);
      final savedFile = await saveToGalleryManually(tempFile);
      finalGalleryPaths.add(savedFile.path);
    }

    final newEntry = DiaryEntry(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      date: DateTime.now(),
      latitude: _latitude,
      longitude: _longitude,
      location: _locationController.text,
      photoUrls: finalGalleryPaths,
    );

    try {
      await DiaryService().addEntry(newEntry);
      await LocalDiaryDatabase().insertEntry(
        newEntry,
        FirebaseAuth.instance.currentUser!.uid,
        _locationController.text,
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
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFFBBBEBF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF649991),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: const Color(0xFFF6E1C4),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextFormField(
                            controller: _titleController,
                            hintText: 'Title',
                            textAlign: TextAlign.center,
                            multiline: true,
                            minLines: 1,
                            maxLines: 2,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                            ],
                            textStyle: GoogleFonts.libreBaskerville(
                              textStyle: const TextStyle(
                                height: 1.5,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E5355),
                              ),
                            ),
                            hintStyle: GoogleFonts.playpenSans(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF2E5355),
                              ),
                            ).copyWith(
                              color: const Color.fromARGB(255, 84, 124, 126),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFFD8CCB1),
                                width: 2,
                              ),
                            ),
                          ),
                          DiaryPhotoCarousel(
                            photoUrls: _photoUrls,
                            onAddPhoto:
                                () => widget.switchToCameraScreen?.call(),
                            onRemovePhoto: (photoPath) {
                              _photoUrls.remove(photoPath);
                              widget.deletePhoto?.call(photoPath);
                            },
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: DateField(
                                  dateController: _dateController,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: DiaryActionButton(
                                  onPressed:
                                      () => _handleMapButtonPressed(context),
                                  icon: Icons.location_on,
                                  iconColor: Color(0xFFC97F4F),
                                  backgroundColor: Color(0xFFEAB054),
                                  borderColor: Color(0xFFC97F4F),
                                  label: 'Find me',
                                  textColor: Color(0xFF373737),
                                ),
                              ),
                            ],
                          ),
                          CustomTextFormField(
                            controller: _locationController,
                            hintText: 'Location',
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                            ],
                            onChanged: (value) async {
                              if (_isAiGenerated) {
                                final shouldClear =
                                    await _showConfirmClearDialog();

                                if (shouldClear) {
                                  setState(() {
                                    _descriptionController.clear();
                                    _isAiGenerated = false;
                                    _previousLocationValue = value;
                                  });
                                } else {
                                  _locationController.value = TextEditingValue(
                                    text: _previousLocationValue,
                                    selection: TextSelection.collapsed(
                                      offset: _previousLocationValue.length,
                                    ),
                                  );
                                }
                              } else {
                                _previousLocationValue = value;
                              }
                            },

                            hintStyle: GoogleFonts.playpenSans(
                              textStyle: TextStyle(
                                fontSize: 18,
                                height: 21 / 18,
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
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1500),
                            ],
                            multiline: true,
                            minLines: 5,
                            maxLines: 5,
                            hintStyle: GoogleFonts.playpenSans(
                              textStyle: TextStyle(
                                fontSize: 18,
                                height: 21 / 18,
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
                                    _dateController.text.isEmpty) {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => const ErrorDialog(
                                          message:
                                              "Please fill every field before using AI Writer. Only description is optional.",
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
                                    _descriptionController.text,
                                  );
                                }
                              },
                              icon: Icons.auto_fix_high,
                              label: 'AI Writer',
                              backgroundColor: const Color(0xFFBEE2F5),
                              borderColor: const Color(0xFF3194B4),
                              iconColor: Color(0xFF4F90C8),
                              textColor: Color(0xFF373737),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      if (widget.onSave != null)
                                        widget.onSave!();
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
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 12,
                                  bottom: 12,
                                ),
                                child: OutlinedButton(
                                  onPressed: () {
                                    final hasChanges =
                                        _titleController.text.isNotEmpty ||
                                        _photoUrls.isNotEmpty ||
                                        _locationController.text.isNotEmpty ||
                                        _descriptionController.text.isNotEmpty;

                                    if (hasChanges) {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => ErrorDialog(
                                              title: 'Annullare modifiche?',
                                              message:
                                                  'Sei sicuro di voler annullare le modifiche? Tutto il contenuto non salvato andrà perso.',
                                              showCancelButton: true,
                                              cancelButtonText: 'No, resta',
                                              okButtonText: 'Sì, annulla',
                                              onOk: () {
                                                widget.switchToDiaryScreen
                                                    ?.call();
                                              },
                                            ),
                                      );
                                    } else {
                                      widget.switchToDiaryScreen?.call();
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF2E5355),
                                    side: const BorderSide(
                                      color: Color(0xFF2E5355),
                                      width: 2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'Annulla',
                                    style: GoogleFonts.playpenSans(
                                      textStyle: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2E5355),
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
            );
          },
        ),
      ),
    );
  }

  void _handleMapButtonPressed(BuildContext context) async {
    if (_isAiGenerated) {
      bool shouldClear = false;

      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: const Color(0xFFF3E2C7),
              title: TextWidget(
                title: 'Attenzione!',
                txtSize: 24.0,
                txtColor: const Color(0xFF20535B),
              ),
              content: TextWidget(
                title:
                    'Hai già generato una descrizione con l’AI.\nVuoi cancellarla per rigenerarla con la nuova posizione?',
                txtSize: 18.0,
                txtColor: const Color(0xFF20535B),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    shouldClear = true;
                    Navigator.of(context).pop();
                  },
                  child: TextWidget(
                    title: "Sì",
                    txtSize: 16.0,
                    txtColor: const Color(0xFF20535B),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    shouldClear = false;
                    Navigator.of(context).pop();
                  },
                  child: TextWidget(
                    title: "No",
                    txtSize: 16.0,
                    txtColor: const Color(0xFF20535B),
                  ),
                ),
              ],
            ),
      );

      if (!shouldClear) return;

      setState(() {
        _descriptionController.clear();
        _isAiGenerated = false;
      });
    }

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
    String textDescription,
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
          description: textDescription,
          date: date,
          latitude: latitude,
          location: location,
          longitude: longitude,
          photoUrls: photoUrls,
        ),
        location,
      );

      Navigator.of(context, rootNavigator: true).pop();

      setState(() {
        _descriptionController.text = response;
        _isAiGenerated = true;
      });
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();

      ItinereoSnackBar.show(
        context,
        "Error generating description: ${e.toString()}",
      );
    }
  }

  Future<bool> _showConfirmClearDialog() async {
    bool shouldClear = false;
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFFF3E2C7),
            title: TextWidget(
              title: 'Aggiornare descrizione AI?',
              txtSize: 24.0,
              txtColor: const Color(0xFF20535B),
            ),
            content: TextWidget(
              title:
                  'Hai già generato una descrizione con l’AI.\nVuoi cancellarla per rigenerarla con la nuova posizione?',
              txtSize: 18.0,
              txtColor: const Color(0xFF20535B),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  shouldClear = true;
                  Navigator.of(context).pop();
                },
                child: TextWidget(
                  title: "Sì",
                  txtSize: 16.0,
                  txtColor: const Color(0xFF20535B),
                ),
              ),
              TextButton(
                onPressed: () {
                  shouldClear = false;
                  Navigator.of(context).pop();
                },
                child: TextWidget(
                  title: "No",
                  txtSize: 16.0,
                  txtColor: const Color(0xFF20535B),
                ),
              ),
            ],
          ),
    );

    return shouldClear;
  }
}

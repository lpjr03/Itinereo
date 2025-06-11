import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinereo/diary/screens/camera_screen.dart';
import 'package:itinereo/services/location_service.dart';
import 'package:itinereo/services/google_service.dart';
import 'package:itinereo/services/local_storage_service.dart';
import 'package:itinereo/diary/widgets/action_card.dart';
import 'package:itinereo/shared/widgets/alert.dart';
import 'package:itinereo/diary/widgets/input_field.dart';
import 'package:itinereo/diary/widgets/date_field.dart';
import 'package:itinereo/diary/widgets/diary_action_button.dart';
import 'package:itinereo/shared/widgets/loading_dialog.dart';
import 'package:itinereo/diary/widgets/photo_carousel.dart';
import 'package:itinereo/shared/widgets/snackbar.dart';
import 'package:itinereo/shared/widgets/text.dart';
import 'package:uuid/uuid.dart';
import '../../../models/diary_entry.dart';
import '../../services/diary_service.dart';

/// A screen that allows users to add a new diary entry to their travel journal.
///
/// Users can input a title, description, date, and location, as well as
/// attach up to five photos. The screen supports geolocation and provides
/// an AI-assisted writer to help generate descriptions.
///
/// The entry is saved both to Firestore (via [DiaryService]) and to the
/// local SQLite database (via [LocalDiaryDatabase]).
class AddDiaryEntryPage extends StatefulWidget {
  /// Callback executed after a successful save.
  final void Function()? onSave;

  /// Callback to switch to the camera screen.
  final void Function()? switchToCameraScreen;

  /// Callback to return to the diary screen.
  final void Function()? switchToDiaryScreen;

  /// Callback to delete a specific photo.
  final void Function(String photoPath)? deletePhoto;

  /// Controller for the title input field.
  final TextEditingController titleController;

  /// Controller for the description input field.
  final TextEditingController descriptionController;

  /// Controller for the location input field.
  final TextEditingController locationController;

  /// Controller for the date input field.
  final TextEditingController dateController;

  /// Whether the description was generated using AI.
  bool isAiGenerated;

  /// Called when the AI-generated state is toggled.
  final void Function(bool)? onAiGeneratedChanged;

  /// List of image paths to prepopulate the photo carousel.
  final List<String> initialPhotoUrls;

  /// Creates a page to add a new diary entry.
  AddDiaryEntryPage({
    super.key,
    required this.onSave,
    required this.switchToCameraScreen,
    required this.switchToDiaryScreen,
    required this.deletePhoto,
    required this.titleController,
    required this.descriptionController,
    required this.locationController,
    required this.dateController,
    required this.isAiGenerated,
    required this.onAiGeneratedChanged,
    this.initialPhotoUrls = const [],
  });

  @override
  State<AddDiaryEntryPage> createState() => _AddDiaryEntryPageState();
}

class _AddDiaryEntryPageState extends State<AddDiaryEntryPage> {
  /// Form key used to validate and save form input.
  final _formKey = GlobalKey<FormState>();

  /// List of photo paths selected by the user.
  late List<String> _photoUrls = [];

  /// Caches the location text before user edits it.
  String _previousLocationValue = '';

  /// Whether the form is currently being submitted.
  bool _isSubmitting = false;

  /// Geolocation coordinates.
  double _latitude = 0.0;
  double _longitude = 0.0;

  @override
  void initState() {
    super.initState();
    _previousLocationValue = widget.locationController.text;
    _photoUrls = List<String>.from(widget.initialPhotoUrls);
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Validates and saves the new diary entry to both Firebase and local storage.
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
      title: widget.titleController.text.trim(),
      description: widget.descriptionController.text.trim(),
      date: DateTime.now(),
      latitude: _latitude,
      longitude: _longitude,
      location: widget.locationController.text,
      photoUrls: finalGalleryPaths,
    );

    try {
      await DiaryService().addEntry(newEntry);
      await LocalDiaryDatabase().insertEntry(
        newEntry,
        FirebaseAuth.instance.currentUser!.uid,
        widget.locationController.text,
      );
      if (context.mounted) {
        widget.onSave?.call();
      }
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
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF649991),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6E1C4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          /// Title input field for the diary entry.
                          CustomTextFormField(
                            controller: widget.titleController,
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
                          PhotoCarousel(
                            photoUrls: _photoUrls,
                            controller: PageController(),
                            caption:
                                _photoUrls.isEmpty
                                    ? null
                                    : '${_photoUrls.length}/5 photos taken',
                            actionCard: ActionCard(
                              onPressed:
                                  () => widget.switchToCameraScreen?.call(),
                            ),
                          ),

                          /// Row containing the date picker and the location button.
                          Row(
                            children: [
                              /// Date input field for the diary entry.
                              Expanded(
                                child: DateField(
                                  dateController: widget.dateController,
                                ),
                              ),
                              const SizedBox(width: 12),

                              /// Button to automatically retrieve and fill the current location.
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

                          /// Location input field with logic to clear AI-generated description if edited.
                          CustomTextFormField(
                            controller: widget.locationController,
                            hintText: 'Location',
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                            ],
                            onChanged: (value) async {
                              if (widget.isAiGenerated) {
                                final shouldClear =
                                    await _showConfirmClearDialog();

                                if (shouldClear) {
                                  setState(() {
                                    widget.descriptionController.clear();
                                    widget.isAiGenerated = false;
                                    _previousLocationValue = value;
                                  });
                                } else {
                                  widget
                                      .locationController
                                      .value = TextEditingValue(
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

                          /// Description input field (optional, can be generated by AI).
                          CustomTextFormField(
                            controller: widget.descriptionController,
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

                          /// Button to generate the description using an AI model.
                          Align(
                            alignment: Alignment.bottomRight,
                            child: DiaryActionButton(
                              onPressed: () {
                                if (widget.titleController.text.isEmpty ||
                                    _photoUrls.isEmpty ||
                                    widget.locationController.text.isEmpty ||
                                    widget.dateController.text.isEmpty) {
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
                                    widget.titleController.text,
                                    _photoUrls,
                                    DateTime.now(),
                                    _latitude,
                                    _longitude,
                                    widget.locationController.text,
                                    widget.descriptionController.text,
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

                          /// Row with 'Save' and 'Cancel' buttons for the entry.
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// Save button to validate and submit the diary entry.
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 12,
                                  bottom: 12,
                                ),
                                child: ElevatedButton(
                                  onPressed:
                                      _isSubmitting
                                          ? null
                                          : () {
                                            if (widget
                                                    .titleController
                                                    .text
                                                    .isEmpty ||
                                                _photoUrls.isEmpty ||
                                                widget
                                                    .locationController
                                                    .text
                                                    .isEmpty ||
                                                widget
                                                    .dateController
                                                    .text
                                                    .isEmpty) {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (
                                                      context,
                                                    ) => const ErrorDialog(
                                                      message:
                                                          "Please fill all fields before saving.",
                                                    ),
                                              );
                                            } else {
                                              _submit();
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
                                    'Save',
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

                              /// Cancel button to discard changes and go back to diary.
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 12,
                                  bottom: 12,
                                ),
                                child: OutlinedButton(
                                  onPressed: () {
                                    final hasChanges =
                                        widget
                                            .titleController
                                            .text
                                            .isNotEmpty ||
                                        _photoUrls.isNotEmpty ||
                                        widget
                                            .locationController
                                            .text
                                            .isNotEmpty ||
                                        widget
                                            .descriptionController
                                            .text
                                            .isNotEmpty;

                                    if (hasChanges) {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => ErrorDialog(
                                              title: 'Discard changes?',
                                              message:
                                                  'Are you sure you want to discard your changes? All unsaved content will be lost.',
                                              showCancelButton: true,
                                              cancelButtonText: 'No, stay',
                                              okButtonText: 'Yes, discard',
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
                                    'Cancel',
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

  /// Handles the logic for the 'Find me' button.
  ///
  /// Retrieves the current geolocation using [GeolocatorService] and updates
  /// the location field. If a description was previously generated with AI,
  /// the user is prompted to confirm clearing it.
  void _handleMapButtonPressed(BuildContext context) async {
    if (widget.isAiGenerated) {
      bool shouldClear = false;

      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: const Color(0xFFF3E2C7),
              title: TextWidget(
                title: 'Wait!',
                txtSize: 24.0,
                txtColor: const Color(0xFF20535B),
              ),
              content: TextWidget(
                title:
                    'You have already generated a description with AI.\nDo you want to delete it and regenerate it using the new location?',
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
                    title: "Yes",
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
        widget.descriptionController.clear();
        widget.isAiGenerated = false;
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
        widget.locationController.text = location;
      });
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ItinereoSnackBar.show(
        context,
        "Error retrieving location: ${e.toString()}",
      );
    }
  }

  /// Sends the user's input (title, location, date, and photo URLs) to the
  /// [GoogleService] to generate an AI-assisted description.
  ///
  /// Displays a loading dialog while processing. If the AI returns a result,
  /// the description is set in the appropriate controller, and the
  /// [isAiGenerated] flag is updated. Handles location resolution errors.
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
        widget.descriptionController.text = response;
        widget.isAiGenerated = true;
      });
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();

      ItinereoSnackBar.show(
        context,
        "Error generating description: ${e.toString()}",
      );
    }
  }

  /// Displays a confirmation dialog when the user changes the location
  /// after an AI-generated description has already been generated.
  ///
  /// Returns `true` if the user confirms the intention to clear the
  /// description, otherwise `false`.
  Future<bool> _showConfirmClearDialog() async {
    bool shouldClear = false;
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFFF3E2C7),
            title: TextWidget(
              title: 'Update AI description?',
              txtSize: 24.0,
              txtColor: const Color(0xFF20535B),
            ),
            content: TextWidget(
              title:
                  'You have already generated a description with AI.\nDo you want to delete it and regenerate it using the new location?',
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
                  title: "Yes",
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

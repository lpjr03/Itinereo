import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itinereo/widgets/snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:itinereo/widgets/text_widget.dart';
import 'package:permission_handler/permission_handler.dart';

/// A screen that prompts the user to pick an image from the camera or gallery,
/// and optionally saves it to the device gallery or app cache.
///
/// Once an image is captured or selected, the [onPhotoCaptured] callback is triggered.
class CameraScreen extends StatefulWidget {
  /// Callback triggered when the user presses the back button.
  final VoidCallback? onBack;

  /// Callback triggered after an image is successfully captured or selected.
  /// Returns the local path of the saved image.
  final void Function(String photoPath)? onPhotoCaptured;

  /// Whether to save the image to the gallery (`true`) or to the app's cache (`false`).
  final bool saveToGallery;

  /// Constructs a [CameraScreen].
  const CameraScreen({
    super.key,
    required this.onBack,
    this.saveToGallery = true,
    this.onPhotoCaptured,
  });

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late final File savedPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Show the dialog to pick an image source after build completes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showImageSourceDialog();
    });
  }

  /// Shows a dialog for the user to choose between camera and gallery.
  Future<void> _showImageSourceDialog() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFFF3E2C7),
            title: TextWidget(
              title: "Select the image source:",
              txtSize: 20.0,
              txtColor: const Color(0xFF20535B),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, ImageSource.camera),
                child: TextWidget(
                  title: "Camera",
                  txtSize: 16.0,
                  txtColor: const Color(0xFF20535B),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, ImageSource.gallery),
                child: TextWidget(
                  title: "Gallery",
                  txtSize: 16.0,
                  txtColor: const Color(0xFF20535B),
                ),
              ),
            ],
          ),
    );

    // If the user cancels the dialog, trigger the back callback.
    if (source != null) {
      _pickImage(source);
    } else {
      widget.onBack?.call();
    }
  }

  /// Picks an image using the provided [source] (camera or gallery),
  /// saves it either to the gallery or the app cache, and triggers the callback.
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) {
        widget.onBack?.call();
        return;
      }

      final imageFile = File(pickedFile.path);
      File saved;

      // Save image depending on user's preference
      if (widget.saveToGallery) {
        saved = await saveToGalleryManually(imageFile);
      } else {
        saved = await saveToAppCache(imageFile);
      }

      // Notify parent widget
      widget.onPhotoCaptured?.call(saved.path);

      // Close the screen
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ItinereoSnackBar.show(context, "Unexpected error. Please try again.");
        widget.onBack?.call();
      }
    }
  }

  /// Displays a loading indicator while image selection is in progress.
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// Saves [imageFile] to the public gallery folder `/Pictures/Itinereo`.
///
/// Requests the appropriate permission depending on Android SDK version.
/// Throws an [Exception] if permission is denied.
Future<File> saveToGalleryManually(File imageFile) async {
  final androidInfo = await DeviceInfoPlugin().androidInfo;
  final sdkInt = androidInfo.version.sdkInt;
  late final File savedPath;

  final status =
      sdkInt >= 33
          ? await Permission.photos.request()
          : await Permission.storage.request();

  if (!status.isGranted) throw Exception("Permission denied to save photos.");

  final dir = Directory('/storage/emulated/0/Pictures/Itinereo');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  final fileName = 'itinereo_${DateTime.now().millisecondsSinceEpoch}.jpg';
  savedPath = File('${dir.path}/$fileName');
  await imageFile.copy(savedPath.path);
  return savedPath;
}

/// Saves [imageFile] to the app's temporary directory.
///
/// This file is not persistent and may be deleted by the OS.
Future<File> saveToAppCache(File imageFile) async {
  final dir = await getTemporaryDirectory();
  final fileName = 'itinereo_temp${DateTime.now().millisecondsSinceEpoch}.jpg';
  final savedPath = File('${dir.path}/$fileName');
  await imageFile.copy(savedPath.path);
  return savedPath;
}

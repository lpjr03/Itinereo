import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itinereo/widgets/snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:itinereo/widgets/text_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final void Function(String photoPath)? onPhotoCaptured;
  final bool saveToGallery;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showImageSourceDialog();
    });
  }

  Future<void> _showImageSourceDialog() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFFF3E2C7),
            title: TextWidget(
              title: "Seleziona la fonte dell'immagine: ",
              txtSize: 20.0,
              txtColor: const Color(0xFF20535B),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, ImageSource.camera),
                child: TextWidget(
                  title: "Fotocamera",
                  txtSize: 16.0,
                  txtColor: const Color(0xFF20535B),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, ImageSource.gallery),
                child: TextWidget(
                  title: "Galleria",
                  txtSize: 16.0,
                  txtColor: const Color(0xFF20535B),
                ),
              ),
            ],
          ),
    );
    if (source != null) {
      _pickImage(source);
    } else {
      widget.onBack?.call();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
      );
      if (pickedFile == null) {
        widget.onBack?.call();
        return;
      }

      final imageFile = File(pickedFile.path);
      File saved;

      if (widget.saveToGallery) {
        saved = await saveToGalleryManually(imageFile);
      } else {
        saved = await saveToAppCache(imageFile);
      }

      widget.onPhotoCaptured?.call(saved.path);

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
  

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }


}

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

Future<File> saveToAppCache(File imageFile) async {
  final dir = await getTemporaryDirectory();
  final fileName = 'itinereo_temp${DateTime.now().millisecondsSinceEpoch}.jpg';
  final savedPath = File('${dir.path}/$fileName');
  await imageFile.copy(savedPath.path);
  return savedPath;
}

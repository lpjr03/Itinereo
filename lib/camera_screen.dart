import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itinereo/exceptions/photo_exceptions.dart';
import 'package:itinereo/services/firebase_storage.dart';
import 'package:itinereo/widgets/itinereo_appBar.dart';
import 'package:itinereo/widgets/snackbar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class CameraScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final void Function(String photoPath)? onPhotoCaptured;

  const CameraScreen({
    Key? key,
    required this.onBack,
    this.onPhotoCaptured,
  }) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late final File savedPath;
  final ImagePicker _picker = ImagePicker();

  String? _imagePath;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _openCamera();
  }

  Future<void> _openCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile == null) {
        widget.onBack?.call(); 
        return;
      }
      setState(() {
        _imagePath = pickedFile.path;
      });
    } catch (e) {
      if (mounted) {
        ItinereoSnackBar.show(context, "Error opening the camera. Please try again.");
        widget.onBack?.call();
      }
    }
  }

  Future<File> _saveToGalleryManually(File imageFile) async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    final status = sdkInt >= 33
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

  Future<void> _uploadPhoto() async {
    if (_imagePath == null) return;

    try {
      setState(() => _isUploading = true);
      final imageFile = File(_imagePath!);
      await _saveToGalleryManually(imageFile);
      widget.onPhotoCaptured?.call(savedPath.path);

      if (mounted) {
        ItinereoSnackBar.show(context, "Photo successfully uploaded.");
        await Future.delayed(const Duration(seconds: 1));
        if (Navigator.canPop(context)) Navigator.pop(context);
      }
    } on PhotoException catch (e) {
      ItinereoSnackBar.show(context, e.message);
    } catch (e) {
      ItinereoSnackBar.show(context, "Unexpected error. Please try again.");
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ItinereoAppBar(
        title: "Photo Preview",
        textColor: const Color(0xFFF6E1C4),
        pillColor: const Color.fromARGB(255, 127, 62, 18),
        topBarColor: const Color.fromARGB(255, 8, 6, 4),
      ),
      body: Stack(
        children: [
          if (_imagePath != null)
            Positioned.fill(
              child: Image.file(File(_imagePath!), fit: BoxFit.cover),
            ),
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
          if (_imagePath != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _isUploading ? null : _uploadPhoto,
                    child: const Text('Upload Photo'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _imagePath = null);
                      _openCamera(); // Scatta di nuovo
                    },
                    child: const Text('Take Another Photo'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

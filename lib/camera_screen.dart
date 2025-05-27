import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itinereo/exceptions/photo_exceptions.dart';
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

    final imageFile = File(pickedFile.path);
    final saved = await _saveToGalleryManually(imageFile);
    widget.onPhotoCaptured?.call(saved.path);

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context); // torna indietro subito
    }
  } on PhotoException catch (e) {
    if (mounted) {
      ItinereoSnackBar.show(context, e.message);
      widget.onBack?.call();
    }
  } catch (e) {
    if (mounted) {
      ItinereoSnackBar.show(context, "Unexpected error. Please try again.");
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

@override
Widget build(BuildContext context) {
  return const Scaffold(
    body: SizedBox.expand(
      child: ColoredBox(color: Colors.black),
    ),
  );
}
}

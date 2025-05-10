import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:itinereo/exceptions/photo_exceptions.dart';
import 'package:itinereo/firebase_storage.dart';


/// A screen that allows the user to take a photo using the device camera
/// and upload it to Firebase Storage.
///
/// Features:
/// - Initializes the camera with high resolution.
/// - Captures a photo when the user presses the button.
/// - Uploads the photo to Firebase Storage via the [StorageService].
/// - Displays a success or error message using SnackBar.
/// - Returns to the previous screen after upload completes.
class CameraScreen extends StatefulWidget {
  /// The camera description passed from the camera list.
  final CameraDescription camera;

  /// Creates a [CameraScreen] widget.
  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  /// The local path of the captured image.
  String? _imagePath;

  /// The download URL of the uploaded image from Firebase Storage.
  String? _downloadUrl;

  /// Service for handling Firebase Storage uploads.
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Captures a picture using the camera and uploads it to Firebase Storage.
  ///
  /// Parameters:
  /// - [entryId]: The ID of the diary entry this photo is associated with.
  ///
  /// Displays a success SnackBar on completion, or an error SnackBar if
  /// an error occurs.
  bool _isUploading = false;

Future<void> _takePictureAndUpload() async {
  try {
    setState(() => _isUploading = true);
    await _initializeControllerFuture;

    late XFile file;
    try {
      file = await _controller.takePicture();
    } on CameraException catch (e) {
      throw PhotoCaptureException('Errore fotocamera: ${e.description}');
    } on IOException catch (e) {
      throw PhotoCaptureException('Errore file system: ${e.toString()}');
    }

    final File imageFile = File(file.path);
    String downloadUrl;

    try {
      downloadUrl = await _storageService.uploadPhoto(imageFile);
    } catch (e) {
      throw PhotoUploadException('Errore upload Firebase: ${e.toString()}');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto caricata!')),
      );
      await Future.delayed(const Duration(seconds: 1));
      if (Navigator.canPop(context)) Navigator.pop(context);
    }
  } on PhotoException catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore imprevisto')),
      );
    }
  } finally {
    if (mounted) setState(() => _isUploading = false);
  }
}
  /// Builds the camera screen UI.
  ///
  /// Displays a [CameraPreview] and a button to take a picture.
  /// Shows a loading indicator while the image is being uploaded.
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Camera Screen')),
    body: FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: [
              CameraPreview(_controller),
              if (_isUploading)
                Container(
                  color: Colors.black54,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : () {
                    _takePictureAndUpload();
                  },
                  child: const Text('Scatta Foto e Carica'),
                ),
              ),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    ),
  );
}
}
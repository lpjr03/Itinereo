import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:itinereo/exceptions/photo_exceptions.dart';
import 'package:itinereo/services/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription? camera;
  final VoidCallback? onBack;

  const CameraScreen({Key? key, required this.camera, required this.onBack})
    : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  String? _imagePath;
  String? _downloadUrl;
  bool _isUploading = false;

  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();

    if (widget.camera == null) {
      throw Exception("Camera non inizializzata!");
    }

    _controller = CameraController(widget.camera!, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveToGalleryManually(File imageFile) async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        throw Exception("Photo access not granted");
      }
    } else {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception("Storage access not granted");
      }
    }

    final dir = Directory('/storage/emulated/0/Pictures/Itinereo');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final fileName = 'itinereo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = File('${dir.path}/$fileName');
    await imageFile.copy(savedPath.path);
  }

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

      setState(() {
        _imagePath = imageFile.path;
      });

      try {
        await _saveToGalleryManually(imageFile);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore salvataggio galleria: ${e.toString()}'),
            ),
          );
        }
      }

      String downloadUrl;
      try {
        downloadUrl = await _storageService.uploadPhoto(imageFile);
        _downloadUrl = downloadUrl;
      } catch (e) {
        throw PhotoUploadException('Errore upload Firebase: ${e.toString()}');
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Foto caricata!')));
        await Future.delayed(const Duration(seconds: 1));
        if (Navigator.canPop(context)) Navigator.pop(context);
      }
    } on PhotoException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Errore imprevisto')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            }
          },
        ),
        title: const Text('Camera Screen'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Positioned.fill(
                  child:
                      _imagePath == null
                          ? CameraPreview(_controller)
                          : Image.file(File(_imagePath!), fit: BoxFit.cover),
                ),
                if (_isUploading)
                  Container(
                    color: Colors.black54,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: _isUploading ? null : _takePictureAndUpload,
                        child: const Text('Scatta Foto e Carica'),
                      ),
                      if (_imagePath != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _imagePath = null;
                            });
                          },
                          child: const Text('Scatta di nuovo'),
                        ),
                    ],
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

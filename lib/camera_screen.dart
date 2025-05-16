import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itinereo/exceptions/photo_exceptions.dart';
import 'package:itinereo/services/firebase_storage.dart';
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
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();

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
        widget.onBack?.call(); // torna indietro se l'utente annulla
        return;
      }
      setState(() {
        _imagePath = pickedFile.path;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore apertura fotocamera')),
        );
        widget.onBack?.call();
      }
    }
  }

  Future<void> _saveToGalleryManually(File imageFile) async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    final status = sdkInt >= 33
        ? await Permission.photos.request()
        : await Permission.storage.request();

    if (!status.isGranted) throw Exception("Permessi non concessi");

    final dir = Directory('/storage/emulated/0/Pictures/Itinereo');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final fileName = 'itinereo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = File('${dir.path}/$fileName');
    await imageFile.copy(savedPath.path);
  }

  Future<void> _uploadPhoto() async {
    if (_imagePath == null) return;

    try {
      setState(() => _isUploading = true);
      final imageFile = File(_imagePath!);

      try {
        await _saveToGalleryManually(imageFile);
      } catch (_) {}

      final downloadUrl = await _storageService.uploadPhoto(imageFile);
      widget.onPhotoCaptured?.call(downloadUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto caricata!')),
        );
        await Future.delayed(const Duration(seconds: 1));
        if (Navigator.canPop(context)) Navigator.pop(context);
      }
    } on PhotoException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore imprevisto')),
      );
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
          onPressed: () => widget.onBack?.call(),
        ),
        title: const Text('Anteprima Foto'),
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
                    child: const Text('Carica'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _imagePath = null);
                      _openCamera(); // Scatta di nuovo
                    },
                    child: const Text('Scatta di nuovo'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:itinereo/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Camera Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CameraScreen(camera: camera),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  String? _imagePath;
  String? _downloadUrl;

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

Future<void> _takePictureAndUpload(String entryId) async {
  try {
    await _initializeControllerFuture;
    final XFile file = await _controller.takePicture();
    final File imageFile = File(file.path);
    final String downloadUrl = await _storageService.uploadPhoto(imageFile);


    // Mostra Snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto caricata!')),
      );

      // Torna indietro dopo breve attesa per permettere al popup di mostrarsi
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context);
    }
  } catch (e) {
    print('Errore nello scattare la foto: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore nel caricamento della foto')),
      );
    }
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Camera Screen')),
    body: FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: CameraPreview(_controller)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Passa l’entryId corretto qui!
                  _takePictureAndUpload('ENTRY_ID'); 
                },
                child: const Text('Scatta Foto e Carica'),
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

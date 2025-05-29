import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itinereo/widgets/snackbar.dart';
import 'package:itinereo/widgets/text_widget.dart';

class CameraScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final void Function(String photoPath)? onPhotoCaptured;

  const CameraScreen({super.key, required this.onBack, this.onPhotoCaptured});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late final File savedPath;
  final ImagePicker _picker = ImagePicker();

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
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) {
        widget.onBack?.call();
        return;
      }

      final imageFile = File(pickedFile.path);
      widget.onPhotoCaptured?.call(imageFile.path);

      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ItinereoSnackBar.show(context, "Errore: nel salvataggio della foto");
        widget.onBack?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // mostra un loader temporaneo
      ),
    );
  }
}

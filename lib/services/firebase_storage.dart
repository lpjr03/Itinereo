import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// A service class for managing photo uploads to Firebase Storage.
///
/// This class is designed for future integration with the Itinereo app,
/// particularly for saving diary-related photos in the cloud.
///
/// Images are stored under the path:
/// `Users/{userId}/diary_photos/{timestamp}.jpg`
class StorageService {
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  /// The currently authenticated user's UID.
  String get userId => _auth.currentUser!.uid;

  /// Uploads an image file to Firebase Storage and returns its public URL.
  ///
  /// The image is saved under the path:
  /// `Users/{userId}/diary_photos/{timestamp}.jpg`
  ///
  /// Example usage:
  /// ```dart
  /// final url = await storageService.uploadPhoto(File('path/to/image.jpg'));
  /// ```
  ///
  /// This method will be used in the future to attach photos to diary entries.
  Future<String> uploadPhoto(File imageFile) async {
    final ref = _storage
        .ref()
        .child('Users/$userId/diary_photos/${DateTime.now().millisecondsSinceEpoch}.jpg');

    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }
}

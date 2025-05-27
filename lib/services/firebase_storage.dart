import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:itinereo/exceptions/photo_exceptions.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;
  String get userId => _auth.currentUser!.uid;

  Future<String> uploadPhoto(File imageFile) async {
    final ref = _storage.ref().child('Users/$userId/diary_photos/${DateTime.now().millisecondsSinceEpoch}.jpg');

    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> deletePhoto(String downloadUrl) async {
  try {
    final ref = _storage.refFromURL(downloadUrl);
    await ref.delete();
  } catch (e) {
    throw PhotoDeleteException('Impossibile eliminare la foto: $e');
  }
}

}

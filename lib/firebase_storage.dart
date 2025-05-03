import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadPhoto(File imageFile) async {
    final id = const Uuid().v4();
    final ref = _storage.ref().child('diary_photos/$id.jpg');

    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }
}

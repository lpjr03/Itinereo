import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;
  String get userId => _auth.currentUser!.uid;

  Future<String> uploadPhoto(File imageFile) async {
    final ref = _storage.ref().child('Users/$userId/diary_photos/${DateTime.now().millisecondsSinceEpoch}.jpg');

    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }

}

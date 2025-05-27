import 'dart:io';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:itinereo/exceptions/sign_in_exception.dart';
import 'package:itinereo/models/diary_entry.dart';
import 'package:mime/mime.dart';

/// A service class responsible for handling Google Sign-In authentication.
///
/// This class integrates with both the `google_sign_in` and `firebase_auth`
/// packages to allow users to sign in to the app using their Google account.
///
/// All methods are static, so there's no need to instantiate the class.
class GoogleService {
  /// Internal instance of [GoogleSignIn].
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Internal instance of [FirebaseAuth].
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Signs in the user using Google Sign-In and Firebase Authentication.
  ///
  /// Returns the signed-in [User] if the authentication succeeds.
  ///
  /// Throws a [SignInException] if:
  /// - The user cancels the sign-in process.
  /// - Firebase authentication fails.
  /// - A platform-level error occurs (e.g., Google Play Services error).
  /// - Any other unknown error happens.
  ///
  static Future<User?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw SignInException('Login interrupted by the user.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw SignInException('Firebase error: ${e.message}');
    } on PlatformException catch (e) {
      throw SignInException('Platform error: ${e.message}');
    } catch (e) {
      throw SignInException('Sign-in interrupted');
    }
  }

  /// Generates a diary description using the Gemini API from a [DiaryEntry].
  /// The description is based on title, location, date, and photo URLs.
  ///
  /// Returns a string description if successful, otherwise throws an exception.
  static Future<String> generateDescriptionFromEntry(
    DiaryEntry entry,
    String location,
  ) async {
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.0-flash-001',
    );
    final prompt = TextPart('''
Crea una descrizione per una voce di diario di viaggio con queste informazioni:
Titolo: ${entry.title}
Località: La posizione è: $location
Data: ${entry.date.toIso8601String()}
Descrivi l’esperienza in modo personale ed emotivo, coerente con le immagini, descrivendole una per una.
Massimo 1500 caratteri.
Parti direttamente con la risposta, come se fosse un diario personale, senza introdurre il testo con "Ecco la descrizione" o simili.
''');
    final parts = <Part>[prompt];

    for (final url in entry.photoUrls) {
      final file = File(url);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final mimeType = lookupMimeType(url) ?? 'image/jpg';
        parts.add(InlineDataPart(mimeType, bytes));
      }
    }

    final response = await model.generateContent([Content.multi(parts)]);

    return response.text ?? 'Nessuna descrizione generata.';
  }
}

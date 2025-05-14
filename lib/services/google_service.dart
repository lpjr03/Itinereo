import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:itinereo/exceptions/sign_in_exception.dart';
import 'package:itinereo/models/diary_entry.dart';

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

  /// Gemini API key (set your actual key here).
  static const String _geminiApiKey = 'YOUR_GEMINI_API_KEY';

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
  static Future<String> generateDescriptionFromEntry(DiaryEntry entry) async {
    final prompt = '''Crea una descrizione per una voce di diario di viaggio con queste informazioni:
Titolo: ${entry.title}
Località: coordinate (${entry.latitude}, ${entry.longitude})
Data: ${entry.date.toIso8601String()}
Descrivi l’esperienza in modo personale ed emotivo, coerente con le immagini.''';

    final parts = <Map<String, dynamic>>[
      {"text": prompt},
    ];

    for (final url in entry.photoUrls) {
      final bytes = await File(url).readAsBytes();
      parts.add({
        "inlineData": {
          "mimeType": "image/jpeg",
          "data": base64Encode(bytes),
        }
      });
    }

    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent?key=$_geminiApiKey',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": [
          {"parts": parts}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['candidates'][0]['content']['parts'][0]['text'] ?? '';
    } else {
      throw Exception('Failed to generate description: ${response.body}');
    }
  }
}

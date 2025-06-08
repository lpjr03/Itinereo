import 'dart:convert';
import 'dart:io';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:itinereo/exceptions/sign_in_exception.dart';
import 'package:itinereo/models/diary_entry.dart';
import 'package:itinereo/services/diary_service.dart';
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

      await DiaryService.instance.syncLocalEntriesWithFirestore(userCredential);

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
    // Define output schema
    final jsonSchema = Schema.object(
      properties: {'description': Schema.string()},
    );

    // Prompt testuale
    final prompt = TextPart('''
Crea una descrizione per una voce di diario di viaggio con queste informazioni:
Titolo: ${entry.title}
Descrizione: ${entry.description}
Località: La posizione è: $location
Data: ${entry.date.toIso8601String()}
Descrivi l’esperienza in modo personale ed emotivo, coerente con le immagini, descrivendole una per una.
Massimo 1500 caratteri.
Parti direttamente con la descrizione, senza frasi introduttive o date e luogo all'inizio con poi la descrizione.
Fornisci la risposta come JSON con un solo campo chiamato "description".
''');

    final parts = <Part>[prompt];

    for (final url in entry.photoUrls) {
      final file = File(url);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final mimeType = lookupMimeType(url) ?? 'image/jpeg';
        parts.add(InlineDataPart(mimeType, bytes));
      }
    }

    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.0-flash-001',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: jsonSchema,
      ),
    );

    final response = await model.generateContent([Content.multi(parts)]);

    final rawText = response.text!;
    final jsonResponse = jsonDecode(rawText);
    if (jsonResponse case {'description': final String description}) {
      return description;
    } else {
      return 'Could not generate description.';
    }
  }

  /// Generates 5 suggested itineraries based on a list of [DiaryEntry] objects.
  ///
  /// The function sends the entries to the Gemini API, prompting it to return
  /// five imaginative travel itineraries inspired by the diary entries, each composed
  /// of a list of Google Maps [Marker] objects. The generated itineraries suggest
  /// new locations and are not limited to those found in the original entries.
  ///
  /// Returns a [Future] containing a list of 5 itineraries, where each itinerary
  /// is a [List] of [Marker]s.
  ///
  /// Throws an [Exception] if the AI response cannot be parsed.

  static Future<List<Map<String, dynamic>>> generateItinerariesFromEntries(
    List<DiaryEntry> entries,
  ) async {
    // Build entry summaries
    String entrySummaries = entries
        .map((entry) {
          return '''
Titolo: ${entry.title}
Data: ${entry.date.toIso8601String()}
Descrizione: ${entry.description}
Luogo: lat=${entry.latitude}, lon=${entry.longitude}
''';
        })
        .join('\n\n');

    // Updated schema with 'title' for each itinerary
    final jsonSchema = Schema.object(
      properties: {
        'itineraries': Schema.array(
          items: Schema.object(
            properties: {
              'title': Schema.string(),
              'stops': Schema.array(
                items: Schema.object(
                  properties: {
                    'name': Schema.string(),
                    'latitude': Schema.number(),
                    'longitude': Schema.number(),
                  },
                ),
              ),
            },
          ),
        ),
      },
    );

    // Updated prompt
    final prompt = TextPart('''
Ti fornisco un elenco di voci di diario di viaggio (titolo, descrizione, luogo).
Crea **5 diversi itinerari turistici** ispirati a questi racconti, proponendo nuove località **simili o collegate** per atmosfera, tema o interesse.

Per ogni itinerario fornisci:
- **title**: un titolo suggestivo per l’itinerario
- **stops**: un array di 5 tappe, ognuna con:
  - "name": il nome del luogo
  - "latitude": la latitudine
  - "longitude": la longitudine

Le tappe devono essere **geograficamente vicine** (massimo 200 km l’una dall’altra).

Ecco le voci di diario da cui prendere ispirazione:

$entrySummaries
''');

    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.0-flash-001',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: jsonSchema,
      ),
    );

    final response = await model.generateContent([Content.text(prompt.text)]);

    if (response.text == null) {
      throw Exception('Empty response.');
    }

    try {
      final rawText = response.text!;
      final jsonResponse = jsonDecode(rawText);
      final itineraries = jsonResponse['itineraries'] as List;

      return itineraries.map<Map<String, dynamic>>((itinerary) {
        final title = itinerary['title'] as String;
        final stops =
            (itinerary['stops'] as List).map<Marker>((stop) {
              return Marker(
                markerId: MarkerId(stop['name']),
                position: LatLng(
                  (stop['latitude'] as num).toDouble(),
                  (stop['longitude'] as num).toDouble(),
                ),
                infoWindow: InfoWindow(title: stop['name']),
              );
            }).toList();
        return {'title': title, 'markers': stops};
      }).toList();
    } catch (e) {
      throw Exception('Error parsing response: ${e.toString()}');
    }
  }
}

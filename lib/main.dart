import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:itinereo/auth/screens/login_checker.dart';

/// Entry point of the Itinereo app.
///
/// Initializes:
/// - Environment variables using `.env`
/// - Firebase and Firebase App Check
/// - Firestore settings (with persistence disabled)
/// - System UI mode (only top status bar visible)
///
/// Then runs the [LogInChecker] widget, which determines whether to
/// display the main app or the authentication flow.
void main() async {
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );
  
  runApp(const LogInChecker());
}

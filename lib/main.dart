import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:itinereo/LoginManager/check_log_in.dart';
import 'itinereo_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const LogInChecker());
}

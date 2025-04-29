import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:itinereo/login_manager/log_in_checker.dart';
import 'package:itinereo/itinereo_manager.dart';

/**
 void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const LogInChecker());
}**/

void main() async{
  runApp(const ItinereoManager());
}
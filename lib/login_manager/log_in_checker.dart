import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itinereo/login_manager/login_screen.dart';
import 'package:itinereo/login_manager/signup_screen.dart';
import 'package:itinereo/login_manager/welcome_screen.dart';
import 'package:itinereo/itinereo_manager.dart';


class LogInChecker extends StatelessWidget {
  const LogInChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Itinereo',
      theme: ThemeData(
        primaryColor: const Color(0xFFFBFCFF),
        scaffoldBackgroundColor: const Color(0xFF262b31),
        secondaryHeaderColor: const Color(0xFF151a1d),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
      home: Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              return const ItinereoManager(); 
            } else {
              return const WelcomeScreen();
            }
          }),
        ),
      ),
    );
  }
}
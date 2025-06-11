import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itinereo/login_manager/login_screen.dart';
import 'package:itinereo/login_manager/signup_screen.dart';
import 'package:itinereo/login_manager/welcome_screen.dart';
import 'package:itinereo/itinereo_manager.dart';

/// Entry point widget that determines whether to show the main app or authentication screens.
///
/// [LogInChecker] listens to the Firebase Authentication state and displays:
/// - [ItinereoManager] if the user is authenticated
/// - [WelcomeScreen] if the user is not logged in
///
/// Also defines the main application theme and routing configuration.
///
/// This widget should be used as the root of the app after initialization.
class LogInChecker extends StatelessWidget {
  /// Creates the [LogInChecker] widget.
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

      /// Defines the named routes for login and signup screens.
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },

      /// Home screen is determined by Firebase auth state.
      home: Scaffold(
        body: StreamBuilder<User?>(
          /// Listens to changes in the authentication state (login/logout).
          stream: FirebaseAuth.instance.authStateChanges(),

          /// Builds the appropriate screen based on the auth state:
          /// - If the user is logged in: [ItinereoManager] (main app)
          /// - Otherwise: [WelcomeScreen] (unauthenticated state)
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const ItinereoManager();
            } else {
              return const WelcomeScreen();
            }
          },
        ),
      ),
    );
  }
}

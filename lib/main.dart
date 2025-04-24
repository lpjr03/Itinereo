import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itinereo/login_screen.dart';
import 'package:itinereo/signup_screen.dart';
import 'welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
              return const WelcomeScreen();//mettere HomePage()
            } else {
              return const WelcomeScreen();
            }
          }),
        ),
      ),
    );
  }
}

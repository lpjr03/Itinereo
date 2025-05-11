import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itinereo/alert_widget.dart';
import 'package:itinereo/exceptions/sign_in_exception.dart';
import 'package:itinereo/itinereo_manager.dart';
import 'package:itinereo/login_manager/google_service.dart';
import 'package:itinereo/login_manager/social_button_widget.dart';
import 'package:itinereo/snackbar.dart';
import 'forget_password_screen.dart';
import 'validator.dart';
import 'button_widget.dart';
import 'text_field_widget.dart';
import 'text_widget.dart';

/// A screen that allows users to log into the Itinereo app.
///
/// This screen provides login functionality using email and password,
/// as well as Google Sign-In. It includes field validation, error handling,
/// and navigation to password recovery or main app upon successful login.
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

/// Performs login using email and password.
///
/// Displays an [ErrorDialog] if fields are empty or if login fails
/// with a Firebase-specific error. On success, navigates to [ItinereoManager].
  void login() async {
    final String email = emailController.text;
    final String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder:
            (context) => const ErrorDialog(
              message: "Please make sure to fill in both email and password.",
            ),
      );
      return;
    }

    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.uid)
          .get();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ItinereoManager()),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-credential':
          message = "Invalid email or password.";
          break;
        default:
          message = "Authentication error. Please try again.";
      }

      showDialog(
        context: context,
        builder: (context) => ErrorDialog(message: message),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E2C7),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height / 3.5,
                child: Image.asset("assets/images/logo.jpeg"),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 16.0, right: 21.0),
              height: MediaQuery.of(context).size.height / 1.67,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    title: "Log-in",
                    txtSize: 30,
                    txtColor: Color(0xFF20535B),
                  ),
                  const TextWidget(
                    title: "Email",
                    txtSize: 22,
                    txtColor: Color(0xFF20535B),
                  ),
                  InputTxtField(
                    hintText: "Email",
                    controller: emailController,
                    validator: emailValidator,
                    obscureText: false,
                  ),
                  const TextWidget(
                    title: "Password",
                    txtSize: 22,
                    txtColor: Color(0xFF20535B),
                  ),
                  InputTxtField(
                    hintText: "Password",
                    controller: passwordController,
                    validator: passwordValidator,
                    obscureText: true,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  ((context) => const ForgetPasswordScreen()),
                            ),
                          );
                        },
                        child: const TextWidget(
                          title: "Forgot password?",
                          txtSize: 18,
                          txtColor: Color(0xFF20535B),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    child: ButtonWidget(btnText: "Log in", onPress: login),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Container(
                          height: 2.0,
                          width: 70.0,
                          color: Color(0xFF20535B),
                        ),
                      ),
                      const TextWidget(
                        title: "Or log in with",
                        txtSize: 18,
                        txtColor: Color(0xFF20535B),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Container(
                          height: 2.0,
                          width: 70.0,
                          color: Color(0xFF20535B),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: SocialButtonWidget(
                      bgColor: Colors.white,
                      imagePath: 'assets/images/Google_G_logo.png',
                      onPress: () async {
                        try {
                          User? user = await GoogleService.loginWithGoogle();
                          if (user != null) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: ((context) => const ItinereoManager()),
                              ),
                            );
                          }
                        } on SignInException catch (e) {
                          ItinereoSnackBar.show(context, e.message);
                        } catch (e) {
                          ItinereoSnackBar.show(
                            context,
                            "Google login failed. Please try again.",
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

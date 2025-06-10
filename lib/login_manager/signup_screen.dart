// Refactored SignUpScreen with structure and adaptiveness similar to LoginScreen

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itinereo/exceptions/sign_in_exception.dart';
import 'package:itinereo/itinereo_manager.dart';
import 'package:itinereo/login_manager/welcome_screen.dart';
import 'package:itinereo/services/diary_service.dart';
import 'package:itinereo/services/google_service.dart';
import 'package:itinereo/widgets/alert_widget.dart';
import 'package:itinereo/widgets/snackbar.dart';
import 'package:itinereo/widgets/social_button_widget.dart';
import 'validator.dart';
import 'package:itinereo/widgets/loading_button_widget.dart';
import 'package:itinereo/widgets/text_field_widget.dart';
import 'package:itinereo/widgets/text_widget.dart';

/// A screen that allows users to sign up for an account in the Itinereo app.
///
/// This screen provides form inputs for name, email, and password,
/// and handles user registration through Firebase Authentication.
/// It also saves user info in Firestore and supports Google Sign-In.
class SignUpScreen extends StatefulWidget {
  /// Creates a [SignUpScreen] widget.
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

/// The state for the [SignUpScreen] widget.
class _SignUpScreenState extends State<SignUpScreen> {
  /// Controller for the name input field.
  TextEditingController nameController = TextEditingController();

  /// Controller for the email input field.
  TextEditingController emailController = TextEditingController();

  /// Controller for the password input field.
  TextEditingController passwordController = TextEditingController();

  /// Indicates whether the password is obscured.

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Handles user registration using Firebase Authentication.
  ///
  /// Validates inputs, creates a user with email and password,
  /// stores additional user info in Firestore, and navigates to the [WelcomeScreen].
  /// Shows error dialogs for weak passwords or existing accounts.
  void register() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;
    final String name = nameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder:
            (context) => const ErrorDialog(
              message: "Please make sure to fill in all fields.",
            ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await db.collection("Users").doc(userCredential.user!.uid).set({
        "Name": name,
        "Email": email,
      });

      await FirebaseAuth.instance.currentUser?.updateDisplayName(name);

      await FirebaseAuth.instance.signOut();

      if (mounted) {
        setState(() => isLoading = false);

        ItinereoSnackBar.show(context, "Sign-up successful! Please Log In.");

        await Future.delayed(const Duration(milliseconds: 2100));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = "Registration failed. Please try again.";
      if (e.code == 'weak-password') {
        message = "Password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        message = "The account already exists for that email.";
      }
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(message: message),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
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
                child: Image.asset("assets/images/logo.png"),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: MediaQuery.of(context).size.height / 1.6,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    title: "Sign-up",
                    txtSize: 30,
                    txtColor: const Color(0xFF20535B),
                  ),
                  const TextWidget(
                    title: "Name",
                    txtSize: 22,
                    txtColor: Color(0xFF20535B),
                  ),
                  InputTxtField(
                    hintText: "Name",
                    controller: nameController,
                    validator: nameValidator,
                    obscureText: false,
                    autocorrect: false,
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
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    keyboardType: TextInputType.emailAddress,
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
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    child: LoadingButton(
                      btnText: "Sign Up",
                      onPress: register,
                      isLoading: isLoading,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Container(
                          height: 2.0,
                          width: 70.0,
                          color: const Color(0xFF20535B),
                        ),
                      ),
                      const TextWidget(
                        title: "Or sign up with",
                        txtSize: 18,
                        txtColor: Color(0xFF20535B),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Container(
                          height: 2.0,
                          width: 70.0,
                          color: const Color(0xFF20535B),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: SocialButtonWidget(
                      bgColor: Colors.white,
                      imagePath: 'assets/images/Google_G_logo.png',
                      buttonName: 'Google',
                      onPress: () async {
                        await DiaryService.instance.requestStoragePermission();
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
                            "Google sign up failed. Please try again.",
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itinereo/services/diary_service.dart';
import 'package:itinereo/services/google_service.dart';
import 'package:itinereo/widgets/alert_widget.dart';
import 'package:itinereo/exceptions/sign_in_exception.dart';
import 'package:itinereo/itinereo_manager.dart';
import 'package:itinereo/widgets/snackbar.dart';
import 'package:itinereo/widgets/social_button_widget.dart';
import 'forget_password_screen.dart';
import 'validator.dart';
import '../widgets/loading_button_widget.dart';
import '../widgets/text_field_widget.dart';
import '../widgets/text_widget.dart';

/// A screen that allows users to log into the Itinereo app using email/password or Google Sign-In.
///
/// This screen includes:
/// - Input fields for email and password, with validation.
/// - A login button that authenticates using Firebase Authentication.
/// - An option to recover a forgotten password.
/// - A Google Sign-In button for alternative authentication.
/// - Automatic synchronization of local diary entries upon successful login.
class LoginScreen extends StatefulWidget {
  /// Creates the [LoginScreen].
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Controller for the email input field.
  final TextEditingController emailController = TextEditingController();

  /// Controller for the password input field.
  final TextEditingController passwordController = TextEditingController();

  /// Instance of Firebase Authentication used for email/password login.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Indicates whether a login operation is in progress.
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Logs in the user using email and password.
  ///
  /// If any field is empty, displays an [ErrorDialog].
  /// On success:
  /// - Retrieves the user document from Firestore.
  /// - Synchronizes local diary entries.
  /// - Navigates to the [ItinereoManager].
  /// On failure:
  /// - Shows an appropriate error message via [ErrorDialog].
  Future<void> login() async {
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

    setState(() => isLoading = true);
    await DiaryService.instance.requestStoragePermission();

    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.uid)
          .get();

      await DiaryService.instance.syncLocalEntriesWithFirestore(userCredential);

      if (mounted) {
        setState(() => isLoading = false);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ItinereoManager()),
        );
      }
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

            /// App logo
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 3.5,
                child: Image.asset("assets/images/logo.png"),
              ),
            ),

            const SizedBox(height: 10),

            /// Login form container
            Container(
              margin: const EdgeInsets.only(left: 16.0, right: 21.0),
              height: MediaQuery.of(context).size.height / 1.67,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  const TextWidget(
                    title: "Log-in",
                    txtSize: 30,
                    txtColor: Color(0xFF20535B),
                  ),

                  /// Email input
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

                  /// Password input
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

                  /// Forgot password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const ForgetPasswordScreen(),
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

                  /// Login button
                  SizedBox(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    child: LoadingButton(
                      btnText: "Log In",
                      onPress: login,
                      isLoading: isLoading,
                    ),
                  ),

                  /// OR separator
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
                        title: "Or log in with",
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

                  /// Google sign-in
                  Center(
                    child: SocialButtonWidget(
                      bgColor: Colors.white,
                      imagePath: 'assets/images/Google_G_logo.png',
                      buttonName: 'Google',
                      onPress: () async {
                        try {
                          await DiaryService.instance
                              .requestStoragePermission();

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

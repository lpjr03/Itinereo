import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itinereo/shared/widgets/alert.dart';
import 'package:itinereo/shared/widgets/snackbar.dart';
import '../../utils/validator.dart';
import '../widgets/loading_button.dart';
import '../widgets/text_field.dart';
import '../../shared/widgets/text.dart';

/// A screen that allows users to request a password reset via email.
///
/// This screen includes:
/// - An input field for the user's email address.
/// - A submit button that triggers FirebaseAuth's password reset email.
/// - Feedback via a styled snackbar on success.
/// - An error dialog if the field is empty.
/// - A button to return to the login screen.
class ForgetPasswordScreen extends StatefulWidget {
  /// Creates the [ForgetPasswordScreen].
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  /// Controller for the email input field.
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  /// Sends a password reset email using Firebase Authentication.
  ///
  /// Validates the input field to ensure it is not empty.
  /// On success, displays a confirmation snackbar and pops the screen after a short delay.
  /// On failure (empty input), shows a custom error dialog.
  Future<void> forgetPassword() async {
    final String email = emailController.text;

    if (email.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const ErrorDialog(message: "Please enter your email address.");
        },
      );
      return;
    }

    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    ItinereoSnackBar.show(context, "Password reset email sent.");
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E2C7),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),

            /// Logo section
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 3.5,
                child: Image.asset("assets/images/logo.png"),
              ),
            ),

            const SizedBox(height: 10),

            /// Form section
            Container(
              margin: const EdgeInsets.only(left: 16.0, right: 21.0),
              height: MediaQuery.of(context).size.height / 2.5,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextWidget(
                    title: "Email",
                    txtSize: 22,
                    txtColor: Color(0xFF20535B),
                  ),

                  /// Email input field
                  InputTxtField(
                    hintText: "Your Email id",
                    controller: emailController,
                    validator: emailValidator,
                    obscureText: false,
                  ),

                  /// Submit button
                  SizedBox(
                    height: 55,
                    width: MediaQuery.of(context).size.width,
                    child: LoadingButton(
                      btnText: "Submit",
                      onPress: forgetPassword,
                    ),
                  ),

                  /// Back to login button
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const TextWidget(
                        title: "Back to login",
                        txtSize: 18,
                        txtColor: Color(0xFF20535B),
                      ),
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

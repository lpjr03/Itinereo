import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itinereo/widgets/alert_widget.dart';
import 'package:itinereo/widgets/snackbar.dart';
import 'validator.dart';
import '../widgets/button_widget.dart';
import '../widgets/text_field_widget.dart';
import '../widgets/text_widget.dart';

/// A screen that allows users to reset their password via email.
///
/// This screen provides:
/// - an input field for the user’s email address
/// - a submit button that sends a password reset email
/// - feedback via a styled snackbar
/// - a button to return to the login screen
class ForgetPasswordScreen extends StatefulWidget {
  /// Creates the [ForgetPasswordScreen].
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  /// Controller for the email input field.
  TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  /// Sends a password reset email to the entered address.
  ///
  /// Shows a custom error dialog if the field is empty.
  /// If the email is sent successfully, a snackbar is shown
  /// and the screen closes after 2 seconds.
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

            Center(
              child: Container(
                height: MediaQuery.of(context).size.height / 3.5,
                child: Image.asset("assets/images/logo.png"),
              ),
            ),

            const SizedBox(height: 10),

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

                  InputTxtField(
                    hintText: "Your Email id",
                    controller: emailController,
                    validator: emailValidator,
                    obscureText: false,
                  ),

                  SizedBox(
                    height: 55,
                    width: MediaQuery.of(context).size.width,
                    child: ButtonWidget(
                      btnText: "Submit",
                      onPress: forgetPassword,
                    ),
                  ),

                  Center(
                    child: GestureDetector(
                      onTap: () {
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

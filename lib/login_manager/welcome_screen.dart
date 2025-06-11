import 'package:flutter/material.dart';
import 'package:itinereo/widgets/loading_button_widget.dart';

/// The initial welcome screen for the Itinereo app.
///
/// Displays the app logo and two main buttons:
/// - **Log In**: navigates to the login screen.
/// - **Sign Up**: navigates to the sign-up screen.
///
/// This screen is shown when no user is authenticated.
class WelcomeScreen extends StatelessWidget {
  /// Creates a [WelcomeScreen] widget.
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF3E2C7),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// App logo
                Image.asset(
                  'assets/images/logo.png',
                  height: size.height * 0.35,
                ),

                SizedBox(height: size.height * 0.03),

                /// Log In button
                SizedBox(
                  width: size.width * 0.5,
                  height: size.height * 0.065,
                  child: LoadingButton(
                    onPress: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    btnText: 'Log In',
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                /// Sign Up button
                SizedBox(
                  width: size.width * 0.5,
                  height: size.height * 0.065,
                  child: LoadingButton(
                    onPress: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    btnText: 'Sign Up',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

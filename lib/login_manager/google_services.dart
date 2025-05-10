import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:itinereo/login_manager/welcome_screen.dart';
import 'package:itinereo/exceptions/sign_in_exception.dart';

/// A service class that handles user sign-in using Google Sign-In
/// and Firebase Authentication.
///
/// This service:
/// - Authenticates the user via Google account.
/// - Creates a new user document in Firestore if the user is new.
/// - Navigates to the [WelcomeScreen] after successful login.
///
/// Example usage:
/// ```dart
/// await Services.googleSignIn(context);
/// ```
class Services {
  /// Signs in a user using Google Sign-In and Firebase Authentication.
  ///
  /// Parameters:
  /// - [context]: The BuildContext used to navigate to the next screen.
  ///
  /// Behavior:
  /// - If the user signs in successfully and is new, a document is created
  ///   in the `Users` collection in Firestore.
  /// - Navigates to the [WelcomeScreen] after successful sign-in.
  ///
  /// Throws:
  /// - [SignInException] if the sign-in or authentication fails.
  static Future<void> googleSignIn(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;

      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        try {
          final authResult = await FirebaseAuth.instance.signInWithCredential(
            GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            ),
          );

          if (authResult.additionalUserInfo!.isNewUser) {
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(authResult.user!.uid)
                .set({
              "Name": authResult.user!.displayName,
              "Email": authResult.user!.email,
            });
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          );
        } on FirebaseAuthException catch (e) {
          throw SignInException('Firebase auth failed: ${e.message}');
        } catch (e) {
          throw SignInException('Unexpected error: $e');
        }
      } else {
        throw SignInException('Missing Google auth token.');
      }
    } else {
      throw SignInException('User canceled Google Sign-In.');
    }
  }
}

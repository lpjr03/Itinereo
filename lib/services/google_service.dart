import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:itinereo/exceptions/sign_in_exception.dart';

/// A service class responsible for handling Google Sign-In authentication.
///
/// This class integrates with both the `google_sign_in` and `firebase_auth`
/// packages to allow users to sign in to the app using their Google account.
///
/// All methods are static, so there's no need to instantiate the class.
class GoogleService {
  /// Internal instance of [GoogleSignIn].
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Internal instance of [FirebaseAuth].
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Signs in the user using Google Sign-In and Firebase Authentication.
  ///
  /// Returns the signed-in [User] if the authentication succeeds.
  ///
  /// Throws a [SignInException] if:
  /// - The user cancels the sign-in process.
  /// - Firebase authentication fails.
  /// - A platform-level error occurs (e.g., Google Play Services error).
  /// - Any other unknown error happens.
  ///
  static Future<User?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw SignInException('Login interrupted by the user.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw SignInException('Firebase error: ${e.message}');
    } on PlatformException catch (e) {
      throw SignInException('Platform error: ${e.message}');
    } catch (e) {
      throw SignInException('Sign-in interrupted');
    }
  }
}

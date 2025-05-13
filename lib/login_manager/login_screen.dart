import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:itinereo/itinereo_manager.dart';
import 'package:itinereo/widgets/social_button_widget.dart';
import 'forget_password_screen.dart';
import 'signup_screen.dart';
import 'validator.dart';
import '../widgets/button_widget.dart';
import '../widgets/text_field_widget.dart';
import '../widgets/text_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Inizializza GoogleSignIn

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  // Funzione per il login tramite email e password
  void login() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    final String email = emailController.text;
    final String password = passwordController.text;
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      await db.collection("Users").doc(userCredential.user!.uid).get();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: ((context) => const ItinereoManager())),
      );
    } on FirebaseAuthException catch (e) {
      // Gestione degli errori
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: TextWidget(
              title: "No User Found for that Email",
              txtSize: 18.0,
              txtColor: Theme.of(context).primaryColor,
            ),
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: TextWidget(
              title: "Wrong Password Provided by User",
              txtSize: 18.0,
              txtColor: Theme.of(context).primaryColor,
            ),
          ),
        );
      }
    }
  }

  // Funzione per il login con Google
  Future<User?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Divider(height: 50),
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
                    txtColor: Theme.of(context).primaryColor,
                  ),
                  const TextWidget(
                    title: "Email",
                    txtSize: 22,
                    txtColor: Color(0xffdddee3),
                  ),
                  InputTxtField(
                    hintText: "Your Email id",
                    controller: emailController,
                    validator: emailValidator,
                    obscureText: false,
                  ),
                  const TextWidget(
                    title: "Password",
                    txtSize: 22,
                    txtColor: Color(0xffdddee3),
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
                          title: "Forget password?",
                          txtSize: 18,
                          txtColor: Color(0xff999a9e),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    child: ButtonWidget(btnText: "Login", onPress: login),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Container(
                          height: 2.0,
                          width: 70.0,
                          color: const Color(0xff999a9e),
                        ),
                      ),
                      const TextWidget(
                        title: "Or login with",
                        txtSize: 18,
                        txtColor: Color(0xff999a9e),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Container(
                          height: 2.0,
                          width: 70.0,
                          color: const Color(0xff999a9e),
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
                        User? user = await loginWithGoogle();
                        if (user != null) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: ((context) => const ItinereoManager()),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: const TextWidget(
                                title: "Google login failed",
                                txtSize: 18.0,
                                txtColor: Colors.white,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const TextWidget(
                        title: "Don't have an account? ",
                        txtSize: 18,
                        txtColor: Color(0xff999a9e),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: ((context) => const SignUpScreen()),
                            ),
                          );
                        },
                        child: const TextWidget(
                          title: "Sign-Up ",
                          txtSize: 18,
                          txtColor: Color(0xff999a9e),
                        ),
                      ),
                    ],
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

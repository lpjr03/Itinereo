import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itinereo/itinereo_manager.dart';
import 'package:itinereo/services/google_services.dart';
import 'package:itinereo/login_manager/welcome_screen.dart';
import 'package:itinereo/widgets/social_button_widget.dart';
import 'validator.dart';
import 'package:itinereo/widgets/button_widget.dart';
import 'package:itinereo/widgets/text_field_widget.dart';
import 'package:itinereo/widgets/text_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool obscureText = true;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void register() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    FirebaseFirestore db = FirebaseFirestore.instance;
    final String name = nameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    try {
      final UserCredential userCredential = await auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await db.collection("Users").doc(userCredential.user!.uid).set({
        "Name": name,
        "Email": email,
      });

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(), //mettere HomePage()
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (nameController.text.isEmpty &&
          emailController.text.isEmpty &&
          passwordController.text.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: const TextWidget(
                title: "Error",
                txtSize: 25.0,
                txtColor: Colors.white,
              ),
              content: const TextWidget(
                title: "Please fill the fields",
                txtSize: 20.0,
                txtColor: Colors.white,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const TextWidget(
                    title: "Ok",
                    txtSize: 18.0,
                    txtColor: Colors.blue,
                  ),
                ),
              ],
            );
          },
        );
      }
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: TextWidget(
              title: "Password Provided is too Weak",
              txtSize: 18.0,
              txtColor: Theme.of(context).primaryColor,
            ),
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: TextWidget(
              title: "Account Already exists",
              txtSize: 18.0,
              txtColor: Theme.of(context).primaryColor,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E2C7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 21.0,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height / 3.5,
                        child: Image.asset("assets/images/logo.png"),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextWidget(
                      title: "Sign-up",
                      txtSize: 30,
                      txtColor: const Color(0xFF20535B),
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ButtonWidget(
                        btnText: "Sign up",
                        onPress: register,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 2,
                          width: 70,
                          color: const Color(0xff999a9e),
                        ),
                        const SizedBox(width: 10),
                        const TextWidget(
                          title: "Or sign up with",
                          txtSize: 18,
                          txtColor: Color(0xFF20535B),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          height: 2,
                          width: 70,
                          color: const Color(0xff999a9e),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: SocialButtonWidget(
                        bgColor: Colors.white,
                        imagePath: 'assets/images/Google_G_logo.png',
                        buttonName: 'Google',
                        onPress: () async {
                          try {
                            User? user = await GoogleService.loginWithGoogle();
                            if (user != null) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder:
                                      ((context) => const ItinereoManager()),
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
            );
          },
        ),
      ),
    );
  }
}

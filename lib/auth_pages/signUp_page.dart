import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_noteapp/auth_pages/signIn_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/utils_service.dart';

class SignUpPage extends StatefulWidget {
  static const id = '/signUp_page';

  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void _signUp() {
    String fistName = firstnameController.text.trim();
    String lastname = lastnameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String name = "$fistName  $lastname";
    if (fistName.isEmpty ||
        lastname.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      Utils.fireSnackBar("Please fill all gaps", context);
      return;
    }
    isLoading = true;
    setState(() {});
    AuthService.signUpUser(context, name, email, password)
        .then((user) => _checkNewUser(user));
  }

  void _checkNewUser(User? user) async{
    if (user != null) {
   await   DBService.saveUserId(user.uid);
      if (mounted) Navigator.pushReplacementNamed(context, SignInPage.id);
    } else {
      Utils.fireSnackBar(
          "Please check your entered data, Please try again!", context);
    }
    isLoading = false;
    setState(() {});
  }

  void goSignInPage() {
    Navigator.pushReplacementNamed(context, SignInPage.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // #firstname
                  TextField(
                    controller: firstnameController,
                    decoration: const InputDecoration(hintText: "FirstName"),
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // #lastName
                  TextField(
                    controller: lastnameController,
                    decoration: const InputDecoration(hintText: "LastName"),
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 20),
                  // #email
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(hintText: "Email"),
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 20),
                  // #password
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(hintText: "Password"),
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 20),
                  // #sign_in
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50)),
                    onPressed: _signUp,
                    child: const Text(
                      "Sign in",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Already have an account?  ",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: "Sign In",
                          style: const TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = goSignInPage,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Visibility(
            visible: isLoading,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}

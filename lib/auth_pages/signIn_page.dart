import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_noteapp/auth_pages/signUp_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../pages/home_page.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/utils_service.dart';

class SignInPage extends StatefulWidget {
  static const id = '/signIn_page';

  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void _goSignUp() {
    Navigator.pushReplacementNamed(context, SignUpPage.id);
  }

  void _signIn() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      Utils.fireSnackBar("Please fill all gaps", context);
      return;
    }
    isLoading = true;
    setState(() {});
    AuthService.signInUser(context, email, password).then((user) => _checkUser(user));
  }

  void _checkUser(User? user) async {
    if (user != null) {
      await DBService.saveUserId(user.uid);
     if(mounted) Navigator.pushReplacementNamed(context,  HomePage.id);
    } else{
      Utils.fireSnackBar("Please check your entered data, Please try again!", context);
    }
    isLoading = false;
    setState(() {});
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
                  // #email
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(hintText: "Email"),
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
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
                    onPressed: _signIn,
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
                          text: "Don't have an account?",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: "Sign Up",
                          style: const TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()..onTap = _goSignUp,
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

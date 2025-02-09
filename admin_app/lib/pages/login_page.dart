import 'package:admin_app/pages/home_screen.dart';
import 'package:flutter/material.dart';

import '../components/sign_in_button.dart';
import '../components/my_textfield.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  late final BuildContext? appContext;

  // sign user in method
  Future<void> signUserIn() async {
    if(usernameController.text.toString() == "USERNAME" && passwordController.text.toString() == "PASSWORD"){
      final prefs = await SharedPreferences.getInstance();

      // update creds
      await prefs.setString("username", usernameController.text.toString());
      await prefs.setString("password", passwordController.text.toString());

      Fluttertoast.showToast(
        msg: "Starting App",
        toastLength: Toast.LENGTH_LONG,
      );

      Navigator.pushReplacement(appContext!, MaterialPageRoute(builder: (context) => HomeScreen()),);
    }
    else{
      Fluttertoast.showToast(
        msg: "Incorrect Credentials, try again.",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    appContext = context;

    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.primaryFixedDim,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const SizedBox(height: 50),

              // logo
              const Icon(
                Icons.lock,
                size: 100,
                color: Colors.deepPurple,
              ),

              const SizedBox(height: 50),

              // welcome back, you've been missed!
              Text(
                'Welcome back you lil scoundrel!',
                style: TextStyle(
                  color: Colors.deepPurple[200],
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              // username textfield
              MyTextField(
                controller: usernameController,
                hintText: 'Username',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              // password textfield
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              const SizedBox(height: 10),

              // forgot password?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Reset Password?',
                      style: TextStyle(color: Colors.deepPurple[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // sign in button
              SignInButton(
                onTap: signUserIn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
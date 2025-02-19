import 'dart:convert';
import 'dart:developer' as dev;

import 'package:admin_app/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../components/my_textfield.dart';
import '../components/sign_in_button.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  late final BuildContext? appContext;

  // sign user in method
  Future<void> signUserIn() async {
    // bypass for dev (backend apis wont be accessible)
    if (usernameController.text.toString() == "dev" &&
        passwordController.text.toString() == "dev") {
      // save tokens (bypass)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("accessToken", "bypass");
      await prefs.setString("refreshToken", "bypass");

      Fluttertoast.showToast(
        msg: "Starting App in dev mode",
        toastLength: Toast.LENGTH_LONG,
      );

      Navigator.pushReplacement(
        appContext!,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      final url = Uri.parse('http://<your_ip>:8000/api/auth/token/');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": usernameController.text.toString(),
          "password": passwordController.text.toString()
        }),
      );

      if (response.statusCode == 200) {
        // decode the json resp
        final responseData = jsonDecode(response.body);

        // save tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("accessToken", responseData['access'].toString());
        await prefs.setString(
            "refreshToken", responseData['refresh'].toString());

        Fluttertoast.showToast(
          msg: "Starting App",
          toastLength: Toast.LENGTH_LONG,
        );

        Navigator.pushReplacementNamed(appContext!, '/home');
      } else {
        Fluttertoast.showToast(
          msg: "Incorrect Credentials",
          toastLength: Toast.LENGTH_LONG,
        );
      }
    }

    dev.log("-------IM OUT-------");
  }

  @override
  Widget build(BuildContext context) {
    // appContext = context;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.primaryFixedDim,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const SizedBox(height: 50),

              // logo
              Icon(
                Icons.lock,
                size: 100,
                color: colorScheme.primary,
              ),

              const SizedBox(height: 50),

              // welcome back, you've been missed!
              Text(
                'Welcome back you lil scoundrel!',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              // username textfield
              MyTextField(
                controller: usernameController,
                hintText: 'Username',
                obscureText: false,
                borderColor: colorScheme.outline,
                focusedBorderColor: colorScheme.secondary,
              ),

              const SizedBox(height: 10),

              // password textfield
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
                borderColor: colorScheme.outline,
                focusedBorderColor: colorScheme.secondary,
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
                      style: TextStyle(color: colorScheme.secondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // sign in button
              SignInButton(
                onTap: signUserIn,
                buttonColor: colorScheme.primaryContainer,
                textColor: colorScheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

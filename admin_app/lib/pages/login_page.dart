import 'dart:developer' as dev;

import 'package:admin_app/pages/splash_screen.dart';
import 'package:admin_app/services/api%20services/authority_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/my_textfield.dart';
import '../components/sign_in_button.dart';
import '../services/api services/dio_client_auth_service.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  // sign user in method
  Future<void> signUserIn() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();

    // bypass for dev (backend apis wont be accessible)
    if (usernameController.text.toString() == "dev" &&
        passwordController.text.toString() == "dev") {
      // save token (bypass)
      await prefs.setString("isDev", "true");

      Fluttertoast.showToast(
        msg: "Starting App in dev mode",
        toastLength: Toast.LENGTH_LONG,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    } else {
      final authService = AuthorityService(DioClientAuth());
      bool isAuthenticated = await authService.login(
          usernameController.text.toString(),
          passwordController.text.toString());

      setState(() {
        isLoading = false;
      });

      if (isAuthenticated) {
        await prefs.setString("isUser", "true");
        Fluttertoast.showToast(
          msg: "Starting App",
          toastLength: Toast.LENGTH_LONG,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        );
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
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

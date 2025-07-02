import 'dart:developer' as dev;

import 'package:admin_app/pages/splash_screen.dart';
import 'package:admin_app/services/api%20services/authority_service.dart';
import 'package:admin_app/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/my_textfield.dart';
import '../services/api services/dio_client_auth_service.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final usernameController = TextEditingController();
  final passphraseController = TextEditingController();
  bool isLoading = false;
  String? usernameError;
  String? passphraseError;

  // sign user in method
  Future<void> signUserIn() async {
    setState(() {
      isLoading = true;
      usernameError = null;
      passphraseError = null;
    });

    final prefs = await SharedPreferences.getInstance();

    // bypass for dev (backend apis wont be accessible)
    if (usernameController.text.toString() == "dev" &&
        passphraseController.text.toString() == "dev") {
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
      // validating input
      if (usernameController.text.trim().isEmpty) {
        setState(() {
          isLoading = false;
          usernameError = "Username cannot be empty";
        });
        return;
      }

      if (passphraseController.text.trim().isEmpty) {
        setState(() {
          isLoading = false;
          passphraseError =
              "Passphrase can't be empty, e.g. chase-ear-finch-human-crowd";
        });
        return;
      }

      print(
          "------------------------------- im gonna check pass --------------------------------------");
      try {
        print(
            "------------------------------- ive checked pass --------------------------------------");
        final authService = AuthorityService(DioClientAuth());
        bool isAuthenticated = await authService.login(
          usernameController.text.trim(),
          passphraseController.text.trim(),
        );

        setState(() {
          isLoading = false;
        });

        if (isAuthenticated) {
          // authenticated, goes to splash scr
          await prefs.setString("isUser", "true");
          Fluttertoast.showToast(
            msg: "Starting App",
            toastLength: Toast.LENGTH_SHORT,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SplashScreen()),
          );
        } else {
          setState(() {
            usernameError = "Incorrect username";
            passphraseError = "Incorrect passphrase";
          });
          Fluttertoast.showToast(
            msg: "Incorrect Credentials",
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false;
          usernameError = "Login failed";
          passphraseError = "Login failed";
        });
        Fluttertoast.showToast(
          msg: "Error: $e",
          toastLength: Toast.LENGTH_LONG,
        );
        dev.log("Login error: $e");
      }
    }

    dev.log("-------IM OUT-------");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      // this unfocuses the textfield when tapped outside
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background image with gradient fade
            Positioned.fill(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.white.withOpacity(1.0),
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                  child: Image.asset(
                    'assets/map_light.jpg',
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            // Foreground content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // logo
                      // Icon(
                      //   Icons.lock,
                      //   size: 60,
                      //   color: colorScheme.primary,
                      // ),

                      const SizedBox(height: 20),

                      Text(
                        'Rosto Radar',
                        style: context.theme.textTheme.displayMedium,
                      ),

                      Text(
                        'Admin',
                        style: context.theme.textTheme.headlineSmall?.copyWith(
                          color: context.colorScheme.primary,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // welcome back, you've been missed!
                      Text(
                        'Welcome back!',
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
                        keyboardType: TextInputType.name,
                        borderColor: colorScheme.outline,
                        focusedBorderColor: colorScheme.secondary,
                        errorText: usernameError,
                        prefixIcon: Icons.account_circle_rounded,
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 10),

                      // password textfield
                      MyTextField(
                        controller: passphraseController,
                        hintText: 'Passphrase',
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        borderColor: colorScheme.outline,
                        focusedBorderColor: colorScheme.secondary,
                        errorText: passphraseError,
                        prefixIcon: Icons.password_rounded,
                        textInputAction: TextInputAction.done,
                        onSubmitted: signUserIn,
                      ),

                      const SizedBox(height: 10),

                      const SizedBox(height: 25),

                      // sign in button
                      GestureDetector(
                        onTap: isLoading ? null : signUserIn,
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          margin: const EdgeInsets.symmetric(horizontal: 25),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: isLoading
                                ? SizedBox(
                                    width: 20.0,
                                    height: 20.0,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.onPrimaryContainer,
                                      ),
                                      strokeWidth: 2.0,
                                    ),
                                  )
                                : Text(
                                    "Sign In",
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

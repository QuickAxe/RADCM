// lib/splash_screen.dart
import 'dart:developer' as dev;
import 'dart:ui';

import 'package:app/data/models/anomaly_marker_model.dart';
import 'package:app/services/background/activity_tracker.dart';
import 'package:app/util/general_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

import '../services/providers/permissions.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
    // Schedule the heavy initializations after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Load environment variables.
      await dotenv.load(fileName: ".env");

      // Initialize FMTC and create the map store.
      await FMTCObjectBoxBackend().initialise();
      await const FMTCStore('mapStore').manage.create();

      // Initialize Hive and register adapters.
      await Hive.initFlutter();
      Hive.registerAdapter(AnomalyMarkerAdapter());

      // Initialize permission logic and start the activity tracker
      final permissions = Provider.of<Permissions>(context, listen: false);
      await permissions.fetchPosition().then((_) async {
        await ActivityTracker().startTracker().then((_) {
          showToast("Activity Tracker started.");
        }).catchError((error) {
          dev.log("didnt start activity tracker: $error");
        });
      }).catchError((error) {
        dev.log("failed fetchlocation: $error");
      });

      // Log a message indicating initialization is complete.
      dev.log('Initialization complete. Navigating to HomeScreen.');
      showToast("Initialization complete!");

      // Navigate to HomeScreen once initialization is complete.
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e, stackTrace) {
      dev.log('Error during initialization: $e', stackTrace: stackTrace);
      showToast("An error occurred when initializing.");
      // TODO: UI error, retry mechanism
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/splash_background_dark.jpg",
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // FadeTransition(
              //   opacity: _fadeAnimation,
              //   child: Image.asset("assets/logo.png", height: 100),
              // ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  "RADCM",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              const SizedBox(height: 10),
              const Text(
                "Initializing...",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

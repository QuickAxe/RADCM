// lib/splash_screen.dart
import 'dart:developer' as dev;

import 'package:app/data/models/anomaly_marker_model.dart';
import 'package:app/pages/home_screen.dart';
import 'package:app/services/background/activity_tracker.dart';
import 'package:app/util/general_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

import '../services/providers/permissions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
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
      await permissions.fetchPosition().then((_) {
        ActivityTracker().startTracker();
        showToast("Activity Tracker started.");
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
    // TODO: Better Splash screen
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

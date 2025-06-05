import 'dart:developer' as dev;

import 'package:admin_app/data/models/anomaly_marker_model.dart';
import 'package:admin_app/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../services/providers/anomaly_websocket_provider.dart';
import '../services/providers/permissions.dart';
import '../utils/general_utils.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showDelayMessage = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        setState(() {
          _showDelayMessage = true;
        });
      }
    });

    // Schedule the heavy initializations after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize FMTC and create the map store.
      try {
        await FMTCObjectBoxBackend().initialise();
      } on FMTCBackendError catch (e) {
        if (e.toString().contains('RootAlreadyInitialised')) {
          dev.log('FMTC already initialised. Skipping.');
        } else {
          rethrow;
        }
      }
      await const FMTCStore('mapStore').manage.create();

      // Initialize Hive and register adapters.
      await Hive.initFlutter();
      try {
        Hive.registerAdapter(AnomalyMarkerAdapter());
      } on HiveError catch (e) {
        if (e
            .toString()
            .contains('There is already a TypeAdapter for typeId 0')) {
          dev.log('Hive already initialised. Skipping.');
        } else {
          rethrow;
        }
      }

      // Start the connection with the Websocket
      final ws = Provider.of<AnomalyWebSocketProvider>(context, listen: false);
      ws.init();

      // Initialize permission logic and start the activity tracker
      final permissions = Provider.of<Permissions>(context, listen: false);
      await permissions.fetchPosition();

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
      _showInitializationError(e);
    }
  }

  void _showInitializationError([Object? error]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Initialization Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Something went wrong. Please retry',
              style: context.theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            if (error != null)
              Text(
                "Error: ${error.toString()}",
                style: context.theme.textTheme.labelMedium,
              ),
          ],
        ),
        icon: const Icon(LucideIcons.alertTriangle),
        actions: [
          TextButton(
            onPressed: () {
              // must close the app
              SystemNavigator.pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // phoenix rebirth restarts the app, completely rebuilding the context's widget tree
              Phoenix.rebirth(context);
            },
            child: const Text('Restart app'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      context.colorScheme.primary)),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              if (_showDelayMessage)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Hang tight...",
                    style: context.theme.textTheme.bodyLarge,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

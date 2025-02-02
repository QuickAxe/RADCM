import 'dart:developer' as dev;

import 'package:app/pages/home_screen.dart';
import 'package:app/pages/map_route_screen.dart';
import 'package:app/pages/settings_screen.dart';
import 'package:app/pages/settings_screens/additional_settings.dart';
import 'package:app/pages/settings_screens/routines.dart';
import 'package:app/pages/settings_screens/toggle_anomalies.dart';
import 'package:app/pages/settings_screens/voice_engine.dart';
import 'package:app/services/background/anomaly_detection.dart';
import 'package:app/services/providers/permissions.dart';
import 'package:app/services/providers/search.dart';
import 'package:app/services/providers/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    // registering providers here
    MultiProvider(
      providers: [
        // permissions provider to handle permissions (location for now)
        ChangeNotifierProvider(create: (context) => Permissions()),
        ChangeNotifierProvider(create: (context) => Search()),
        ChangeNotifierProvider(create: (context) => UserSettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FlutterIsolate dataCollectorIsolate;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      Permissions permissions =
          Provider.of<Permissions>(context, listen: false);

      // calls fetch position
      permissions.fetchPosition().then((_) {
        dev.log('YOO IM THIS COOL COMMENT HERE.. IM SIC');

        dev.log('background process started.');
        theDataCollector();
        // FlutterIsolate.spawn(theDataCollector, "bg process isolate")
        //     .then((isolate) {
        //   dataCollectorIsolate = isolate;
        // });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      routes: {
        '/settings': (context) => const SettingsScreen(),
        '/toggle_anomalies': (context) => const ToggleAnomaliesScreen(),
        '/routines': (context) => const RoutinesScreen(),
        '/voice_engine': (context) => const VoiceEngineScreen(),
        '/additional_settings': (context) => const AdditionalSettings(),
        '/map_route': (context) => const MapRouteScreen(),
      },
    );
  }
}

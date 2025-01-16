import 'package:app/pages/home_screen.dart';
import 'package:app/pages/settings_screen.dart';
import 'package:app/pages/settings_screens/routines.dart';
import 'package:app/pages/settings_screens/toggle_anomalies.dart';
import 'package:app/pages/settings_screens/voice_engine.dart';
import 'package:app/util/bg_process.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';

void main() {
  runApp(const MyApp());
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
    FlutterIsolate.spawn(theDataCollector, "bg process isolate").then((isolate) {
      dataCollectorIsolate = isolate;
    });
  }

  @override
  void dispose() {
    dataCollectorIsolate.kill();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
      routes: {
        '/settings': (context) => SettingsScreen(),
        '/toggle_anomalies': (context) => ToggleAnomaliesScreen(),
        '/routines': (context) => RoutinesScreen(),
        '/voice_engine': (context) => VoiceEngineScreen(),
      },
    );
  }
}

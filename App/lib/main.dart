import 'package:app/pages/home_screen.dart';
import 'package:app/pages/settings_screen.dart';
import 'package:app/pages/settings_screens/routines.dart';
import 'package:app/pages/settings_screens/toggle_anomalies.dart';
import 'package:app/pages/settings_screens/voice_engine.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

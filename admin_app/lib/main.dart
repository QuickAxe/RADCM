import 'package:admin_app/pages/fix_anomaly.dart';
import 'package:admin_app/pages/home_screen.dart';
import 'package:admin_app/pages/login_page.dart';
import 'package:admin_app/pages/settings_screen.dart';
import 'package:admin_app/pages/settings_screens/additional_settings.dart';
import 'package:admin_app/pages/settings_screens/routines.dart';
import 'package:admin_app/pages/settings_screens/toggle_anomalies.dart';
import 'package:admin_app/pages/settings_screens/voice_engine.dart';
import 'package:admin_app/services/providers/permissions.dart';
import 'package:admin_app/services/providers/search.dart';
import 'package:admin_app/services/providers/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString("username");

  runApp(
    // registering providers here
    MultiProvider(
      providers: [
        // permissions provider to handle permissions (location for now)
        ChangeNotifierProvider(create: (context) => Permissions()),
        ChangeNotifierProvider(create: (context) => Search()),
        ChangeNotifierProvider(create: (context) => UserSettingsProvider()),
      ],
      child: MyApp(username: username),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String? username;
  const MyApp({super.key, required this.username});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: widget.username == null ? LoginPage() : HomeScreen(),
        routes: {
          '/settings': (context) => const SettingsScreen(),
          '/toggle_anomalies': (context) => const ToggleAnomaliesScreen(),
          '/routines': (context) => const RoutinesScreen(),
          '/voice_engine': (context) => const VoiceEngineScreen(),
          '/additional_settings': (context) => const AdditionalSettings(),
          '/fix_anomaly': (context) => const FixAnomaly(),
        }
    );
  }
}
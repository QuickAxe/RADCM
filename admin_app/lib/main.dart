import 'package:admin_app/pages/home_screen.dart';
import 'package:admin_app/pages/login_page.dart';
import 'package:admin_app/pages/settings_screen.dart';
import 'package:admin_app/pages/settings_screens/additional_settings.dart';
import 'package:admin_app/pages/settings_screens/navigation_preferences.dart';
import 'package:admin_app/pages/settings_screens/routines.dart';
import 'package:admin_app/pages/settings_screens/toggle_anomalies.dart';
import 'package:admin_app/pages/settings_screens/voice_engine.dart';
import 'package:admin_app/pages/splash_screen.dart';
import 'package:admin_app/pages/survey/survey_control_screen.dart';
import 'package:admin_app/pages/survey/survey_screen.dart';
import 'package:admin_app/services/providers/anomaly_provider.dart';
import 'package:admin_app/services/providers/anomaly_websocket_provider.dart';
import 'package:admin_app/services/providers/map_controller_provider.dart';
import 'package:admin_app/services/providers/permissions.dart';
import 'package:admin_app/services/providers/route_provider.dart';
import 'package:admin_app/services/providers/search.dart';
import 'package:admin_app/services/providers/user_settings.dart';
import 'package:admin_app/theme/theme.dart';
import 'package:admin_app/theme/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables.
  // await dotenv.load(fileName: ".env");

  Future<Map<String, String?>> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "isDev": prefs.getString("isDev"),
      "isUser": prefs.getString("isUser"),
    };
  }

  Map<String, String?> currentPrefs = await loadPrefs();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Permissions()),
        ChangeNotifierProvider(create: (context) => Search()),
        ChangeNotifierProvider(create: (context) => UserSettingsProvider()),
        ChangeNotifierProvider(create: (context) => RouteProvider()),
        ChangeNotifierProvider(create: (context) => AnomalyProvider()),
        ChangeNotifierProvider(create: (context) => MapControllerProvider()),
        ChangeNotifierProvider(create: (context) => AnomalyWebSocketProvider()),
      ],
      child: Phoenix(
        child:
            MyApp(isDev: currentPrefs["isDev"], isUser: currentPrefs["isUser"]),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String? isDev, isUser;

  const MyApp({super.key, required this.isDev, required this.isUser});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<UserSettingsProvider>(context);
    TextTheme textTheme = createTextTheme(context, "Albert Sans", "ABeeZee");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(0.8)),
      child: MaterialApp(
          themeMode: settings.themeMode,
          theme: theme.light(),
          darkTheme: theme.dark(),
          debugShowCheckedModeBanner: false,
          home: widget.isDev == null && widget.isUser == null
              ? LoginPage()
              : const SplashScreen(),
          routes: {
            '/login': (context) => LoginPage(),
            '/home': (context) => const HomeScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/toggle_anomalies': (context) => const ToggleAnomaliesScreen(),
            '/routines': (context) => const RoutinesScreen(),
            '/voice_engine': (context) => const VoiceEngineScreen(),
            '/additional_settings': (context) => const AdditionalSettings(),
            '/navigation_preferences': (context) =>
                const NavigationPreferences(),
            '/survey': (context) => SurveyScreen(),
            '/survey_controls': (context) => SurveyControlScreen(),
          }),
    );
  }
}

import 'package:admin_app/pages/home_screen.dart';
import 'package:admin_app/pages/login_page.dart';
import 'package:admin_app/pages/settings_screen.dart';
import 'package:admin_app/pages/settings_screens/additional_settings.dart';
import 'package:admin_app/pages/settings_screens/navigation_preferences.dart';
import 'package:admin_app/pages/settings_screens/routines.dart';
import 'package:admin_app/pages/settings_screens/toggle_anomalies.dart';
import 'package:admin_app/pages/settings_screens/voice_engine.dart';
import 'package:admin_app/services/providers/permissions.dart';
import 'package:admin_app/services/providers/route_provider.dart';
import 'package:admin_app/services/providers/search.dart';
import 'package:admin_app/services/providers/user_settings.dart';
import 'package:admin_app/theme/theme.dart';
import 'package:admin_app/theme/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/restart_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // to use .env
  await dotenv.load(fileName: ".env");

  // This allows flutter_map caching
  await FMTCObjectBoxBackend().initialise();
  // mapStore is a specialized container that is used to store Tiles (caching)
  await const FMTCStore('mapStore').manage.create();

  final prefs = await SharedPreferences.getInstance();
  String? isDev = prefs.getString("isDev");

  runApp(
    RestartWidget(  // Wrap the entire app inside RestartWidget
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Permissions()),
          ChangeNotifierProvider(create: (context) => Search()),
          ChangeNotifierProvider(create: (context) => UserSettingsProvider()),
          ChangeNotifierProvider(create: (context) => MapRouteProvider()),
        ],
        child: MyApp(isDev: isDev),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String? isDev;
  const MyApp({super.key, required this.isDev});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<UserSettingsProvider>(context);
    TextTheme textTheme = createTextTheme(context, "Albert Sans", "ABeeZee");
    MaterialTheme theme = MaterialTheme(textTheme);
    return MaterialApp(
        themeMode: settings.themeMode,
        theme: theme.light(),
        darkTheme: theme.dark(),
        debugShowCheckedModeBanner: false,
        home: widget.isDev == null ? LoginPage() : const HomeScreen(),
        routes: {
          '/login': (context) => LoginPage(),
          '/home': (context) => const HomeScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/toggle_anomalies': (context) => const ToggleAnomaliesScreen(),
          '/routines': (context) => const RoutinesScreen(),
          '/voice_engine': (context) => const VoiceEngineScreen(),
          '/additional_settings': (context) => const AdditionalSettings(),
          '/navigation_preferences': (context) => const NavigationPreferences(),
        });
  }
}

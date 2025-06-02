import 'package:app/pages/map_route_screen.dart';
import 'package:app/pages/settings_screen.dart';
import 'package:app/pages/settings_screens/additional_settings.dart';
import 'package:app/pages/settings_screens/navigation_preferences.dart';
import 'package:app/pages/settings_screens/routines.dart';
import 'package:app/pages/settings_screens/toggle_anomalies.dart';
import 'package:app/pages/settings_screens/voice_engine.dart';
import 'package:app/pages/splash_screen.dart';
import 'package:app/services/providers/anomaly_provider.dart';
import 'package:app/services/providers/anomaly_websocket_provider.dart';
import 'package:app/services/providers/map_controller_provider.dart';
import 'package:app/services/providers/permissions.dart';
import 'package:app/services/providers/route_provider.dart';
import 'package:app/services/providers/search.dart';
import 'package:app/services/providers/user_settings.dart';
import 'package:app/theme/theme.dart';
import 'package:app/theme/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';

import 'components/anomaly_image_uploader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        // permissions provider to handle permissions
        ChangeNotifierProvider(create: (context) => Permissions()),
        ChangeNotifierProvider(create: (context) => Search()),
        ChangeNotifierProvider(create: (context) => UserSettingsProvider()),
        ChangeNotifierProvider(create: (context) => RouteProvider()),
        ChangeNotifierProvider(create: (context) => AnomalyProvider()),
        ChangeNotifierProvider(create: (context) => MapControllerProvider()),
        ChangeNotifierProvider(create: (context) => AnomalyWebSocketProvider()),
      ],
      child: Phoenix(
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme related logic (NEED TO MOVE THIS)
    final themeMode = context.select<UserSettingsProvider, ThemeMode>(
      (settings) => settings.themeMode,
    );
    TextTheme textTheme = createTextTheme(context, "Albert Sans", "ABeeZee");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(0.8)),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        themeMode: themeMode,
        theme: theme.light(),
        darkTheme: theme.dark(),
        routes: {
          '/settings': (context) => const SettingsScreen(),
          '/toggle_anomalies': (context) => const ToggleAnomaliesScreen(),
          '/routines': (context) => const RoutinesScreen(),
          '/voice_engine': (context) => const VoiceEngineScreen(),
          '/additional_settings': (context) => const AdditionalSettings(),
          '/map_route': (context) => const MapRouteScreen(),
          '/navigation_preferences': (context) => const NavigationPreferences(),
          '/capture': (context) => AnomalyImageUploader(),
        },
      ),
    );
  }
}

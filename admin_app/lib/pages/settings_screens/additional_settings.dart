import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/providers/user_settings.dart';

class AdditionalSettings extends StatelessWidget {
  const AdditionalSettings({super.key});

  void openBatteryOptimizationSettings(context) async {
    if (Platform.isAndroid) {
      const intent = AndroidIntent(
        action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
        data: 'package:com.example.app',
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<UserSettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Additional Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            trailing: Icon(
              Icons.arrow_forward_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Toggle Battery Optimization'),
            subtitle: const Text(
                'Battery Optimization may prevent normal operation of the app. To avoid issues we recommend disabling it.'),
            onTap: () => openBatteryOptimizationSettings(context),
          ),
          ListTile(
            title: const Text("Theme"),
            subtitle: const Text(
                "Choose between Light mode or Dark mode or select System to default to your system theme."),
            trailing: DropdownButton<ThemeMode>(
              borderRadius: BorderRadius.circular(15),
              value: settings.themeMode,
              onChanged: (ThemeMode? newMode) {
                if (newMode != null) {
                  settings.setThemeMode(newMode);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text("System"),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text("Light"),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text("Dark"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

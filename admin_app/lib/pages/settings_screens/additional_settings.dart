import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Additional Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            trailing: const Icon(Icons.arrow_forward_rounded),
            title: const Text('Toggle Battery Optimization'),
            subtitle: const Text(
                'Battery Optimization may prevent normal operation of the app. To avoid issues we recommend disabling it.'),
            onTap: () => openBatteryOptimizationSettings(context),
          )
        ],
      ),
    );
  }
}

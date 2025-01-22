import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/providers/user_settings.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  @override
  Widget build(BuildContext context) {
    final userSettings = Provider.of<UserSettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routines'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('Auto Detect Routines'),
            subtitle: const Text(
                'Let maps auto start and alert you about anomalies when travelling along a daily route'),
            trailing: Switch(
              value: userSettings.autoDetectRoutines,
              onChanged: (value) {
                userSettings.toggleAutoDetectRoutines();
              },
            ),
          ),
        ],
      ),
    );
  }
}

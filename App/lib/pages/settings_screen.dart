import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Toggle Anomalies'),
            leading: const Icon(LucideIcons.toggleRight),
            onTap: () {
              Navigator.pushNamed(context, '/toggle_anomalies');
            },
          ),
          ListTile(
            title: const Text('Routines'),
            leading: const Icon(LucideIcons.bot),
            onTap: () {
              Navigator.pushNamed(context, '/routines');
            },
          ),
          ListTile(
            title: const Text('Voice Engine'),
            leading: const Icon(Icons.record_voice_over),
            onTap: () {
              Navigator.pushNamed(context, '/voice_engine');
            },
          ),
          ListTile(
            title: const Text('Additional Settings'),
            leading: const Icon(LucideIcons.circleEllipsis),
            onTap: () {
              Navigator.pushNamed(context, '/additional_settings');
            },
          ),
        ],
      ),
    );
  }
}

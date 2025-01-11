import 'package:flutter/material.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  @override
  Widget build(BuildContext context) {
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
            trailing: Switch(value: true, onChanged: (value) {/* TODO */}),
          ),
        ],
      ),
    );
  }
}

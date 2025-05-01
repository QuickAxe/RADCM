import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SurveyControlScreen extends StatelessWidget {
  const SurveyControlScreen({super.key});

  Future<void> sendCommand(String command) async {
    const url = 'http://raspberrypi.local:3333';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'command': command}),
      );

      if (response.statusCode == 200) {
        debugPrint('Command "$command" sent successfully');
      } else {
        debugPrint('Failed to send command "$command": ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending command "$command": $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Controls'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => sendCommand("start"),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Survey'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => sendCommand("stop"),
              icon: const Icon(Icons.stop_rounded),
              label: const Text('Stop Survey'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => sendCommand("stop"),
              icon: const Icon(Icons.upload_rounded),
              label: const Text('Submit Images'),
            ),
          ],
        ),
      ),
    );
  }
}

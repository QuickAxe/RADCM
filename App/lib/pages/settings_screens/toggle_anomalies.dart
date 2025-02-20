import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/providers/user_settings.dart';

class ToggleAnomaliesScreen extends StatelessWidget {
  const ToggleAnomaliesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<UserSettingsProvider>(context);
    List<Map<String, String>> anomalies = [
      {"name": "Pothole", "icon": "assets/icons/ic_pothole.png"},
      {"name": "Speedbreaker", "icon": "assets/icons/ic_speedbreaker.png"},
      {"name": "Rumbler", "icon": "assets/icons/ic_rumbler.png"},
      // {"name": "Obstacle", "icon": "assets/icons/ic_obstacle.png"},
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Toggle Anomalies'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text('Toggle Settings for additional anomalies.'),
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: anomalies.length,
                itemBuilder: (context, index) {
                  final anomaly = anomalies[index]["name"]!;
                  final iconPath = anomalies[index]["icon"]!;
                  final showOnMap = settings.showOnMap[anomaly]!;
                  final alertWhileRiding = settings.alertWhileRiding[anomaly]!;
                  return ListTile(
                    onTap: () => _showAnomalyDialog(
                        context, anomaly, iconPath, settings),
                    leading: Image.asset(iconPath, width: 32, height: 32),
                    title: Text(anomaly),
                    subtitle: Text(
                      "${showOnMap ? 'Show on Map, ' : ''}${alertWhileRiding ? 'Alert while riding' : ''}",
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

void _showAnomalyDialog(BuildContext context, String anomaly, String iconPath,
    UserSettingsProvider settings) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // why not directly alert, cuz we wanna update the ui (alert creates a new tree)
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Image.asset(iconPath, width: 32, height: 32),
                const SizedBox(width: 10),
                Text(anomaly),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text("Show on Map"),
                  subtitle:
                      const Text("View the anomaly on the map as an icon"),
                  value: settings.showOnMap[anomaly]!,
                  onChanged: (value) {
                    settings.toggleShowOnMap(anomaly);
                    setState(() {});
                  },
                ),
                SwitchListTile(
                  title: const Text("Alert while riding"),
                  subtitle: const Text(
                      "Get alerted about this anomaly when navigating"),
                  value: settings.alertWhileRiding[anomaly]!,
                  onChanged: (value) {
                    settings.toggleAlertWhileRiding(anomaly);
                    setState(() {});
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Done"),
              ),
            ],
          );
        },
      );
    },
  );
}

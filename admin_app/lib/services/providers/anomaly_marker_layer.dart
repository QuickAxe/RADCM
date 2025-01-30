import 'package:admin_app/services/providers/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../../data/models/anomaly_marker.dart';
import '../anomaly_marker_service.dart';

// This is the layer that displays the anomalies
class AnomalyMarkerLayer extends StatelessWidget {
  const AnomalyMarkerLayer({super.key});

  // gets the appropriate icon (image asset path) TODO: Mapping redundant, also exists in settings create a single src
  String getAnomalyIcon(String cat) {
    String imageAssetPath = switch (cat) {
      "Speedbreaker" => "assets/icons/ic_speedbreaker.png",
      "Rumbler" => "assets/icons/ic_rumbler.png",
      "Obstacle" => "assets/icons/ic_obstacle.png",
      _ => "assets/icons/ic_obstacle.png",
    };
    return imageAssetPath;
  }

  void _showAnomalyDialog(BuildContext context, AnomalyMarker anomaly) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(anomaly.category),
          content: Text(anomaly.location.toString()),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Ok")),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // consumes filter because the markers displayed must react to change in filters
    return Consumer<UserSettingsProvider>(
      builder: (context, userSettings, child) {
        // filters list first
        List<AnomalyMarker> visibleAnomalies = AnomalyService.anomalies
            .where(
                (anomaly) => userSettings.showOnMap[anomaly.category] ?? true)
            .toList();

        return MarkerLayer(
          // anomalies from the service class
          markers: visibleAnomalies.map((anomaly) {
            return Marker(
                rotate: true, // so the icon stays upright
                point: anomaly.location,
                child: GestureDetector(
                  onTap: () => _showAnomalyDialog(context, anomaly),
                  child: Image.asset(
                    getAnomalyIcon(anomaly.category),
                    width: 20.0,
                    height: 20.0,
                  ),
                ));
          }).toList(),
        );
      },
    );
  }
}

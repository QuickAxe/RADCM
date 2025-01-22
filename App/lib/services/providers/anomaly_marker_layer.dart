import 'package:app/services/anomaly_marker_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../../data/models/anomaly_marker.dart';
import 'filters.dart';

// This is the layer that displays the anomalies
class AnomalyMarkerLayer extends StatelessWidget {
  const AnomalyMarkerLayer({super.key});

  // gets the appropriate icon (image asset path)
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
    return Consumer<Filters>(
      builder: (context, filters, child) {
        // filters list first
        List<AnomalyMarker> filteredAnomalies;
        if (filters.selectedFilter == "All") {
          filteredAnomalies = AnomalyService.anomalies;
        } else {
          filteredAnomalies = AnomalyService.anomalies
              .where((anomaly) => anomaly.category == filters.selectedFilter)
              .toList();
        }

        return MarkerLayer(
          // anomalies from the service class
          markers: filteredAnomalies.map((anomaly) {
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

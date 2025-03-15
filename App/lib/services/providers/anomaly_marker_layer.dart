import 'package:app/services/anomaly_marker_service.dart';
import 'package:app/services/providers/user_settings.dart';
import 'package:app/util/map_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

import '../../data/models/anomaly_marker_model.dart';

// This is the layer that displays the anomalies
class AnomalyMarkerLayer extends StatelessWidget {
  const AnomalyMarkerLayer({super.key});

  // this is for the marker clusters, color increases with more and more anomalies
  Color _getClusterColor(int count) {
    if (count < 5) {
      return Colors.yellow.withOpacity(0.7); // Few anomalies
    } else if (count < 10) {
      return Colors.orange.withOpacity(0.7); // Moderate anomalies
    } else {
      return Colors.red.withOpacity(0.7); // High number of anomalies
    }
  }

  // gets the appropriate icon (image asset path) TODO: Mapping redundant, also exists in settings create a single src
  String getAnomalyIcon(String cat) {
    String imageAssetPath = switch (cat) {
      "Speedbreaker" => "assets/icons/ic_speedbreaker.png",
      "Rumbler" => "assets/icons/ic_rumbler.png",
      // "Obstacle" => "assets/icons/ic_obstacle.png",
      "Pothole" => "assets/icons/ic_pothole.png",
      _ => "assets/icons/ic_pothole.png",
    };
    return imageAssetPath;
  }

  Future<void> _showAnomalyDialog(
      BuildContext context, AnomalyMarker anomaly) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        anomaly.location.latitude, anomaly.location.longitude);
    print(placemarks.toString());
    String address = "Address not available";

    if (placemarks.isNotEmpty) {
      address =
          "${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country}";
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(child: Text(anomaly.category)),
          content: Text(address),
          actions: [
            ElevatedButton(
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

        List<Marker> markers = visibleAnomalies.map((anomaly) {
          return Marker(
            rotate: true,
            point: anomaly.location,
            child: GestureDetector(
              onTap: () => _showAnomalyDialog(context, anomaly),
              child: mapMarkerIcon(getAnomalyIcon(anomaly.category),
                  Theme.of(context).colorScheme.outline.withOpacity(0.5)),
            ),
          );
        }).toList();

        return MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 45, // Adjust clustering sensitivity
            size: const Size(40, 40), // Cluster icon size
            zoomToBoundsOnClick: true,
            padding: const EdgeInsets.fromLTRB(50.0, 150.0, 50.0, 300.0),
            rotate: true,
            markers: markers,
            builder: (context, markers) {
              Color clusterColor = _getClusterColor(markers.length);

              return Container(
                decoration: BoxDecoration(
                  color: clusterColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    markers.length.toString(),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

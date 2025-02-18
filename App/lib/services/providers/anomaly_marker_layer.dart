import 'package:app/services/anomaly_marker_service.dart';
import 'package:app/services/providers/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

import '../../data/models/anomaly_marker.dart';

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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shadow layer (placed behind the image)
                  Container(
                    width: 50, // Slightly larger than the image
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .inversePrimary
                              .withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(2, 3),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    getAnomalyIcon(anomaly.category),
                    width: 60.0,
                    height: 60.0,
                  ),
                ],
              ),
            ),
          );
        }).toList();

        return MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 45, // Adjust clustering sensitivity
            size: const Size(40, 40), // Cluster icon size
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

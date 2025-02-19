import 'package:admin_app/services/providers/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:provider/provider.dart';

import '../../data/models/anomaly_marker.dart';
import '../../pages/anomaly_detail_page.dart';
import '../../utils/marker_utils.dart';
import '../anomaly_marker_service.dart';

// This is the layer that displays the anomalies
class AnomalyMarkerLayer extends StatelessWidget {
  const AnomalyMarkerLayer({super.key});

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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnomalyDetailPage(anomaly: anomaly),
                  ),
                );
              },
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
                  // Actual Marker Image
                  Image.asset(
                    getAnomalyIcon(anomaly.category),
                    width: 60.0, // Slightly bigger for visibility
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
              Color clusterColor = getClusterColor(markers.length);

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

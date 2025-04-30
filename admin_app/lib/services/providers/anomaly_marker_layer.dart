import 'package:admin_app/services/providers/user_settings.dart';
import 'package:admin_app/utils/map_utils.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
              child: mapMarkerIcon(
                  getAnomalyIcon(anomaly.category), colorScheme.surfaceDim),
            ),
          );
        }).toList();

        return MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            showPolygon: false,
            maxClusterRadius: 45, // Adjust clustering sensitivity
            size: const Size(40, 40), // Cluster icon size
            zoomToBoundsOnClick: true,
            padding: const EdgeInsets.fromLTRB(50.0, 150.0, 50.0, 300.0),
            rotate: true,
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

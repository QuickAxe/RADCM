import 'package:app/services/providers/anomaly_provider.dart';
import 'package:app/services/providers/user_settings.dart';
import 'package:app/util/map_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:provider/provider.dart';

import '../../data/models/anomaly_marker_model.dart';

class AnomalyMarkerLayer extends StatelessWidget {
  const AnomalyMarkerLayer({super.key});

  Color _getClusterColor(int count) {
    if (count < 5) {
      return Colors.yellow.withOpacity(0.7);
    } else if (count < 10) {
      return Colors.orange.withOpacity(0.7);
    } else {
      return Colors.red.withOpacity(0.7);
    }
  }

  String getAnomalyIcon(String cat) {
    return switch (cat) {
      "Speedbreaker" => "assets/icons/ic_speedbreaker.png",
      "Rumbler" => "assets/icons/ic_rumbler.png",
      "Pothole" => "assets/icons/ic_pothole.png",
      _ => "assets/icons/ic_pothole.png",
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSettingsProvider>(
      builder: (context, userSettings, child) {
        return ValueListenableBuilder<List<AnomalyMarker>>(
          valueListenable: context.watch<AnomalyProvider>().markersNotifier,
          builder: (context, visibleAnomalies, child) {
            List<Marker> markers = visibleAnomalies
                .where((anomaly) =>
                    userSettings.showOnMap[anomaly.category] ?? true)
                .map((anomaly) {
              return Marker(
                rotate: true,
                point: anomaly.location,
                child: mapMarkerIcon(
                  getAnomalyIcon(anomaly.category),
                  Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
              );
            }).toList();

            return MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: 5,
                size: const Size(40, 40),
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
      },
    );
  }
}

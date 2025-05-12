import 'package:app/services/providers/anomaly_provider.dart';
import 'package:app/services/providers/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:provider/provider.dart';

import '../../data/models/anomaly_marker_model.dart';
import '../../util/map_utils.dart';

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
    "SpeedBreaker" => "assets/icons/ic_speedbreaker.png",
    "Rumbler" => "assets/icons/ic_rumbler.png",
    "Pothole" => "assets/icons/ic_pothole.png",
    "Cracks" => "assets/icons/ic_cracks.png",
    _ => "assets/icons/ic_pothole.png",
  };
}

class AnomalyMarkerLayer extends StatefulWidget {
  final MapController mapController;
  final int clusteringRadius;
  const AnomalyMarkerLayer({
    super.key,
    required this.mapController,
    required this.clusteringRadius,
  });

  @override
  State<AnomalyMarkerLayer> createState() => _AnomalyMarkerLayerState();
}

class _AnomalyMarkerLayerState extends State<AnomalyMarkerLayer>
    with TickerProviderStateMixin {
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
                  alignment: Alignment.topCenter,
                  child: Builder(builder: (BuildContext markerContext) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(anomaly.category),
                            icon: SizedBox(
                              width: 40,
                              height: 40,
                              child: mapMarkerIcon(
                                getAnomalyIcon(anomaly.category),
                                Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.0),
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${anomaly.category} has been reported in this area.",
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                      context, '/toggle_anomalies');
                                },
                                child: const Text('Toggle visibility'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Ok'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: mapMarkerIcon(
                        getAnomalyIcon(anomaly.category),
                        Theme.of(context).colorScheme.outline.withOpacity(0.5),
                      ),
                    );
                  }));
            }).toList();

            return MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                showPolygon: false,
                maxClusterRadius: widget.clusteringRadius,
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

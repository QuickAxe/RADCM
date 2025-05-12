import 'package:admin_app/services/providers/anomaly_provider.dart';
import 'package:admin_app/services/providers/user_settings.dart';
import 'package:admin_app/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:provider/provider.dart';

import '../../data/models/anomaly_marker_model.dart';
import '../../pages/anomaly_detail_page.dart';
import '../../utils/map_utils.dart';

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
  const AnomalyMarkerLayer({super.key});

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
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AnomalyDetailPage(anomaly: anomaly),
                      ),
                    );
                  },
                  child: mapMarkerIcon(getAnomalyIcon(anomaly.category),
                      context.colorScheme.surfaceDim),
                ),
              );
            }).toList();

            return MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                showPolygon: false,
                // COMPARE
                // maxClusterRadius: widget.clusteringRadius,
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

// import 'package:admin_app/services/providers/user_settings.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
// import 'package:provider/provider.dart';
//
// import '../../pages/anomaly_detail_page.dart';
// import '../../utils/map_utils.dart';
// import '../../utils/marker_utils.dart';
// import '../anomaly_marker_service.dart';
//
// // This is the layer that displays the anomalies
// class AnomalyMarkerLayer extends StatelessWidget {
//   const AnomalyMarkerLayer({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     // consumes filter because the markers displayed must react to change in filters
//     return Consumer<UserSettingsProvider>(
//       builder: (context, userSettings, child) {
//         // filters list first
//         List<AnomalyMarker> visibleAnomalies = AnomalyService.anomalies
//             .where(
//                 (anomaly) => userSettings.showOnMap[anomaly.category] ?? true)
//             .toList();
//
//         List<Marker> markers = visibleAnomalies.map((anomaly) {
//           return Marker(
//             rotate: true,
//             point: anomaly.location,
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => AnomalyDetailPage(anomaly: anomaly),
//                   ),
//                 );
//               },
//               child: mapMarkerIcon(
//                   getAnomalyIcon(anomaly.category), colorScheme.surfaceDim),
//             ),
//           );
//         }).toList();
//
//         return MarkerClusterLayerWidget(
//           options: MarkerClusterLayerOptions(
//             showPolygon: false,
//             maxClusterRadius: 45, // Adjust clustering sensitivity
//             size: const Size(40, 40), // Cluster icon size
//             zoomToBoundsOnClick: true,
//             padding: const EdgeInsets.fromLTRB(50.0, 150.0, 50.0, 300.0),
//             rotate: true,
//             markers: markers,
//             builder: (context, markers) {
//               Color clusterColor = getClusterColor(markers.length);
//
//               return Container(
//                 decoration: BoxDecoration(
//                   color: clusterColor,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Center(
//                   child: Text(
//                     markers.length.toString(),
//                     style: const TextStyle(
//                       color: Colors.black87,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

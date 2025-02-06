import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/providers/anomaly_marker_layer.dart';
import '../../services/providers/route_provider.dart';
import '../../util/route_utils.dart';
import 'route_directions.dart';

class RouteSelectionMode extends StatelessWidget {
  final MapRouteProvider mapProvider;
  final MapController mapController;

  const RouteSelectionMode(
      {super.key, required this.mapController, required this.mapProvider});

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
      minHeight: 200,
      maxHeight: 700,
      panel: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select a Route",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            // List of routes
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mapProvider.routes.length,
              itemBuilder: (context, index) {
                final route = mapProvider.routes[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: getColorForRoute(index),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    "Route ${index + 1}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    "Distance: ${formatDistance(route.distance)} | Duration: ${formatDuration(route.duration)}",
                  ),
                  selected: mapProvider.selectedRouteIndex == index,
                  onTap: () {
                    mapProvider.updateSelectedRoute(index);
                    mapController.fitCamera(
                      CameraFit.bounds(
                        bounds: mapProvider.bounds,
                        padding: const EdgeInsets.all(50.0),
                      ),
                    );
                  },
                );
              },
            ),
            const Divider(),
            const SizedBox(height: 10),
            if (mapProvider.selectedRouteIndex >= 0 &&
                mapProvider.selectedRouteIndex < mapProvider.routes.length)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        "Directions",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      RouteDirections(route: mapProvider.currentRoute),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: LatLng(mapProvider.startLat, mapProvider.startLng),
          initialZoom: 14.0,
        ),
        children: [
          TileLayer(
            panBuffer: 0,
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
            tileProvider: FMTCTileProvider(
              stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
            ),
          ),
          // Draw all alternative routes.
          PolylineLayer(
            polylines: [
              for (int i = 0; i < mapProvider.alternativeRoutes.length; i++)
                Polyline(
                  points: mapProvider.alternativeRoutes[i],
                  strokeWidth: mapProvider.selectedRouteIndex == i ? 6.0 : 4.0,
                  color: mapProvider.selectedRouteIndex == i
                      ? getColorForRoute(i).withOpacity(0.8)
                      : getColorForRoute(i).withOpacity(0.5),
                ),
            ],
          ),
          const AnomalyMarkerLayer(),
          Positioned(
            left: 200,
            bottom: 200,
            child: RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () => launchUrl(
                      Uri.parse('https://openstreetmap.org/copyright')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

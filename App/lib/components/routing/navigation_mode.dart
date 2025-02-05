import 'package:app/components/routing/route_directions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/providers/anomaly_marker_layer.dart';
import '../../services/providers/route_provider.dart';
import '../../util/route_utils.dart';

class NavigationMode extends StatelessWidget {
  final MapRouteProvider mapProvider;
  final MapController mapController;

  const NavigationMode(
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
          children: [
            ListTile(
              title: Text(
                "Route ${mapProvider.selectedRouteIndex + 1}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Distance: ${formatDistance(mapProvider.currentRoute.distance)} | Duration: ${formatDuration(mapProvider.currentRoute.duration)}",
              ),
            ),
            const Divider(),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      "Detailed Directions",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
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
          initialZoom: 18.0,
          minZoom: 3.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),

          const AnomalyMarkerLayer(),
          // Draw the selected route.
          PolylineLayer(
            polylines: [
              Polyline(
                points: mapProvider.currentRoutePoints,
                strokeWidth: 6.0,
                color: getColorForRoute(mapProvider.selectedRouteIndex)
                    .withOpacity(0.8),
              ),
            ],
          ),
          CurrentLocationLayer(
            alignPositionOnUpdate: AlignOnUpdate.always,
            alignDirectionOnUpdate: AlignOnUpdate.always,
            alignDirectionAnimationCurve: Curves.easeInOut,
            style: const LocationMarkerStyle(
              marker: DefaultLocationMarker(
                child: Icon(
                  Icons.navigation,
                  color: Colors.white,
                ),
              ),
              markerSize: Size(40, 40),
            ),
          ),
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

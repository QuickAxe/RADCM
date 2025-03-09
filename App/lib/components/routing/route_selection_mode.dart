import 'package:app/components/OSM_Attribution.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../services/providers/anomaly_marker_layer.dart';
import '../../services/providers/route_provider.dart';
import '../../services/providers/user_settings.dart';
import '../../util/map_utils.dart';
import '../../util/route_utils.dart';
import 'route_directions.dart';

class RouteSelectionMode extends StatelessWidget {
  final RouteProvider routeProvider;
  final MapController mapController;

  const RouteSelectionMode(
      {super.key, required this.mapController, required this.routeProvider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeMode = context.select<UserSettingsProvider, ThemeMode>(
      (settings) => settings.themeMode,
    );

    return SlidingUpPanel(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
      minHeight: 200,
      maxHeight: 700,
      panel: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: routeProvider.routeAvailable
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Indicator
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Text(
                    "Select a Route",
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  // List of routes
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: routeProvider.alternativeRoutes.length,
                    itemBuilder: (context, index) {
                      final route = routeProvider.alternativeRoutes[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: getColorForRoute(index),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          "Route ${index + 1}",
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Distance: ${route.distance != null ? formatDistance(route.distance!) : "N/A"} | "
                          "Duration: ${route.duration != null ? formatDuration(route.duration!) : "N/A"}",
                        ),
                        selected: routeProvider.selectedRouteIndex == index,
                        onTap: () {
                          routeProvider.updateSelectedRoute(index);
                          mapController.fitCamera(
                            CameraFit.bounds(
                              bounds: routeProvider.bounds,
                              padding: const EdgeInsets.all(50.0),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  if (routeProvider.selectedRouteIndex >= 0 &&
                      routeProvider.selectedRouteIndex <
                          routeProvider.currentRouteSegments.length)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              "Directions",
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            RouteDirections(route: routeProvider.currentRoute),
                          ],
                        ),
                      ),
                    ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  "No Routes",
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: LatLng(routeProvider.startLat, routeProvider.startLng),
          initialZoom: 14.0,
        ),
        children: [
          TileLayer(
            panBuffer: 0,
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            // retinaMode: true,
            tileBuilder:
                themeMode == ThemeMode.dark ? customDarkModeTileBuilder : null,
            userAgentPackageName: 'com.example.app',
            tileProvider: FMTCTileProvider(
              stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
            ),
          ),
          // Draw all alternative routes.
          PolylineLayer(
            polylines: [
              for (int i = 0; i < routeProvider.alternativeRoutes.length; i++)
                Polyline(
                  points: routeProvider.alternativeRoutes[i].segments
                      .expand((segment) => segment.geometry.coordinates)
                      .toList(),
                  strokeWidth:
                      routeProvider.selectedRouteIndex == i ? 6.0 : 4.0,
                  color: routeProvider.selectedRouteIndex == i
                      ? getColorForRoute(i).withOpacity(0.8)
                      : getColorForRoute(i).withOpacity(0.5),
                ),
            ],
          ),
          const AnomalyMarkerLayer(),
          const Positioned(
            left: 200,
            bottom: 200,
            child: Attribution(),
          ),
        ],
      ),
    );
  }
}

import 'package:app/components/routing/dynamic_route_directions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/providers/anomaly_marker_layer.dart';
import '../../services/providers/route_provider.dart';
import '../../services/providers/user_settings.dart';
import '../../util/map_utils.dart';
import '../../util/route_utils.dart';

class NavigationMode extends StatelessWidget {
  final MapRouteProvider mapProvider;
  final MapController mapController;
  const NavigationMode(
      {super.key, required this.mapController, required this.mapProvider});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<UserSettingsProvider, ThemeMode>(
      (settings) => settings.themeMode,
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SlidingUpPanel(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
      minHeight: 200,
      maxHeight: 200,
      panel: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    "Next Move",
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  DynamicRouteDirections(route: mapProvider.currentRoute),
                ],
              ),
              // ),
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
            panBuffer: 0,
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            tileBuilder:
                themeMode == ThemeMode.dark ? customDarkModeTileBuilder : null,
            userAgentPackageName: 'com.example.app',
            // This part allows caching tiles
            tileProvider: FMTCTileProvider(
              stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
            ),
          ),
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
          const AnomalyMarkerLayer(),
          CurrentLocationLayer(
            alignPositionOnUpdate: AlignOnUpdate.always,
            alignDirectionOnUpdate: AlignOnUpdate.always,
            alignDirectionAnimationCurve: Curves.easeInOut,
            style: LocationMarkerStyle(
              accuracyCircleColor: colorScheme.primary.withOpacity(0.2),
              headingSectorColor: colorScheme.primary.withOpacity(0.4),
              marker: DefaultLocationMarker(
                color: colorScheme.primary,
                child: Icon(
                  Icons.navigation,
                  color: colorScheme.onPrimary,
                ),
              ),
              markerSize: const Size(40, 40),
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

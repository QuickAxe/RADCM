import 'package:admin_app/components/OSM_Attribution.dart';
import 'package:admin_app/components/routing/dynamic_route_directions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../services/providers/anomaly_marker_layer.dart';
import '../../services/providers/route_provider.dart';
import '../../services/providers/user_settings.dart';
import '../../utils/fix_anomaly_dialog.dart';
import '../../utils/map_utils.dart';
import '../../utils/route_utils.dart';

class NavigationMode extends StatefulWidget {
  final MapRouteProvider mapProvider;
  final MapController mapController;
  final double endLat;
  final double endLng;
  const NavigationMode({
    super.key,
    required this.mapController,
    required this.mapProvider,
    required this.endLat,
    required this.endLng,
  });

  @override
  State<NavigationMode> createState() => _NavigationModeState();
}

class _NavigationModeState extends State<NavigationMode> {
  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<UserSettingsProvider, ThemeMode>(
      (settings) => settings.themeMode,
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = Provider.of<UserSettingsProvider>(context, listen: false);
    return SlidingUpPanel(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
      minHeight: 200,
      maxHeight: 400,
      // NOTE: Change the maxHeight if content overflows (Alternatively, adjust the text style)
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
                  DynamicRouteDirections(
                      route: widget.mapProvider.currentRoute),
                ],
              ),
            ),
          ],
        ),
      ),
      body: FlutterMap(
        mapController: widget.mapController,
        options: MapOptions(
          initialCenter:
              LatLng(widget.mapProvider.startLat, widget.mapProvider.startLng),
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
                points: widget.mapProvider.currentRoutePoints,
                strokeWidth: 6.0,
                color: getColorForRoute(widget.mapProvider.selectedRouteIndex)
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
          const Positioned(
            left: 200,
            bottom: 200,
            child: Attribution(),
          ),
          Positioned(
            left: 85,
            bottom: 210,
            child: FloatingActionButton(
              heroTag: "voice_toggle",
              onPressed: () => settings.toggleVoiceEnabled(),
              backgroundColor: settings.voiceEnabled
                  ? colorScheme.secondaryContainer
                  : colorScheme.tertiaryContainer,
              tooltip: settings.voiceEnabled
                  ? "Mute Voice Notifications"
                  : "Enable Voice Notifications",
              elevation: 6,
              child: Icon(
                settings.voiceEnabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                color: settings.voiceEnabled
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onTertiaryContainer,
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 210,
            child: FloatingActionButton(
              heroTag: "fix_anomaly",
              onPressed: () {
                showAnomalyDialog(context, widget.endLat, widget.endLng);
              },
              tooltip: "Fix Anomaly",
              elevation: 6,
              child: const Icon(
                Icons.construction_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

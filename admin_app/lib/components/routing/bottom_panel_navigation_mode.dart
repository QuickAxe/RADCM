import 'package:admin_app/components/attribution.dart';
import 'package:admin_app/components/routing/dynamic_route_directions.dart';
import 'package:admin_app/constants.dart';
import 'package:admin_app/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../data/models/anomaly_marker_model.dart';
import '../../services/providers/anomaly_marker_layer.dart';
import '../../services/providers/route_provider.dart';
import '../../services/providers/user_settings.dart';
import '../../utils/fix_anomaly_dialog.dart';
import '../../utils/map_utils.dart';
import '../../utils/route_utils.dart';
import 'anomaly_alerts.dart';

class NavigationMode extends StatefulWidget {
  final RouteProvider mapProvider;
  final MapController mapController;
  final double endLat;
  final double endLng;
  final AnomalyMarker?
      anomaly; // if null means navigating to some place, otherwise navigating to an anomaly

  const NavigationMode({
    super.key,
    required this.mapController,
    required this.mapProvider,
    required this.endLat,
    required this.endLng,
    this.anomaly,
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
    final screenHeight = MediaQuery.of(context).size.height;

    return SlidingUpPanel(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
      minHeight: screenHeight * 0.18,
      maxHeight: screenHeight * 0.3,
      // NOTE: Change the maxHeight if content overflows (Alternatively, adjust the text style)
      panel: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  // Text(
                  //   "Next Move",
                  //   style: theme.textTheme.headlineSmall
                  //       ?.copyWith(fontWeight: FontWeight.bold),
                  // ),
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
          interactionOptions: const InteractionOptions(
            enableMultiFingerGestureRace: true,
            flags: InteractiveFlag.all,
          ),
          initialCenter:
              LatLng(widget.mapProvider.startLat, widget.mapProvider.startLng),
          initialZoom: defaultZoom,
          minZoom: minZoom,
          maxZoom: maxZoom,
        ),
        children: [
          TileLayer(
            panBuffer: 0,
            urlTemplate: tileServerUrl,
            tileBuilder:
                themeMode == ThemeMode.dark ? customDarkModeTileBuilder : null,
            // o.o
            userAgentPackageName: 'com.example.admin_app',
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
          const Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(right: 16.0, bottom: 160.0),
              child: Attribution(),
            ),
          ),
          const AnomalyMarkerLayer(),
          Positioned(
            left: 16,
            bottom: screenHeight * 0.29,
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

          // Fix anomaly is only shown if navigating to an anomaly, which means
          // an anomaly has to be passed, otherwise its null
          if (widget.anomaly != null)
            Positioned(
              left: 16,
              bottom: screenHeight * 0.38,
              child: FloatingActionButton(
                heroTag: "fix_anomaly",
                onPressed: () {
                  showAnomalyDialog(
                    context,
                    widget.endLat,
                    widget.endLng,
                    widget.anomaly!.cid,
                    widget.anomaly!.category,
                  );
                },
                tooltip: "Fix Anomaly",
                backgroundColor: context.colorScheme.primaryContainer,
                elevation: 6,
                child: Icon(
                  Icons.construction_rounded,
                  color: context.colorScheme.onPrimaryContainer,
                ),
              ),
            ),

          // button to toggle anomaly alerts when navigating
          Positioned(
            left: 16,
            bottom: screenHeight * 0.20,
            child: FloatingActionButton(
              heroTag: "anomaly_filter_while_navigating",
              tooltip: "Toggle Anomaly Alerts while Navigating",
              backgroundColor: colorScheme.tertiaryContainer,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => _AnomalyToggleSheet(),
                );
              },
              child: Icon(LucideIcons.alertTriangle,
                  color: colorScheme.onTertiaryContainer),
            ),
          ),

          AnomalyAlerts(segments: widget.mapProvider.currentRoute.segments),
        ],
      ),
    );
  }
}

class _AnomalyToggleSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<UserSettingsProvider>(context);
    List<Map<String, String>> anomalies = [
      {"name": "Pothole", "icon": "assets/icons/ic_pothole.png"},
      {"name": "SpeedBreaker", "icon": "assets/icons/ic_speedbreaker.png"},
      {"name": "Rumbler", "icon": "assets/icons/ic_rumbler.png"},
      {"name": "Cracks", "icon": "assets/icons/ic_cracks.png"},
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Anomaly Alerts", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...anomalies.map((anomaly) {
            final name = anomaly['name']!;
            return SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              title: Text(name),
              value: settings.alertWhileRiding[name]!,
              onChanged: (val) {
                switch (name) {
                  case "Pothole":
                    settings.toggleAlertWhileRiding(name);
                    break;
                  case "SpeedBreaker":
                    settings.toggleAlertWhileRiding(name);
                    break;
                  case "Rumbler":
                    settings.toggleAlertWhileRiding(name);
                    break;
                  case "Cracks":
                    settings.toggleAlertWhileRiding(name);
                    break;
                }
              },
              secondary: Image.asset(
                anomaly['icon']!,
                width: 28,
                height: 28,
              ),
            );
          }),
        ],
      ),
    );
  }
}

import 'package:admin_app/components/OSM_Attribution.dart';
import 'package:admin_app/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../constants.dart';
import '../../services/providers/anomaly_marker_layer.dart';
import '../../services/providers/route_provider.dart';
import '../../services/providers/user_settings.dart';
import '../../utils/route_utils.dart';
import '../anomaly_zoom_popup.dart';
import 'route_directions.dart';

class RouteSelectionMode extends StatefulWidget {
  final RouteProvider mapProvider;
  final MapController mapController;

  const RouteSelectionMode(
      {super.key, required this.mapController, required this.mapProvider});

  @override
  State<RouteSelectionMode> createState() => _RouteSelectionModeState();
}

class _RouteSelectionModeState extends State<RouteSelectionMode> {
  double _currentZoom = defaultZoom;
  late final ValueNotifier<double> zoomNotifier;

  @override
  void initState() {
    super.initState();

    zoomNotifier = ValueNotifier<double>(defaultZoom);

    widget.mapController.mapEventStream.listen((event) {
      if (event is MapEventMoveEnd ||
          event is MapEventDoubleTapZoomEnd ||
          event is MapEventMove) {
        final newZoom = widget.mapController.camera.zoom;
        if (zoomNotifier.value != newZoom) {
          zoomNotifier.value = newZoom;
        }
      }
    });
  }

  int get clusteringRadius {
    // cuz i always forget, more zoom == closer to the map
    // default zoom is set to 18
    if (_currentZoom >= 15) return 20;
    if (_currentZoom >= 14) return 40;
    if (_currentZoom >= 10) return 80;
    return 100;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final themeMode = context.select<UserSettingsProvider, ThemeMode>(
      (settings) => settings.themeMode,
    );
    final routeProvider = context.watch<RouteProvider>();
    double opacity = (_currentZoom >= zoomThreshold)
        ? 1.0
        : 0.0; // dis controls the anomaly marker layer visibility

    bool showPopup = _currentZoom <
        zoomThreshold; // this controls whether to show the popup (anomalies not visible)

    return SlidingUpPanel(
      color: context.colorScheme.surfaceContainer,
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
      minHeight: screenHeight * 0.4,
      maxHeight: screenHeight * 0.8,
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
                      width: MediaQuery.of(context).size.width * 0.15,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Text(
                    "Select a Route",
                    style: context.theme.textTheme.headlineSmall
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
                          routeProvider.alternativeRoutes.length == 1
                              ? "Shortest Route (Avoids anomalies)"
                              : index == 0
                                  ? "Shortest Route"
                                  : "Route avoiding anomalies",
                          style: context.theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                            "Distance: ${route.distance != null ? formatDistance(route.distance!) : "N/A"}"
                            // "Duration: ${route.duration != null ? formatDuration(route.duration!) : "N/A"}",
                            ),
                        selected: routeProvider.selectedRouteIndex == index,
                        onTap: () {
                          routeProvider.updateSelectedRoute(index);
                          widget.mapController.fitCamera(
                            CameraFit.bounds(
                              bounds: routeProvider.bounds,
                              padding: const EdgeInsets.fromLTRB(
                                  50.0, 150.0, 50.0, 300.0),
                            ),
                          );
                          widget.mapController.rotate(0);
                        },
                      );
                    },
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  if (routeProvider.selectedRouteIndex >= 0 &&
                      routeProvider.selectedRouteIndex <
                          routeProvider.currentRouteSegments.length)
                    // ================================ DIRECTIONS
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              "Directions",
                              style: context.theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            RouteDirections(route: routeProvider.currentRoute),
                          ],
                        ),
                      ),
                    ),
                ],
              )
            // ==================== FALLBACK - NO ROUTES
            : Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "No Routes Available",
                      style: context.theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Please check your internet connection or try again later.",
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
      ),
      body: FlutterMap(
        mapController: widget.mapController,
        options: MapOptions(
          initialCenter:
              LatLng(widget.mapProvider.startLat, widget.mapProvider.startLng),
          initialZoom: 14.0,
        ),
        children: [
          TileLayer(
            panBuffer: 0,
            urlTemplate: tileServerUrl,
            // tileBuilder:
            //     themeMode == ThemeMode.dark ? customDarkModeTileBuilder : null,
            userAgentPackageName: 'com.example.admin_app',
            tileProvider: FMTCTileProvider(
              stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
            ),
          ),
          // Draw all alternative routes.
          PolylineLayer(
            polylines: [
              for (int i = 0;
                  i < widget.mapProvider.alternativeRoutes.length;
                  i++)
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
          // dis anomaly marker layer ＼（〇_ｏ）／
          ValueListenableBuilder<double>(
            valueListenable: zoomNotifier,
            builder: (context, zoom, child) {
              final opacity = (zoom >= zoomThreshold) ? 1.0 : 0.0;
              int clusteringRadius;
              if (zoom >= 15) {
                clusteringRadius = 20;
              } else if (zoom >= 14) {
                clusteringRadius = 40;
              } else if (zoom >= 10) {
                clusteringRadius = 80;
              } else {
                clusteringRadius = 100;
              }

              return AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: opacity,
                child: const AnomalyMarkerLayer(),
              );
            },
          ),
          const Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(right: 16.0, bottom: 340.0),
              child: Attribution(),
            ),
          ),
          Positioned(
            top: 80,
            left: 10,
            right: 10,
            child: ValueListenableBuilder<double>(
              valueListenable: zoomNotifier,
              builder: (context, zoom, child) {
                return AnimatedOpacity(
                  opacity: (zoom < zoomThreshold) ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: AnomalyZoomPopup(mapController: widget.mapController),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

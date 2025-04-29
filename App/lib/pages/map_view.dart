import 'dart:developer' as dev;

import 'package:app/components/anomaly_zoom_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../components/OSM_Attribution.dart';
import '../constants.dart';
import '../services/grid_movement_handler.dart';
import '../services/providers/anomaly_marker_layer.dart';
import '../services/providers/anomaly_provider.dart';
import '../services/providers/map_controller_provider.dart';
import '../services/providers/permissions.dart';
import '../services/providers/user_settings.dart';
import '../util/map_utils.dart';

class MapView extends StatefulWidget {
  final PolylineLayer? polylineLayer;
  const MapView({super.key, this.polylineLayer});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late final MapController _mapController;
  late final GridMovementHandler _gridHandler;
  double _currentZoom = defaultZoom;

  @override
  void initState() {
    dev.log("Initializing the map");
    super.initState();
    _mapController = context.read<MapControllerProvider>().mapController;
    _gridHandler =
        GridMovementHandler(mapController: _mapController, context: context);
    Provider.of<AnomalyProvider>(context, listen: false).init();

    _mapController.mapEventStream.listen((event) {
      if (event is MapEventMoveEnd ||
          event is MapEventDoubleTapZoomEnd ||
          event is MapEventMove) {
        if (mounted) {
          // dev.log("Current zoom level: ${_mapController.camera.zoom}");
          setState(() {
            _currentZoom = _mapController.camera.zoom;
          });
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
    double opacity = (_currentZoom >= zoomThreshold)
        ? 1.0
        : 0.0; // dis controls the anomaly marker layer visibility

    bool showPopup = _currentZoom <
        zoomThreshold; // this controls whether to show the popup (anomalies not visible)

    return Consumer<Permissions>(
      builder: (context, permissions, child) {
        var userLocation = permissions.position != null
            ? LatLng(
                permissions.position!.latitude, permissions.position!.longitude)
            : defaultCenter;

        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: userLocation,
            initialZoom: defaultZoom,
            maxZoom: maxZoom,
            minZoom: minZoom,
          ),
          children: [
            const MapTileLayer(),
            if (permissions.position != null)
              MarkerLayer(
                markers: [
                  Marker(
                    rotate: true,
                    point: userLocation,
                    child: mapMarkerIcon("assets/icons/ic_user.png",
                        Theme.of(context).colorScheme.outlineVariant),
                  ),
                ],
              ),
            if (widget.polylineLayer != null) widget.polylineLayer!,
            // dis anomaly marker layer ＼（〇_ｏ）／
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: opacity,
              child: AnomalyMarkerLayer(
                mapController: _mapController,
                clusteringRadius: clusteringRadius,
              ),
            ),
            const Positioned(
              left: 345,
              bottom: 210,
              child: Attribution(),
            ),
            Positioned(
              top: 80,
              left: 10,
              right: 10,
              child: AnimatedOpacity(
                opacity: showPopup ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: AnomalyZoomPopup(mapController: _mapController),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Moved tileLayer to its separate logic, because it depends on themeMode, and if themeMode changes then we only need to rebuild the tileLayer, NOT the entire Map logic
class MapTileLayer extends StatelessWidget {
  const MapTileLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<UserSettingsProvider, ThemeMode>(
      (settings) => settings.themeMode,
    );

    return TileLayer(
      panBuffer: 0,
      userAgentPackageName: 'com.example.app',
      urlTemplate: tileServerUrl,
      tileBuilder:
          themeMode == ThemeMode.dark ? customDarkModeTileBuilder : null,
      tileProvider: FMTCTileProvider(
          stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate}),
    );
  }
}

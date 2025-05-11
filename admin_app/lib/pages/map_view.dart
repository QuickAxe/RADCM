import 'dart:developer' as dev;

import 'package:admin_app/components/anomaly_zoom_popup.dart';
import 'package:admin_app/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../components/attribution.dart';
import '../constants.dart';
import '../services/grid_movement_handler.dart';
import '../services/providers/anomaly_marker_layer.dart';
import '../services/providers/anomaly_provider.dart';
import '../services/providers/map_controller_provider.dart';
import '../services/providers/permissions.dart';
import '../services/providers/user_settings.dart';
import '../utils/map_utils.dart';
import 'map_route_screen.dart';

class MapView extends StatefulWidget {
  final PolylineLayer? polylineLayer;
  final UserSettingsProvider userSettingsProvider;
  const MapView(
      {super.key, this.polylineLayer, required this.userSettingsProvider});

  @override
  State<MapView> createState() => _MapViewState();
}

Future<String> _getAddress(LatLng location) async {
  try {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);
    if (placemarks.isNotEmpty) {
      return "${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country}";
    }
  } catch (e) {
    return "Address not available";
  }
  return "Address not available";
}

class _MapViewState extends State<MapView> {
  late final MapController _mapController;
  late final GridMovementHandler _gridHandler;
  LatLng? _tapMarker;
  String? _tapAddress;

  double _currentZoom = defaultZoom;

  @override
  void initState() {
    dev.log(
        "Initializing the map -------------------------------------------------");
    super.initState();
    _mapController = context.read<MapControllerProvider>().mapController;
    dev.log(
        'UserSettingsProvider: $widget.userSettingsProvider ------------------------------');
    GridMovementHandler.initOnce(
      mapController: _mapController,
      userSettingsProvider: widget.userSettingsProvider,
      context: context,
    );
    _gridHandler = GridMovementHandler.instance;
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
            interactionOptions: const InteractionOptions(
              enableMultiFingerGestureRace: true,
              flags: InteractiveFlag.all,
            ),
            initialCenter: userLocation,
            initialZoom: defaultZoom,
            maxZoom: maxZoom,
            minZoom: minZoom,
            onTap: (tapPosition, latlng) async {
              setState(() {
                _tapMarker = latlng;
                _tapAddress = null; // reset
              });

              String address = await _getAddress(latlng);
              if (mounted) {
                setState(() {
                  _tapAddress = address;
                });
              }
            },
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

            // marker that appears when users tap on locations
            if (_tapMarker != null) ...[
              MarkerLayer(
                markers: [
                  // fix this: marker nudges down after address loads
                  Marker(
                    point: _tapMarker!,
                    rotate: true,
                    width: 250,
                    height: 180,
                    child: Column(
                      children: [
                        Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _tapAddress == null
                                ? const SizedBox(
                                    width: 200,
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  )
                                : SizedBox(
                                    width: 200,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12.0),
                                          child: Text(
                                            _tapAddress!,
                                            textAlign: TextAlign.center,
                                            style: context
                                                .theme.textTheme.titleSmall,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _tapMarker = null;
                                                  _tapAddress = null;
                                                });
                                              },
                                              child: Text("Close",
                                                  style: TextStyle(
                                                      color: context.colorScheme
                                                          .secondary)),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        MapRouteScreen(
                                                      endLat:
                                                          _tapMarker!.latitude,
                                                      endLng:
                                                          _tapMarker!.longitude,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: const Text("Go here"),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        Icon(Icons.location_on_rounded,
                            size: 30, color: context.colorScheme.tertiary),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            if (widget.polylineLayer != null) widget.polylineLayer!,
            // dis anomaly marker layer ＼（〇_ｏ）／
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: opacity,
              child: const AnomalyMarkerLayer(),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(
                  right: 16.0,
                  bottom: MediaQuery.of(context).size.height * 0.25,
                ),
                child: const Attribution(),
              ),
            ),
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, left: 10.0, right: 10.0),
                child: AnimatedOpacity(
                  opacity: showPopup ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: AnomalyZoomPopup(mapController: _mapController),
                ),
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
      userAgentPackageName: 'com.example.admin_app',
      urlTemplate: tileServerUrl,
      tileBuilder:
          themeMode == ThemeMode.dark ? customDarkModeTileBuilder : null,
      tileProvider: FMTCTileProvider(
          stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate}),
    );
  }
}

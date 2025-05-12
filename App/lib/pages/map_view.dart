import 'dart:developer' as dev;

import 'package:app/components/anomaly_zoom_popup.dart';
import 'package:app/util/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:geocoding/geocoding.dart';
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

        return Stack(
          children: [
            FlutterMap(
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

                // USER -----
                if (permissions.position != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        rotate: true,
                        point: userLocation,
                        alignment: Alignment.topCenter,
                        child: mapMarkerIcon("assets/icons/ic_user.png",
                            Theme.of(context).colorScheme.outlineVariant),
                      ),
                    ],
                  ),

                // ROUTE? -----
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

                // DROPPED PIN MARKER -----
                if (_tapMarker != null) ...[
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _tapMarker!,
                        rotate: true,
                        width: 255,
                        height: 155,
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: [
                            Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: SizedBox(
                                  width: 255,
                                  child: Column(
                                    children: [
                                      _tapAddress == null
                                          ? Text(
                                              "Fetching address...",
                                              style: context
                                                  .theme.textTheme.labelLarge
                                                  ?.copyWith(
                                                      color: Colors.grey),
                                            )
                                          : Text(
                                              _tapAddress!,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: context
                                                  .theme.textTheme.labelLarge,
                                            ),
                                      const SizedBox(height: 15),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 20),
                                              backgroundColor:
                                                  context.colorScheme.secondary,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _tapMarker = null;
                                                _tapAddress = null;
                                              });
                                            },
                                            icon: Icon(
                                              Icons.close_rounded,
                                              color: context
                                                  .colorScheme.onSecondary,
                                            ),
                                            label: Text(
                                              'Close',
                                              style: context
                                                  .theme.textTheme.labelLarge
                                                  ?.copyWith(
                                                color: context
                                                    .colorScheme.onSecondary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 20),
                                              backgroundColor:
                                                  context.colorScheme.primary,
                                            ),
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
                                            icon: Icon(
                                              Icons.navigation_rounded,
                                              color:
                                                  context.colorScheme.onPrimary,
                                            ),
                                            label: Text(
                                              'Go Here',
                                              style: context
                                                  .theme.textTheme.labelLarge
                                                  ?.copyWith(
                                                color: context
                                                    .colorScheme.onPrimary,
                                              ),
                                            ),
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

                // ATTRIBUTION -------
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.0, bottom: 210.0),
                    child: Attribution(),
                  ),
                ),

                // ZOOM IN POP-UP -------
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 16.0, left: 10.0, right: 10.0),
                    child: AnimatedOpacity(
                      opacity: showPopup ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: AnomalyZoomPopup(mapController: _mapController),
                    ),
                  ),
                ),
              ],
            )
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

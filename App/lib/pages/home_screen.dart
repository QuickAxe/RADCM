import 'dart:async';

import 'package:app/components/UI/blur_with_loading.dart';
import 'package:app/components/app_drawer.dart';
import 'package:app/components/bottom_panel_nav.dart';
import 'package:app/services/providers/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../components/OSM_Attribution.dart';
import '../components/bottom_panel.dart';
import '../services/grid_movement_handler.dart';
import '../services/providers/anomaly_marker_layer.dart';
import '../services/providers/anomaly_provider.dart';
import '../services/providers/permissions.dart';
import '../services/providers/search.dart';
import '../util/map_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final MapController _mapController;
  late final GridMovementHandler _gridHandler;
  LatLng userLocation = const LatLng(15.49613530624519, 73.82646130357969);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Special FMTC tileprovider
  final _tileProvider = FMTCTileProvider(
    stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
  );

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _gridHandler =
        GridMovementHandler(mapController: _mapController, context: context);

    // this init call fetches anomalies from the hive cache into the provider
    Provider.of<AnomalyProvider>(context, listen: false).init();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeMode = context.select<UserSettingsProvider, ThemeMode>(
      (settings) => settings.themeMode,
    );

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: FloatingActionButton(
            backgroundColor: colorScheme.secondaryContainer,
            heroTag: "hamburger",
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            child: const Icon(
              Icons.menu_rounded,
            ),
          ),
        ),
        actions: [
          Consumer<Search>(builder: (context, search, child) {
            if (search.isCurrentSelected) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: FloatingActionButton(
                  onPressed: () {
                    search.performDeselection();
                    _mapController.moveAndRotate(userLocation, 15.0, 0.0);
                  },
                  child: const Icon(
                    Icons.arrow_back_rounded,
                  ),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: FloatingActionButton(
                  heroTag: "my_location",
                  backgroundColor: colorScheme.secondaryContainer,
                  onPressed: () {
                    // refresh user location
                    Provider.of<Permissions>(context, listen: false)
                        .checkAndRequestLocationPermission();
                    Position? pos =
                        Provider.of<Permissions>(context, listen: false)
                            .position;

                    if (pos != null) {
                      userLocation = LatLng(pos.latitude, pos.longitude);
                    }
                  },
                  child: const Icon(
                    Icons.my_location_rounded,
                  ),
                ),
              );
            }
          })
        ],
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // Consumer, listening for position changes
          Consumer<Permissions>(
            builder: (context, permissions, child) {
              if (permissions.position != null) {
                userLocation = LatLng(
                  permissions.position!.latitude,
                  permissions.position!.longitude,
                );
                // centers to the users current location and makes the map upright
                _mapController.moveAndRotate(userLocation, 15.0, 0.0);
              }

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: userLocation,
                  initialZoom: 18.0,
                  maxZoom: 20.0,
                  minZoom: 3.0,
                ),
                children: [
                  TileLayer(
                    panBuffer: 0,
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    // retinaMode: true,
                    tileBuilder: themeMode == ThemeMode.dark
                        ? customDarkModeTileBuilder
                        : null,
                    userAgentPackageName: 'com.example.app',
                    tileProvider: _tileProvider,
                  ),
                  // updates the user location marker
                  if (permissions.position != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                            rotate: true,
                            point: userLocation,
                            child: mapMarkerIcon("assets/icons/ic_user.png",
                                Theme.of(context).colorScheme.outlineVariant)),
                      ],
                    ),
                  AnomalyMarkerLayer(
                    mapController: _mapController,
                  ),
                  const Positioned(
                    left: 200,
                    bottom: 200,
                    child: Attribution(),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 210,
                    child: FloatingActionButton(
                      heroTag: "capture_anomaly",
                      onPressed: () {
                        Navigator.pushNamed(context, '/capture');
                      },
                      backgroundColor: colorScheme.primaryContainer,
                      tooltip: "See an anomaly? Capture it!",
                      elevation: 6,
                      child: const Icon(LucideIcons.camera),
                    ),
                  ),
                ],
              );
            },
          ),
          Consumer<Permissions>(
            builder: (context, permissions, child) {
              return Consumer<Search>(
                builder: (context, search, child) {
                  if (permissions.loadingLocation) {
                    return const BlurWithLoading();
                  } else if (search.isCurrentSelected) {
                    return BottomPanelNav(mapController: _mapController);
                  } else {
                    return BottomPanel(mapController: _mapController);
                  }
                },
              );
            },
          )
        ],
      ),
    );
  }
}

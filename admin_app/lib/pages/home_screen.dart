import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../components/app_drawer.dart';
import '../components/bottom_panel.dart';
import '../components/bottom_panel_nav.dart';
import '../services/providers/anomaly_marker_layer.dart';
import '../services/providers/permissions.dart';
import '../services/providers/search.dart';
import '../services/providers/user_settings.dart';
import '../utils/map_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final MapController _mapController;
  LatLng userLocation = const LatLng(15.49613530624519, 73.82646130357969);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
// Special FMTC tileprovider
  final _tileProvider = FMTCTileProvider(
    stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
  );
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      Permissions permissions =
          Provider.of<Permissions>(context, listen: false);

      // calls fetch position
      permissions.fetchPosition();
    });

    _mapController = MapController();
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
            heroTag: null,
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
                    // move map to user location
                    _mapController.move(
                        userLocation, _mapController.camera.zoom);
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
                  child: const Icon(Icons.my_location_rounded),
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
                _mapController.move(userLocation, _mapController.camera.zoom);
              }

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: userLocation,
                  initialZoom: 13,
                  maxZoom: 18,
                  minZoom: 3,
                ),
                children: [
                  TileLayer(
                    panBuffer: 0,
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    tileBuilder: themeMode == ThemeMode.dark
                        ? customDarkModeTileBuilder
                        : null,
                    userAgentPackageName: 'com.example.admin_app',
                    tileProvider: _tileProvider,
                  ),
                  // updates the user location marker
                  if (permissions.position != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: userLocation,
                          child: Image.asset(
                            "assets/icons/ic_user.png",
                            width: 60.0,
                            height: 60.0,
                          ),
                        ),
                      ],
                    ),
                  const AnomalyMarkerLayer(),
                ],
              );
            },
          ),

          Consumer<Permissions>(
            builder: (context, permissions, child) {
              return Consumer<Search>(
                builder: (context, search, child) {
                  if (permissions.loadingLocation) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
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

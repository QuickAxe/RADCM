import 'package:app/components/app_drawer.dart';
import 'package:app/components/bottom_panel_nav.dart';
import 'package:app/services/providers/anomaly_marker_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/bottom_panel.dart';
import '../services/providers/permissions.dart';
import '../services/providers/search.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final MapController _mapController;
  LatLng userLocation = const LatLng(15.49613530624519, 73.82646130357969);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: FloatingActionButton(
            heroTag: "hamburger",
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.menu_rounded),
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
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.arrow_back_rounded),
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
                  backgroundColor: Colors.white,
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
                // centers to the users current location and makes the map upright
                _mapController.moveAndRotate(userLocation, 15.0, 0.0);
              }

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: userLocation,
                  initialZoom: 15.0,
                  maxZoom: 18.0,
                  minZoom: 3.0,
                ),
                children: [
                  TileLayer(
                    panBuffer: 3,
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  // updates the user location marker
                  if (permissions.position != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          rotate: true,
                          point: userLocation,
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.red,
                            size: 30.0,
                          ),
                        ),
                      ],
                    ),
                  const AnomalyMarkerLayer(),
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
              );
            },
          ),

          Consumer<Search>(builder: (context, search, child) {
            if (search.isCurrentSelected) {
              return BottomPanelNav(mapController: _mapController);
            } else {
              return BottomPanel(mapController: _mapController);
            }
          })
        ],
      ),
    );
  }
}

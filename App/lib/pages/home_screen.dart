import 'dart:developer' as dev;

import 'package:app/components/app_drawer.dart';
import 'package:app/components/bottom_panel_nav.dart';
import 'package:app/services/providers/anomaly_marker_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../components/bottom_panel.dart';
import '../services/isolates/anomaly_detection.dart';
import '../services/providers/permissions.dart';
import '../services/providers/search.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FlutterIsolate dataCollectorIsolate;
  late final MapController _mapController;
  LatLng userLocation = const LatLng(15.49613530624519, 73.82646130357969);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // _panelController = PanelController();
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
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.menu),
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
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.arrow_back_rounded),
                ),
              );
            } else {
              return const Padding(
                padding: EdgeInsets.all(10.0),
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

                // Background process spawns
                dev.log('position: ${permissions.position}');
                dev.log('background process started.');
                FlutterIsolate.spawn(theDataCollector, "bg process isolate")
                    .then((isolate) {
                  dataCollectorIsolate = isolate;
                });
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
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  // updates the user location marker
                  if (permissions.position != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: userLocation,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 30.0,
                          ),
                        ),
                      ],
                    ),
                  const AnomalyMarkerLayer(),
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

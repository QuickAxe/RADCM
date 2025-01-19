import 'dart:developer' as dev;

import 'package:app/components/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../services/providers/permissions.dart';
import '../util/bg_process.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FlutterIsolate dataCollectorIsolate;
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      drawer: AppDrawer(),
      body: SlidingUpPanel(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
        panel: const Center(
          child: Text("This is the bottom panel"),
        ),
        body: Stack(
          children: [
            // Consumer, listening for position changes
            Consumer<Permissions>(
              builder: (context, permissions, child) {
                LatLng userLocation =
                    const LatLng(15.49613530624519, 73.82646130357969);

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
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

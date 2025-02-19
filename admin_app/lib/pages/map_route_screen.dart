// used prefix here to avoid conflict between android inbuilt NavigationMode
import 'dart:ui';

import 'package:admin_app/components/routing/navigation_mode.dart' as prefix;
import 'package:admin_app/components/routing/route_selection_mode.dart';
import 'package:admin_app/utils/fix_anomaly_dialog.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../services/providers/route_provider.dart';

class MapRouteScreen extends StatefulWidget {
  final double endLat;
  final double endLng;

  const MapRouteScreen({super.key, required this.endLat, required this.endLng});

  @override
  State<MapRouteScreen> createState() => _MapRouteScreenState();
}

class _MapRouteScreenState extends State<MapRouteScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapProvider = Provider.of<MapRouteProvider>(context, listen: false);
      mapProvider.initialize(context, widget.endLat, widget.endLng);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Consumer<MapRouteProvider>(
      builder: (context, mapProvider, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                mapProvider.stopRouteNavigation();
                mapProvider.flushRoutes();
                Navigator.of(context).pop();
              },
            ),
            actions: [
              if (mapProvider.selectedRouteIndex != -1 &&
                  !mapProvider.startNavigation)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: FloatingActionButton(
                    onPressed: () {
                      _mapController.moveAndRotate(
                        LatLng(mapProvider.startLat, mapProvider.startLng),
                        18.0,
                        0.0,
                      );
                      mapProvider.startRouteNavigation();
                    },
                    child: const Icon(
                      Icons.navigation_rounded,
                    ),
                  ),
                )
              else if (mapProvider.startNavigation)
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                      child: FloatingActionButton(
                        onPressed: () {
                          showAnomalyDialog(
                              context, widget.endLat, widget.endLng);
                        },
                        child: const Icon(
                          Icons.construction_rounded,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FloatingActionButton(
                        onPressed: () {
                          mapProvider.stopRouteNavigation();
                        },
                        child: const Icon(
                          Icons.stop,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: Stack(
            children: [
              /// Map or navigation mode
              Positioned.fill(
                child: mapProvider.startNavigation
                    ? prefix.NavigationMode(
                        mapProvider: mapProvider, mapController: _mapController)
                    : RouteSelectionMode(
                        mapController: _mapController,
                        mapProvider: mapProvider),
              ),
              if (mapProvider.isLoading)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),
              if (mapProvider.isLoading)
                const Center(
                  child:
                      CircularProgressIndicator(), // Default loading animation
                ),
            ],
          ),
        );
      },
    );
  }
}

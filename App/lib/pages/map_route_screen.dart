// used prefix here to avoid conflict between android inbuilt NavigationMode
import 'package:app/components/UI/blur_with_loading.dart';
import 'package:app/components/routing/bottom_panel_navigation_mode.dart'
    as prefix;
import 'package:app/components/routing/route_selection_mode.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../services/providers/route_provider.dart';

class MapRouteScreen extends StatefulWidget {
  const MapRouteScreen({super.key});

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
      mapProvider.initialize(context);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                )
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
              if (mapProvider.isLoading) const BlurWithLoading(),
            ],
          ),
        );
      },
    );
  }
}

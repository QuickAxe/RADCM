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
      final mapProvider = Provider.of<RouteProvider>(context, listen: false);
      mapProvider.setLoading();
      mapProvider.initialize(context, _mapController);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Consumer<RouteProvider>(
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
                    heroTag: "start_navigation",
                    tooltip: "Start Navigation",
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
                    heroTag: "stop_navigation",
                    tooltip: "Stop Navigation",
                    onPressed: () {
                      mapProvider.stopRouteNavigation();
                    },
                    backgroundColor: colorScheme.errorContainer,
                    child: Icon(
                      Icons.stop_rounded,
                      color: colorScheme.onErrorContainer,
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
                        routeProvider: mapProvider,
                        mapController: _mapController)
                    : RouteSelectionMode(
                        mapController: _mapController,
                        routeProvider: mapProvider),
              ),
              if (mapProvider.isLoading) const BlurWithLoading(),
            ],
          ),
        );
      },
    );
  }
}

// used prefix here to avoid conflict between android inbuilt NavigationMode
import 'package:admin_app/components/routing/navigation_mode.dart' as prefix;
import 'package:admin_app/components/routing/route_selection_mode.dart';
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
    return Consumer<MapRouteProvider>(
      builder: (context, mapProvider, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
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
                    backgroundColor: Colors.deepPurple,
                    child: const Icon(
                      Icons.navigation_rounded,
                      color: Colors.white,
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
                    backgroundColor: Colors.deepPurple,
                    child: const Icon(
                      Icons.stop,
                      color: Colors.white,
                    ),
                  ),
                )
            ],
          ),
          body: mapProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : mapProvider.startNavigation
                  ? prefix.NavigationMode(
                      mapProvider: mapProvider, mapController: _mapController)
                  : RouteSelectionMode(
                      mapController: _mapController, mapProvider: mapProvider),
        );
      },
    );
  }
}

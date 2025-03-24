import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../services/grid_movement_handler.dart';
import '../services/providers/anomaly_marker_layer.dart';
import '../services/providers/anomaly_provider.dart';
import '../services/providers/permissions.dart';
import '../util/map_utils.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late final MapController _mapController;
  late final GridMovementHandler _gridHandler;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _gridHandler =
        GridMovementHandler(mapController: _mapController, context: context);
    Provider.of<AnomalyProvider>(context, listen: false).init();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Permissions>(
      builder: (context, permissions, child) {
        final userLocation = permissions.position != null
            ? LatLng(
                permissions.position!.latitude, permissions.position!.longitude)
            : const LatLng(15.49613530624519, 73.82646130357969);

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
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              tileProvider: FMTCTileProvider(stores: const {
                'mapStore': BrowseStoreStrategy.readUpdateCreate
              }),
            ),
            if (permissions.position != null)
              MarkerLayer(
                markers: [
                  Marker(
                    rotate: true,
                    point: userLocation,
                    child: mapMarkerIcon("assets/icons/ic_user.png",
                        Theme.of(context).colorScheme.outlineVariant),
                  ),
                ],
              ),
            AnomalyMarkerLayer(mapController: _mapController),
          ],
        );
      },
    );
  }
}

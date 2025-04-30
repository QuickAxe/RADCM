import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../services/providers/map_controller_provider.dart';
import '../services/providers/permissions.dart';
import '../services/providers/search.dart';

class LocationButton extends StatelessWidget {
  const LocationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final permissions = Provider.of<Permissions>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: FloatingActionButton(
        heroTag: "my_location",
        backgroundColor: colorScheme.secondaryContainer,
        onPressed: () async {
          await permissions.fetchPosition().then((_) {
            if (permissions.position != null) {
              context.read<MapControllerProvider>().mapController.moveAndRotate(
                  LatLng(permissions.position!.latitude,
                      permissions.position!.longitude),
                  defaultZoom,
                  0.0);
            }
          });
        },
        child: const Icon(Icons.my_location_rounded),
      ),
    );
  }
}

class ReturnButton extends StatelessWidget {
  const ReturnButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final permissions = Provider.of<Permissions>(context, listen: false);
    final search = Provider.of<Search>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: FloatingActionButton(
        heroTag: "my_location",
        backgroundColor: colorScheme.secondaryContainer,
        onPressed: () {
          search.performDeselection();
          context.read<MapControllerProvider>().mapController.moveAndRotate(
              LatLng(permissions.position!.latitude,
                  permissions.position!.longitude),
              defaultZoom,
              0.0);
        },
        child: const Icon(LucideIcons.arrowLeft),
      ),
    );
  }
}

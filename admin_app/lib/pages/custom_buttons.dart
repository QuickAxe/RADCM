import 'package:admin_app/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../services/providers/map_controller_provider.dart';
import '../services/providers/permissions.dart';
import '../services/providers/search.dart';
import '../services/providers/user_settings.dart';

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

class DirtyAnomalies extends StatelessWidget {
  const DirtyAnomalies({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSettingsProvider>(
      builder: (context, settings, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: settings.fetchingAnomalies,
          builder: (context, isFetching, _) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: isFetching
                  ? FloatingActionButton.extended(
                      heroTag: "fetching_anomalies",
                      backgroundColor: context.colorScheme.secondaryContainer,
                      onPressed: null,
                      icon: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.colorScheme.primary,
                        ),
                      ),
                      label: Text(
                        "Fetching anomalies...",
                        style: context.theme.textTheme.labelLarge,
                      ),
                    )
                  : FloatingActionButton(
                      heroTag: "dirty_anomalies",
                      backgroundColor: Colors.amber,
                      onPressed: () {
                        showPopover(
                          direction: PopoverDirection.bottom,
                          context: context,
                          barrierColor: Colors.transparent,
                          radius: 10,
                          width: 220,
                          backgroundColor: context.colorScheme.surfaceContainer,
                          bodyBuilder: (context) {
                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Anomalies weren't fetched",
                                      style: context.theme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      )),
                                  const SizedBox(height: 8),
                                  Text(
                                    "An error prevented the latest anomalies from being fetched.",
                                    style: context.theme.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.refresh),
                                    label: const Text("Retry"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      final mapController = context
                                          .read<MapControllerProvider>()
                                          .mapController;
                                      final currentCenter =
                                          mapController.camera.center;
                                      final nudgedCenter = LatLng(
                                        currentCenter.latitude + 0.0000001,
                                        currentCenter.longitude + 0.0000001,
                                      );
                                      mapController.move(nudgedCenter,
                                          mapController.camera.zoom);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: const Icon(
                        LucideIcons.alertCircle,
                        color: Colors.black87,
                      ),
                    ),
            );
          },
        );
      },
    );
  }
}

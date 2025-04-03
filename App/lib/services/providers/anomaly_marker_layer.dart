import 'dart:developer';

import 'package:app/services/providers/anomaly_provider.dart';
import 'package:app/services/providers/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';

import '../../data/models/anomaly_marker_model.dart';
import '../../util/map_utils.dart';

Color _getClusterColor(int count) {
  if (count < 5) {
    return Colors.yellow.withOpacity(0.7);
  } else if (count < 10) {
    return Colors.orange.withOpacity(0.7);
  } else {
    return Colors.red.withOpacity(0.7);
  }
}

String getAnomalyIcon(String cat) {
  return switch (cat) {
    "SpeedBreaker" => "assets/icons/ic_speedbreaker.png",
    "Rumbler" => "assets/icons/ic_rumbler.png",
    "Pothole" => "assets/icons/ic_pothole.png",
    "Cracks" => "assets/icons/ic_cracks.png",
    _ => "assets/icons/ic_pothole.png",
  };
}

class AnomalyMarkerLayer extends StatefulWidget {
  final MapController mapController;
  final int clusteringRadius;
  const AnomalyMarkerLayer({
    super.key,
    required this.mapController,
    required this.clusteringRadius,
  });

  @override
  State<AnomalyMarkerLayer> createState() => _AnomalyMarkerLayerState();
}

class _AnomalyMarkerLayerState extends State<AnomalyMarkerLayer>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<UserSettingsProvider>(
      builder: (context, userSettings, child) {
        return ValueListenableBuilder<List<AnomalyMarker>>(
          valueListenable: context.watch<AnomalyProvider>().markersNotifier,
          builder: (context, visibleAnomalies, child) {
            List<Marker> markers = visibleAnomalies
                .where((anomaly) =>
                    userSettings.showOnMap[anomaly.category] ?? true)
                .map((anomaly) {
              return Marker(
                  rotate: true,
                  point: anomaly.location,
                  // child: GestureDetector(
                  //   onTap: () => showPopover(
                  //     context: context,
                  //     bodyBuilder: (context) => AnomalyInfoPopup(
                  //       anomaly: anomaly,
                  //     ),
                  //     onPop: () => log("An Anomaly marker was tapped"),
                  //     direction: PopoverDirection.bottom,
                  //     width: 200,
                  //     height: 400,
                  //     arrowHeight: 15,
                  //     arrowWidth: 30,
                  //   ),
                  //   child: mapMarkerIcon(
                  //     getAnomalyIcon(anomaly.category),
                  //     Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  //   ),
                  // ),
                  child: Builder(builder: (BuildContext markerContext) {
                    return GestureDetector(
                      onTap: () {
                        _animatedMapMove(
                            anomaly.location, widget.mapController.camera.zoom,
                            () {
                          showPopover(
                            context: markerContext,
                            bodyBuilder: (markerContext) => AnomalyInfoPopup(
                              anomaly: anomaly,
                            ),
                            onPop: () => log("An Anomaly marker was tapped"),
                            direction: PopoverDirection.top,
                            width: 250,
                            arrowDyOffset: -2,
                            arrowHeight: 15,
                            arrowWidth: 30,
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                          );
                        });
                      },
                      child: mapMarkerIcon(
                        getAnomalyIcon(anomaly.category),
                        Theme.of(context).colorScheme.outline.withOpacity(0.5),
                      ),
                    );
                  }));
            }).toList();

            return MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: widget.clusteringRadius,
                size: const Size(40, 40),
                zoomToBoundsOnClick: true,
                padding: const EdgeInsets.fromLTRB(50.0, 150.0, 50.0, 300.0),
                rotate: true,
                markers: markers,
                builder: (context, markers) {
                  Color clusterColor = _getClusterColor(markers.length);
                  return Container(
                    decoration: BoxDecoration(
                      color: clusterColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        markers.length.toString(),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // Source: [https://stackoverflow.com/questions/69829784/flutter-how-to-move-marker-on-map-more-smooth-using-flutter-map-package]
  void _animatedMapMove(
      LatLng destLocation, double destZoom, VoidCallback onMoveComplete) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(
        begin: widget.mapController.camera.center.latitude,
        end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: widget.mapController.camera.center.longitude,
        end: destLocation.longitude);
    final zoomTween =
        Tween<double>(begin: widget.mapController.camera.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      widget.mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
        onMoveComplete(); // the popover is called after the animation is done
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }
}

/// This is the popup that appears when marker is clicked
class AnomalyInfoPopup extends StatelessWidget {
  final AnomalyMarker anomaly;
  const AnomalyInfoPopup({super.key, required this.anomaly});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // anomaly icon and title
          Row(
            children: [
              Image.asset(
                getAnomalyIcon(anomaly.category),
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  anomaly.category,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Location
          Row(
            children: [
              Icon(Icons.location_on_rounded,
                  size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "Lat: ${anomaly.location.latitude.toStringAsFixed(5)}, "
                  "Lng: ${anomaly.location.longitude.toStringAsFixed(5)}",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // "Go here" Button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  log("Implement navigation logic here, pending..."),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: theme.colorScheme.secondaryContainer,
              ),
              child: Text(
                "Go here",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

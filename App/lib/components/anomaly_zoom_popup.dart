import 'package:app/util/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../constants.dart';

class AnomalyZoomPopup extends StatelessWidget {
  final MapController mapController;
  const AnomalyZoomPopup({super.key, required this.mapController});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      color: context.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Anomalies are hidden at this zoom level",
                style: TextStyle(
                  color: context.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                onPressed: () {
                  mapController.moveAndRotate(
                      mapController.camera.center, zoomThreshold, 0.0);
                },
                child: const Text("Zoom in"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:admin_app/utils/context_extensions.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Anomalies hidden",
                style: TextStyle(
                  color: context.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
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
    );
  }
}

import 'package:flutter/material.dart';

import '../../services/providers/anomaly_marker_layer.dart';

class AnomalyNotificationWidget extends StatelessWidget {
  final String message;
  final String category;
  final double distance;
  const AnomalyNotificationWidget(
      {super.key,
      required this.message,
      required this.category,
      required this.distance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      color: colorScheme.primaryFixed,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Image.asset(
              getAnomalyIcon(category),
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: TextStyle(
                      color: colorScheme.onPrimaryFixed,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.onPrimaryFixed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${distance.toStringAsFixed(0)}m",
                style: TextStyle(
                  color: colorScheme.primaryFixed,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

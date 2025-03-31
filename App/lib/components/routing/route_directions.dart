import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/route_models.dart';
import '../../util/route_utils.dart';

/// A widget that displays detailed turn-by-turn directions for a chosen route
class RouteDirections extends StatelessWidget {
  final RouteModel route;
  const RouteDirections({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: route.segments.length,
      padding: const EdgeInsets.all(8.0),
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        String? turnDirection = route.segments[index].maneuver.turnDirection;

        String instruction = turnDirection ?? "n/a";

        return ListTile(
          leading: Icon(
              _getManeuverIcon(turnDirection)), // Icon based on turnDirection
          title: Text(
            instruction,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            "Distance: ${formatDistance(route.segments[index].cost)}",
            style: TextStyle(color: Colors.grey[700]),
          ),
        );
      },
    );
  }

  /// Returns an appropriate icon for the given maneuver type
  IconData _getManeuverIcon(String? turnDirection) {
    switch (turnDirection) {
      case "START":
        return LucideIcons.navigation;
      case "STRAIGHT":
        return LucideIcons.arrowUp;
      case "LEFT":
        return LucideIcons.arrowLeft;
      case "SLIGHTLY LEFT":
        return LucideIcons.cornerUpLeft;
      case "RIGHT":
        return LucideIcons.arrowRight;
      case "SLIGHTLY RIGHT":
        return LucideIcons.cornerUpRight;
      default:
        return LucideIcons.arrowUp;
    }
  }
}

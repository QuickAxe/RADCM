import 'package:app/util/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/osrm_models.dart';
import '../../util/route_utils.dart';

/// A widget that displays detailed turn-by-turn directions for a chosen route
class RouteDirections extends StatelessWidget {
  final MatchingModel route;
  const RouteDirections({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (route.legs.isEmpty) {
      return const Center(child: Text("No directions available"));
    }

    final leg = route.legs.first;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: leg.steps.length,
      padding: const EdgeInsets.all(8.0),
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final step = leg.steps[index];

        String roadName =
            step.name.isNotEmpty ? capitalize(step.name) : "Unnamed road";
        String instruction =
            "${capitalize(step.maneuver.type)} ${step.maneuver.modifier ?? ''} on $roadName";

        return ListTile(
          leading: Icon(
            _getManeuverIcon(
                step.maneuver.type, step.maneuver.modifier.toString()),
            color: colorScheme.primary,
          ), // Icon based on maneuver type
          title: Text(
            instruction,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            "Distance: ${formatDistance(step.distance)} | Duration: ${formatDuration(step.duration)}",
            style: TextStyle(color: Colors.grey[700]),
          ),
        );
      },
    );
  }

  /// Returns an appropriate icon for the given maneuver type
  IconData _getManeuverIcon(String maneuverType, String modifier) {
    switch (maneuverType) {
      case "depart":
        return LucideIcons.navigation;
      case "turn":
        if (modifier == "left") {
          return LucideIcons.cornerUpLeft;
        } else {
          return LucideIcons.cornerUpRight;
        }
      case "continue":
        if (modifier == "left") {
          return LucideIcons.cornerUpLeft;
        } else if (modifier == "right") {
          return LucideIcons.cornerUpRight;
        } else if (modifier == "straight") {
          return LucideIcons.arrowUp;
        } else {
          return LucideIcons.map;
        }
      case "roundabout":
        return LucideIcons.rotateCw;
      case "merge":
        return LucideIcons.merge;
      case "exit":
        return LucideIcons.logOut;
      case "straight":
        return LucideIcons.arrowUp;
      case "arrive":
        return LucideIcons.partyPopper;
      default:
        if (modifier == "left") {
          return LucideIcons.cornerUpLeft;
        } else if (modifier == "right") {
          return LucideIcons.cornerUpRight;
        } else if (modifier == "straight") {
          return LucideIcons.arrowUp;
        } else if (modifier == "slight left") {
          return LucideIcons.arrowUpLeft;
        } else {
          return LucideIcons.map;
        }
    }
  }
}

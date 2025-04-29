import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Used to provide a color to a route displayed on the map
Color getColorForRoute(int index) {
  List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange
  ];
  return colors[index % colors.length];
}

/// Takes seconds as input and formats it into "minutes, seconds"
String formatDuration(double seconds) {
  int totalSeconds = seconds.round();
  int minutes = totalSeconds ~/ 60;
  int remainingSeconds = totalSeconds % 60;
  return "$minutes min $remainingSeconds sec";
}

/// Converts m to km
String formatDistance(double meters) {
  double km = meters / 1000;
  return "${km.toStringAsFixed(2)} km";
}

/// Generates a next direction instruction
String generateVerboseInstruction(
    String maneuverType, String? modifier, String roadName) {
  bool isUnnamedRoad = roadName.toLowerCase().contains("unnamed road");

  switch (maneuverType) {
    case "depart":
      return isUnnamedRoad
          ? "Start your journey and continue ahead."
          : "Start your journey by heading ${modifier ?? 'forward'} onto $roadName.";

    case "turn":
      return isUnnamedRoad
          ? "Turn ${modifier ?? ''} at the next available road."
          : "Turn ${modifier ?? ''} onto $roadName.";

    case "continue":
      return isUnnamedRoad
          ? "Continue ${modifier ?? 'straight'} on the road ahead."
          : "Continue ${modifier ?? 'straight'} on $roadName.";

    case "roundabout":
      return isUnnamedRoad
          ? "Enter the roundabout and take the appropriate exit."
          : "Enter the roundabout and take the appropriate exit onto $roadName.";

    case "merge":
      return isUnnamedRoad
          ? "Merge ${modifier ?? ''} ahead."
          : "Merge ${modifier ?? ''} onto $roadName.";

    case "exit":
      return isUnnamedRoad
          ? "Take the exit ${modifier != null ? 'to the ' + modifier : ''}."
          : "Take the exit ${modifier != null ? 'to the ' + modifier : ''} onto $roadName.";

    case "straight":
      return isUnnamedRoad
          ? "Proceed straight ahead."
          : "Proceed straight ahead on $roadName.";

    case "arrive":
      return isUnnamedRoad
          ? "You have arrived at your destination."
          : "You have arrived. Your destination is on the ${modifier ?? 'right'} side of $roadName.";

    default:
      return isUnnamedRoad
          ? "Proceed ${modifier ?? 'forward'} on the road ahead."
          : "Proceed ${modifier ?? 'forward'} on $roadName.";
  }
}

/// Returns an appropriate icon for the given maneuver type
IconData getManeuverIcon(String maneuverType, String? modifier) {
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

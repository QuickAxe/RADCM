import 'package:flutter/material.dart';

/// Used to provide a color to a route displayed on the map
Color getColorForRoute(int index) {
  List<Color> colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
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

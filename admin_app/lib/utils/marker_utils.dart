import 'package:flutter/material.dart';

/// gets the appropriate icon (image asset path) TODO: Mapping redundant, also exists in settings create a single src
String getAnomalyIcon(String cat) {
  String imageAssetPath = switch (cat) {
    "Speedbreaker" => "assets/icons/ic_speedbreaker.png",
    "Rumbler" => "assets/icons/ic_rumbler.png",
    "Obstacle" => "assets/icons/ic_obstacle.png",
    "Pothole" => "assets/icons/ic_pothole.png",
    _ => "assets/icons/ic_obstacle.png",
  };
  return imageAssetPath;
}

/// this is for the marker clusters, color increases with more and more anomalies
Color getClusterColor(int count) {
  if (count < 5) {
    return Colors.yellow.withOpacity(0.7); // Few anomalies
  } else if (count < 10) {
    return Colors.orange.withOpacity(0.7); // Moderate anomalies
  } else {
    return Colors.red.withOpacity(0.7); // High number of anomalies
  }
}

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

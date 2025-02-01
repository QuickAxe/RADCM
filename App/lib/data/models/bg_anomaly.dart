import 'dart:collection';

// Represents the structure of an anomaly
class Anomaly {
  ListQueue<List<double>> accReadings = ListQueue();
  double latitude = 0.0;
  double longitude = 0.0;
}

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/anomaly_marker_model.dart';

class AnomalyProvider extends ChangeNotifier {
  final ValueNotifier<List<AnomalyMarker>> markersNotifier = ValueNotifier([]);

  /// Store anomalies per grid
  final Map<LatLng, List<AnomalyMarker>> _anomalyCache = {};

  /// Adds new anomalies from a fetched grid
  void addAnomalies(LatLng gridCenter, List<AnomalyMarker> anomalies) {
    if (_anomalyCache.containsKey(gridCenter)) return; // Skip if already cached

    _anomalyCache[gridCenter] = anomalies;

    // Flatten all anomalies across grids for the map
    markersNotifier.value =
        _anomalyCache.values.expand((list) => list).toList();

    notifyListeners();
  }
}

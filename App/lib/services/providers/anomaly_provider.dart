import 'package:flutter/foundation.dart';

import '../../data/models/anomaly_marker_model.dart';

class AnomalyProvider extends ChangeNotifier {
  final List<AnomalyMarker> _anomalies = [];
  ValueNotifier<List<AnomalyMarker>> markersNotifier =
      ValueNotifier<List<AnomalyMarker>>([]);

  List<AnomalyMarker> get anomalies => List.unmodifiable(_anomalies);

  void addAnomalies(List<AnomalyMarker> anomalies) {
    bool updated = false;

    for (var anomaly in anomalies) {
      if (!_anomalies.contains(anomaly)) {
        _anomalies.add(anomaly);
        updated = true;
      }
    }

    if (updated) {
      markersNotifier.value = List.from(_anomalies);
      notifyListeners();
    }
  }

  void clearAnomalies() {
    _anomalies.clear();
    markersNotifier.value = [];
    notifyListeners();
  }
}

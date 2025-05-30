import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/anomaly_marker_model.dart';

class AnomalyProvider extends ChangeNotifier {
  final ValueNotifier<List<AnomalyMarker>> markersNotifier = ValueNotifier([]);

  /// Stored key value pairs of cached anomalies, key being the grid center and value is a list of anomaly markers
  final Map<LatLng, List<AnomalyMarker>> _anomalyCache = {};
  late Box<List<dynamic>> _hiveBox;

  /// Initialize Hive and load stored anomalies
  Future<void> init() async {
    _hiveBox = await Hive.openBox<List<dynamic>>('anomalies');
    // _loadCachedAnomalies();
  }

  void _loadCachedAnomalies() {
    dev.log("Loading cached anomalies");
    if (_hiveBox.isNotEmpty) {
      _anomalyCache.clear();

      for (var key in _hiveBox.keys) {
        if (key is String) {
          LatLng gridCenter = _parseLatLng(key);
          List<dynamic>? rawList = _hiveBox.get(key);
          if (rawList != null) {
            _anomalyCache[gridCenter] = rawList.cast<AnomalyMarker>();
          }
        }
      }
    }
    _updateMarkers();
  }

  void _updateMarkers() {
    markersNotifier.value =
        _anomalyCache.values.expand((list) => list).toList();
    notifyListeners();
  }

  void addAnomalies(LatLng gridCenter, List<AnomalyMarker> anomalies) {
    final isReplace = _anomalyCache.containsKey(gridCenter);

    _anomalyCache[gridCenter] = anomalies;
    _hiveBox.put(_latLngToKey(gridCenter), anomalies);

    dev.log("${isReplace ? "Replaced" : "Added"} anomalies for $gridCenter");
    _updateMarkers();
  }

  /// Helper: Convert LatLng to a string key for Hive storage
  String _latLngToKey(LatLng latLng) =>
      "${latLng.latitude},${latLng.longitude}";

  /// Helper: Convert string key back to LatLng
  LatLng _parseLatLng(String key) {
    try {
      var parts = key.split(',');
      if (parts.length != 2) {
        throw FormatException("Invalid LatLng format: $key");
      }

      double lat = double.parse(parts[0].trim());
      double lon = double.parse(parts[1].trim());

      return LatLng(lat, lon);
    } catch (e) {
      print("Error parsing LatLng: $key -> $e");
      return LatLng(0, 0);
    }
  }
}

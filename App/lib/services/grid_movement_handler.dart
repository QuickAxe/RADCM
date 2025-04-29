import 'dart:async';
import 'dart:developer';

import 'package:app/services/providers/anomaly_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../data/models/anomaly_marker_model.dart';
import 'api_service/dio_client_user_service.dart';

class GridMovementHandler {
  final MapController mapController;
  final double gridSize = 0.72; // 80km grid in degrees
  Timer? _debounceTimer;
  final Set<LatLng> visitedGrids = {};
  final Map<LatLng, List<AnomalyMarker>> anomalyCache = {};
  final BuildContext context;
  late Box<List<String>> _hiveBox; // to load visitedGrids from cache

  GridMovementHandler({required this.mapController, required this.context}) {
    _initHive().then((_) {
      mapController.mapEventStream.listen((event) {
        _onMapMoved();
      });
      _onMapMoved();
    });
  }

  final DioClientUser _dioClient = DioClientUser();

  Future<void> _initHive() async {
    _hiveBox = await Hive.openBox<List<String>>('visitedGrids');

    LatLng mapCenter = mapController.camera.center;
    _checkIfMovedToNewGrid(mapCenter);
    // _loadVisitedGrids();
  }

  void _loadVisitedGrids() {
    List<String> storedGrids = _hiveBox.get('visitedGrids', defaultValue: [])!;
    for (var key in storedGrids) {
      visitedGrids.add(_parseLatLng(key));
    }
    log("Loaded visited grids from hive, size of visitedGrids: ${visitedGrids.length}");
  }

  String _latLngToKey(LatLng latLng) =>
      "${latLng.latitude},${latLng.longitude}";

  /// Convert string back to LatLng
  LatLng _parseLatLng(String key) {
    var parts = key.split(',');
    return LatLng(double.parse(parts[0]), double.parse(parts[1]));
  }

  void _onMapMoved() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      final mapCenter = mapController.camera.center;
      _checkIfMovedToNewGrid(mapCenter);
    });
  }

  void _checkIfMovedToNewGrid(LatLng newCenter) {
    LatLng newGridCenter = getGridCenter(newCenter);

    if (visitedGrids.contains(newGridCenter)) {
      log("Already visited grid: $newGridCenter");
      return; // Skip API call if already visited
    }

    log("Moved to a new grid! Fetching anomalies for: $newGridCenter");

    _fetchAnomalies(newGridCenter);
  }

  /// Finds the grid center for a given point
  LatLng getGridCenter(LatLng point) {
    double lat =
        (point.latitude / gridSize).floor() * gridSize + (gridSize / 2);
    double lon =
        (point.longitude / gridSize).floor() * gridSize + (gridSize / 2);
    return LatLng(lat, lon);
  }

  /// Fetch anomalies for a given grid center
  Future<void> _fetchAnomalies(LatLng gridCenter) async {
    try {
      final response = await _dioClient.getRequest('anomalies/', queryParams: {
        "latitude": gridCenter.latitude,
        "longitude": gridCenter.longitude,
        // NOTE: Radius is an optional parameter
      });

      // error fetching
      if (!response.success) {
        throw Exception("API call failed");
      } else if (response.data == null) {
        throw Exception("API returned null data");
      }

      // fetch successful
      final List<dynamic> anomalies = response.data['anomalies'] ?? [];

      List<AnomalyMarker> anomalyList = anomalies.map((anomaly) {
        return AnomalyMarker(
          latitude: anomaly['latitude'],
          longitude: anomaly['longitude'],
          category: anomaly['category'],
        );
      }).toList();

      // store gridCenter -> anomalyList -- in Memory
      anomalyCache[gridCenter] = anomalyList;

      // add it to the providers list (this overrides)
      Provider.of<AnomalyProvider>(context, listen: false)
          .addAnomalies(gridCenter, anomalyList);

      // store the visited grid -- in Memory
      visitedGrids.add(gridCenter);

      // update the stored anomalies in Hive
      _saveVisitedGrids();
    } catch (e) {
      log("Error fetching anomalies: $e");
    }
  }

  void _saveVisitedGrids() {
    List<String> storedGrids =
        visitedGrids.map((grid) => _latLngToKey(grid)).toList();
    log("Saved visited grids in Hive");
    _hiveBox.put('visitedGrids', storedGrids);
  }
}

import 'dart:async';
import 'dart:developer' as dev;
import 'dart:developer';

import 'package:admin_app/services/providers/anomaly_provider.dart';
import 'package:admin_app/services/providers/user_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../data/models/anomaly_marker_model.dart';
import 'api services/dio_client_user_service.dart';

class GridMovementHandler {
  static GridMovementHandler? _instance;

  final MapController mapController;
  final BuildContext context;
  final UserSettingsProvider userSettingsProvider;
  bool _listenerAttached = false;

  final double gridSize = 0.72; // 80km grid in degrees
  Timer? _debounceTimer;

  GridMovementHandler._internal(
      this.mapController, this.userSettingsProvider, this.context) {
    _initHive().then((_) {
      _attachMapListener();
    });
    log("GridMovementHandler initialized --------------------------------------------");
  }

  static void initOnce({
    required MapController mapController,
    required UserSettingsProvider userSettingsProvider,
    required BuildContext context,
  }) {
    dev.log(
        'UserSettingsProvider in initOnce: $userSettingsProvider ------------------------------');
    _instance ??= GridMovementHandler._internal(
        mapController, userSettingsProvider, context);
    _instance?._onMapMoved();
  }

  static GridMovementHandler get instance {
    assert(
      _instance != null,
      'GridMovementHandler.initOnce() must be called before accessing the instance.',
    );
    return _instance!;
  }

  Future<void> _initHive() async {
    _hiveBox = await Hive.openBox<List<String>>('visitedGrids');
  }

  void _attachMapListener() {
    if (_listenerAttached) return;
    _listenerAttached = true;
    mapController.mapEventStream.listen((event) {
      _onMapMoved();
    });
  }

  void _onMapMoved() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      final mapCenter = mapController.camera.center;
      _checkIfMovedToNewGrid(mapCenter);
    });
  }

  final Set<LatLng> visitedGrids = {};
  final Map<LatLng, List<AnomalyMarker>> anomalyCache = {};
  late Box<List<String>> _hiveBox; // to load visitedGrids from cache

  void _loadVisitedGrids() {
    List<String> storedGrids = _hiveBox.get('visitedGrids', defaultValue: [])!;
    for (var key in storedGrids) {
      visitedGrids.add(_parseLatLng(key));
    }
    log("Loaded visited grids from hive, size of visitedGrids: ${visitedGrids.length}");
  }

  void _checkIfMovedToNewGrid(LatLng newCenter) {
    LatLng newGridCenter = getGridCenter(newCenter);

    if (visitedGrids.contains(newGridCenter)) {
      log("Already visited grid: $newGridCenter");
      return; // Skip API call if already visited
    }

    log("Moved to a new grid! Fetching anomalies for: $newGridCenter");

    userSettingsProvider.setFetchingAnomalies(true);
    userSettingsProvider.setDirtyAnomalies(true);
    _fetchAnomalies(newGridCenter);
  }

  /// Fetch anomalies for a given grid center
  Future<void> _fetchAnomalies(LatLng gridCenter) async {
    final DioClientUser dioClient = DioClientUser();
    try {
      final response = await dioClient.getRequest('anomalies/', queryParams: {
        "latitude": gridCenter.latitude,
        "longitude": gridCenter.longitude,
        // NOTE: Radius is an optional parameter
      });

      userSettingsProvider.setFetchingAnomalies(false);

      // error fetching
      if (!response.success) {
        throw Exception("API call failed");
      } else if (response.data == null) {
        throw Exception("API returned null data");
      }

      userSettingsProvider.setDirtyAnomalies(false);

      // fetch successful
      final List<dynamic> anomalies = response.data['anomalies'] ?? [];

      List<AnomalyMarker> anomalyList = anomalies.map((anomaly) {
        return AnomalyMarker(
          latitude: anomaly['latitude'],
          longitude: anomaly['longitude'],
          category: anomaly['category'],
          cid: anomaly['anomaly_id'],
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
      userSettingsProvider.setDirtyAnomalies(true);
      log("Error fetching anomalies: $e");
    }
  }

  /// refreshes all the anomalies fetched so far, called when a websocket event is detected, indicating an anomaly fix or addition
  Future<void> handleWebsocketAnomalyUpdate() async {
    // these flags are required for the on-screen fetch indicator
    userSettingsProvider.setFetchingAnomalies(true);
    userSettingsProvider.setDirtyAnomalies(true);

    try {
      // for every gridCenter for which anomalies have been fetched, re-fetch the anomalies
      for (LatLng gridCenter in anomalyCache.keys) {
        await _fetchAnomalies(gridCenter);
      }

      // flags go false if all fetches were successful
      userSettingsProvider.setFetchingAnomalies(false);
      userSettingsProvider.setDirtyAnomalies(false);
    } catch (e) {
      log("error handling websocket anomaly update: $e");
      userSettingsProvider.setFetchingAnomalies(false);
      userSettingsProvider.setDirtyAnomalies(true);
    }
  }

  /// stringifies all visitedGrids and stores them in a hive box as a list of strings
  void _saveVisitedGrids() {
    List<String> storedGrids =
        visitedGrids.map((grid) => _latLngToKey(grid)).toList();
    log("Saved visited grids in Hive");
    _hiveBox.put('visitedGrids', storedGrids);
  }

  // Helper functions
  /// Finds the grid center for a given point
  LatLng getGridCenter(LatLng point) {
    double lat =
        (point.latitude / gridSize).floor() * gridSize + (gridSize / 2);
    double lon =
        (point.longitude / gridSize).floor() * gridSize + (gridSize / 2);
    return LatLng(lat, lon);
  }

  /// Converts a LatLng to a string to be used as a key in hive
  String _latLngToKey(LatLng latLng) =>
      "${latLng.latitude},${latLng.longitude}";

  /// Convert string back to LatLng
  LatLng _parseLatLng(String key) {
    var parts = key.split(',');
    return LatLng(double.parse(parts[0]), double.parse(parts[1]));
  }
}

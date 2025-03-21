import 'dart:async';

import 'package:app/services/providers/anomaly_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
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

  GridMovementHandler({required this.mapController, required this.context}) {
    mapController.mapEventStream.listen((event) {
      _onMapMoved();
    });
    _onMapMoved();
  }

  final DioClientUser _dioClient = DioClientUser();

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
      print("Already visited grid: $newGridCenter");
      return; // Skip API call if already visited
    }

    print("Moved to a new grid! Fetching anomalies for: $newGridCenter");

    visitedGrids.add(newGridCenter);

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

      if (response.success && response.data != null) {
        final Map<String, dynamic> jsonResponse = response.data;
        final List<dynamic> anomalies = jsonResponse['anomalies'] ?? [];

        List<AnomalyMarker> anomalyList = anomalies.map((anomaly) {
          return AnomalyMarker(
            location: LatLng(anomaly['latitude'], anomaly['longitude']),
            category: anomaly['category'],
          );
        }).toList();

        anomalyCache[gridCenter] = anomalyList; // Store anomalies in cache
        Provider.of<AnomalyProvider>(context, listen: false)
            .addAnomalies(gridCenter, anomalyList);

        print("Fetched ${anomalyList.length} anomalies for $gridCenter");
      } else {
        print("Failed to fetch anomalies. Error: ${response.errorMessage}");
      }
    } catch (e) {
      print("Error fetching anomalies: $e");
    }
  }
}

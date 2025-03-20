import 'dart:async';
import 'dart:developer';

import 'package:app/services/providers/anomaly_provider.dart';
import 'package:latlong2/latlong.dart';

import '../data/models/anomaly_marker_model.dart';
import 'api_service/dio_client_user_service.dart';

class AnomalyGridService {
  final DioClientUser _dioClient = DioClientUser();
  double gridSize = 0.011; // default grid size, 1deg
  // lat:lon : List<{"latitude": ..., "longitude": ..., "category": ...}>
  final Map<String, Map<String, dynamic>> _cache = {};
  final AnomalyProvider anomalyProvider;
  Timer? _debounceTimer;

  AnomalyGridService({required this.anomalyProvider, this.gridSize = 0.011});

  /// maps `gridSize` with zoom levels
  // void updateGridSize(double zoom) {
  //   if (zoom > 15) {
  //     gridSize = 0.0025;
  //   } else if (zoom > 13) {
  //     gridSize = 0.005;
  //   } else if (zoom > 11) {
  //     gridSize = 0.01;
  //   } else if (zoom > 9) {
  //     gridSize = 0.02;
  //   } else {
  //     gridSize = 0.05;
  //   }
  // }

  /// lat/lng -> grid cell ID (lat:lng)
  String _gridCellId(LatLng point) {
    final latCell = (point.latitude / gridSize).floor();
    final lngCell = (point.longitude / gridSize).floor();
    return '$latCell:$lngCell';
  }

  /// calculate the center of a grid cell
  LatLng _cellCenter(String cellId) {
    final parts = cellId.split(':');
    final latCell = int.parse(parts[0]);
    final lngCell = int.parse(parts[1]);
    return LatLng((latCell + 0.5) * gridSize, (lngCell + 0.5) * gridSize);
  }

  /// gets all visible grid cells based on current map bounds.
  Set<String> _getVisibleGridCells(LatLng sw, LatLng ne) {
    final cells = <String>{};
    for (double lat = sw.latitude; lat <= ne.latitude; lat += gridSize) {
      for (double lng = sw.longitude; lng <= ne.longitude; lng += gridSize) {
        cells.add(_gridCellId(LatLng(lat, lng)));
      }
    }
    return cells;
  }

  void onMapViewChanged(LatLng sw, LatLng ne, double zoom) {
    // updateGridSize(zoom); commenting this cuz of the overlapping issue
    _debounceTimer?.cancel();

    int debounceTime = 1000; // default wait before fetch 1sec
    if (_debounceTimer != null) {
      debounceTime = 1000; // increase debounce if move too quick
    }

    _debounceTimer = Timer(Duration(milliseconds: debounceTime), () {
      final visibleCells = _getVisibleGridCells(sw, ne);
      log("Zoom Level: $zoom | Grid Size: $gridSize");
      log("Visible Grid Cells: $visibleCells");

      for (var cellId in visibleCells) {
        LatLng center = _cellCenter(cellId);
        if (_cache.containsKey(cellId)) {
          log("Cache hit for $cellId. Skipping API call.");
          continue;
        }

        fetchAnomaliesForCell(cellId, center);
      }
    });
  }

  Future<void> fetchAnomaliesForCell(String cellId, LatLng center) async {
    // set a temp cache expiry to 60mins
    const Duration cacheDuration = Duration(minutes: 60);

    // cached? valid?
    if (_cache.containsKey(cellId)) {
      final timestamp = _cache[cellId]!['timestamp'] as DateTime;
      if (DateTime.now().difference(timestamp) < cacheDuration) {
        log("Cache valid for $cellId. Skipping API call.");
        return; // skip api call
      }
    }

    try {
      final response = await _dioClient.getRequest('anomalies/', queryParams: {
        "latitude": center.latitude,
        "longitude": center.longitude,
      });
      // final response = await http.get(
      //   Uri.parse(
      //       'https://b170-152-57-245-40.ngrok-free.app/api/anomalies?latitude=${center.latitude}&longitude=${center.longitude}'),
      //   headers: {'ngrok-skip-browser-warning': 'true'},
      // );

      if (response.success) {
        final data = response.data;
        final anomaliesData = data['anomalies'] ?? [];

        if (anomaliesData is! List) {
          log("Unexpected API response for $cellId: $data");
          return;
        }

        List<Map<String, dynamic>> parsedAnomalies =
            anomaliesData.cast<Map<String, dynamic>>();

        List<AnomalyMarker> anomalies = parsedAnomalies.map((item) {
          return AnomalyMarker(
            location: LatLng(item['latitude'], item['longitude']),
            category: item['category'],
          );
        }).toList();

        // Store in cache **with timestamp**
        _cache[cellId] = {'anomalies': anomalies, 'timestamp': DateTime.now()};

        // Update the provider only with **new anomalies**
        anomalyProvider.addAnomalies(anomalies);

        log("Fetched anomalies for $cellId: ${anomalies.length}");
      } else {
        log("API failed for $cellId with status: ${response.errorMessage}");
      }
    } catch (e) {
      log("Error fetching anomalies for $cellId: $e");
    }
  }
}

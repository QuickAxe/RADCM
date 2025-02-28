import 'dart:developer' as dev;

import 'package:app/services/providers/permissions.dart';
import 'package:app/services/providers/search.dart';
import 'package:app/services/providers/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../data/models/osrm_models.dart';
import '../../data/repository/osrm_repository.dart';

/// Provider class that handles fetching the route, and other routing related processes
class MapRouteProvider with ChangeNotifier {
  final OSRMRepository repository = OSRMRepository();

  double startLat = 15.49613530624519,
      startLng = 73.82646130357969,
      endLat = 15.60000652430488,
      endLng = 73.82570085490943;

  List<List<LatLng>> alternativeMatchings = [];
  List<MatchingModel> alternativeMatchingModels = [];

  // UI state
  bool isLoading = true;
  int selectedMatchingIndex = -1;
  bool startNavigation = false;

  // Store calculated bounds for the route
  late LatLngBounds bounds;

  /// Initialize the provider by fetching routes.
  Future<void> initialize(BuildContext context) async {
    final searchProvider = Provider.of<Search>(context, listen: false);
    final permissionsProvider =
        Provider.of<Permissions>(context, listen: false);

    // sets destination to the currently selected place
    if (searchProvider.isCurrentSelected &&
        searchProvider.currentSelected != null) {
      double? parsedLat =
          double.tryParse(searchProvider.currentSelected['lat']);
      double? parsedLng =
          double.tryParse(searchProvider.currentSelected['lon']);
      if (parsedLat != null && parsedLng != null) {
        endLat = parsedLat;
        endLng = parsedLng;
      }
    }
    // users current pos as starting point
    if (permissionsProvider.position != null) {
      startLat = permissionsProvider.position!.latitude;
      startLng = permissionsProvider.position!.longitude;
    }
    await _loadRoutes(context);
  }

  Future<void> _loadRoutes(BuildContext context) async {
    try {
      final userSettings =
          Provider.of<UserSettingsProvider>(context, listen: false);
      // TODO: Handle passing profiles n all later
      RouteResponse routeResponse = await repository.fetchMatchedRoute(
        startLat: startLat,
        startLng: startLng,
        endLat: endLat,
        endLng: endLng,
      );

      List<List<LatLng>> matchingList = [];
      List<MatchingModel> matchingModels = [];

      for (MatchingModel matching in routeResponse.matchings) {
        matchingModels.add(matching);
        if (matching.geometry.coordinates.isNotEmpty) {
          matchingList.add(matching.geometry.coordinates);
        }
      }

      // Update state
      alternativeMatchings = matchingList;
      alternativeMatchingModels = matchingModels;
      isLoading = false;

      if (alternativeMatchingModels.isNotEmpty) {
        selectedMatchingIndex = 0;
        _calculateBounds(alternativeMatchings[0]);
      }
    } catch (e) {
      dev.log("Error loading routes: $e");
      isLoading = false;
    }
    notifyListeners();
  }

  /// Calculate the bounds for a set of route points.
  void _calculateBounds(List<LatLng> routePoints) {
    if (routePoints.isEmpty) return;

    double minLat =
        routePoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat =
        routePoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng =
        routePoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng =
        routePoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    bounds = LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
  }

  /// Update selected route index and recalculate bounds.
  void updateSelectedRoute(int index) {
    selectedMatchingIndex = index;
    if (index < alternativeMatchings.length) {
      // When a route is selected it is fit in the screen
      _calculateBounds(alternativeMatchings[index]);
    }
    notifyListeners();
  }

  /// Mark that the navigation has started.
  void startRouteNavigation() {
    startNavigation = true;
    notifyListeners();
  }

  /// Mark that the navigation has stopped
  void stopRouteNavigation() {
    startNavigation = false;
    notifyListeners();
  }

  void flushRoutes() {
    isLoading = true;
  }

  /// Get the current MatchingModel
  MatchingModel get currentMatching => (selectedMatchingIndex >= 0 &&
          selectedMatchingIndex < alternativeMatchingModels.length)
      ? alternativeMatchingModels[selectedMatchingIndex]
      : MatchingModel(
          confidence: 0,
          geometry: Geometry(coordinates: [], type: ""),
          weightName: "",
          weight: 0,
          legs: [],
          distance: 0,
          duration: 0);

  /// Get current matching points List<LatLng>
  List<LatLng> get currentMatchingPoints => (selectedMatchingIndex >= 0 &&
          selectedMatchingIndex < alternativeMatchings.length)
      ? alternativeMatchings[selectedMatchingIndex]
      : [];
}

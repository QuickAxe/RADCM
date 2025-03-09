import 'dart:developer' as dev;

import 'package:app/services/providers/permissions.dart';
import 'package:app/services/providers/search.dart';
import 'package:app/services/providers/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../data/models/route_models.dart';
import '../../data/repository/route_repository.dart';

/// Provider class that handles fetching the route and other routing-related processes.
class RouteProvider with ChangeNotifier {
  final RouteRepository repository = RouteRepository();

  double startLat = 15.49613530624519,
      startLng = 73.82646130357969,
      endLat = 15.60000652430488,
      endLng = 73.82570085490943;

  List<RouteModel> alternativeRoutes = []; // Stores multiple routes
  bool isLoading = true;
  bool routeAvailable = true;
  int selectedRouteIndex = -1;
  bool startNavigation = false;

  // Stores calculated bounds for the selected route
  late LatLngBounds bounds;

  /// Initialize the provider by fetching routes.
  Future<void> initialize(BuildContext context) async {
    final searchProvider = Provider.of<Search>(context, listen: false);
    final permissionsProvider =
        Provider.of<Permissions>(context, listen: false);

    // Set destination to the currently selected place
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

    // Use user's current position as the starting point
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

      // Fetch routes from the repository
      dev.log("Before calling the fetchRoute repo function.");
      RouteResponse routeResponse = await repository.fetchRoute(
        startLat: startLat,
        startLng: startLng,
        endLat: endLat,
        endLng: endLng,
      );

      dev.log(routeResponse.toString());

      alternativeRoutes = routeResponse.routes;
      isLoading = false;

      if (alternativeRoutes.isNotEmpty) {
        selectedRouteIndex = 0;
        _calculateBounds(alternativeRoutes.first);
      }
    } catch (e) {
      dev.log("Inside routeProvider, Error loading routes: $e");
      isLoading = false;
      routeAvailable = false;
    }
    notifyListeners();
  }

  void setLoading() {
    isLoading = true;
    notifyListeners();
  }

  /// Calculate the bounds for a given route.
  void _calculateBounds(RouteModel route) {
    List<LatLng> routePoints =
        route.segments.expand((s) => s.geometry.coordinates).toList();
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
    if (index >= 0 && index < alternativeRoutes.length) {
      selectedRouteIndex = index;
      _calculateBounds(alternativeRoutes[index]);
      notifyListeners();
    }
  }

  /// Mark that the navigation has started.
  void startRouteNavigation() {
    startNavigation = true;
    notifyListeners();
  }

  /// Mark that the navigation has stopped.
  void stopRouteNavigation() {
    startNavigation = false;
    notifyListeners();
  }

  void flushRoutes() {
    isLoading = true;
  }

  /// Get the currently selected route.
  RouteModel get currentRoute =>
      (selectedRouteIndex >= 0 && selectedRouteIndex < alternativeRoutes.length)
          ? alternativeRoutes[selectedRouteIndex]
          : RouteModel(segments: [], legs: []);

  /// Get the segments of the currently selected route.
  List<RouteSegment> get currentRouteSegments => currentRoute?.segments ?? [];

  /// Get the coordinates of the currently selected route.
  List<LatLng> get currentRoutePoints =>
      currentRouteSegments.expand((s) => s.geometry.coordinates).toList();
}

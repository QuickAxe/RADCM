import 'dart:developer' as dev;

import 'package:app/services/providers/permissions.dart';
import 'package:app/services/providers/search.dart';
import 'package:app/services/providers/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../data/models/osrm_models.dart';
import '../../data/repository/osrm_repository.dart';

/// Provider class that handles fetching the route, and other routing related processes
class MapRouteProvider with ChangeNotifier {
  final OSRMRepository repository = OSRMRepository();

  // Coordinates for start and destination.
  double startLat = 15.49613530624519,
      startLng = 73.82646130357969,
      endLat = 15.60000652430488,
      endLng = 73.82570085490943;

  // Data from the API
  List<List<LatLng>> alternativeRoutes = [];
  List<RouteModel> routes = [];
  // RouteModel contains: legs, distance, duration, summary

  // UI state
  bool isLoading = true;
  int selectedRouteIndex = -1;
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
      // This is the JSON response
      RouteResponse routeResponse = await repository.fetchRoute(
        startLat: startLat,
        startLng: startLng,
        endLat: endLat,
        endLng: endLng,
        profile: userSettings.profile,
      );

      // these are all the alternative routes
      List<List<LatLng>> routesList = [];
      // list of routes fetched in terms of RouteResponse
      List<RouteModel> routeModels = [];

      // Get an instance of PolylinePoints to decode Polyline -> List<LatLng>
      PolylinePoints polylinePoints = PolylinePoints();

      // the response is an already constructed RouteResponse data model
      for (RouteModel route in routeResponse.routes) {
        routeModels.add(route);
        if (route.legs.isNotEmpty) {
          final leg = route.legs.first;
          List<LatLng> decodedPoints = [];
          for (var step in leg.steps) {
            // converts the encoded Polyline of the geometry to a list of LatLng
            final points = polylinePoints.decodePolyline(step.geometry);
            decodedPoints
                .addAll(points.map((p) => LatLng(p.latitude, p.longitude)));
          }
          // after decoding all steps in a leg, we add it to routeslist (alternate routes basically)
          routesList.add(decodedPoints);
        }
      }

      // Update state
      alternativeRoutes = routesList;
      routes = routeModels;
      isLoading = false;
      if (routes.isNotEmpty) {
        selectedRouteIndex = 0;
        _calculateBounds(alternativeRoutes[0]);
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
    selectedRouteIndex = index;
    if (index < alternativeRoutes.length) {
      // When a route is selected it is fit in the screen
      _calculateBounds(alternativeRoutes[index]);
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

  /// Get the current RouteModel
  RouteModel get currentRoute =>
      (selectedRouteIndex >= 0 && selectedRouteIndex < routes.length)
          ? routes[selectedRouteIndex]
          : RouteModel(legs: [], distance: 0, duration: 0, summary: '');

  /// Get current route points List<LatLng>
  List<LatLng> get currentRoutePoints =>
      (selectedRouteIndex >= 0 && selectedRouteIndex < alternativeRoutes.length)
          ? alternativeRoutes[selectedRouteIndex]
          : [];
}

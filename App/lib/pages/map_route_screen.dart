import 'dart:developer' as dev;

import 'package:flutter/material.dart' hide Step;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../data/models/osrm_models.dart';
import '../data/repository/osrm_repository.dart';
import '../services/providers/permissions.dart';
import '../services/providers/search.dart';

class MapRouteScreen extends StatefulWidget {
  const MapRouteScreen({super.key});

  @override
  State<MapRouteScreen> createState() => _MapRouteScreenState();
}

class _MapRouteScreenState extends State<MapRouteScreen> {
  final OSRMRepository repository = OSRMRepository();
  final MapController _mapController = MapController();

  // alternative routes (decoded polyline points)
  List<List<LatLng>> alternativeRoutes = [];
  // route details (for distance, duration, and detailed directions)
  List<RouteModel> routes = [];
  bool isLoading = true;

  late double startLat, startLng, endLat, endLng;
  late LatLngBounds bounds;

  // index of the currently selected route
  int selectedRouteIndex = -1;

  @override
  void initState() {
    super.initState();
    // fallback coordinates.
    endLat = 15.60000652430488;
    endLng = 73.82570085490943;
    startLat = 15.49613530624519;
    startLng = 73.82646130357969;

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

    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    try {
      RouteResponse routeResponse = await repository.fetchRoute(
        startLat: startLat,
        startLng: startLng,
        endLat: endLat,
        endLng: endLng,
      );

      List<List<LatLng>> routesList = [];
      List<RouteModel> routeModels = [];
      PolylinePoints polylinePoints = PolylinePoints();

      // process each alternative route.
      for (RouteModel route in routeResponse.routes) {
        routeModels.add(route);

        if (route.legs.isNotEmpty) {
          Leg leg = route.legs.first;
          List<LatLng> decodedPoints = [];
          // here we are basically going over every step in the leg and converting it from polyline to a list of LatLng stored in decodedPoints
          for (Step step in leg.steps) {
            List<PointLatLng> points =
                polylinePoints.decodePolyline(step.geometry);
            decodedPoints
                .addAll(points.map((p) => LatLng(p.latitude, p.longitude)));
          }
          // finally adding all the decoded points in the routelist (this stores all the routes that were found)
          routesList.add(decodedPoints);
        }
      }

      setState(() {
        alternativeRoutes = routesList;
        routes = routeModels;
        isLoading = false;
        // defaults to the first route
        if (routes.isNotEmpty) {
          selectedRouteIndex = 0;
          _fitMapToRoute(routesList[0]);
        }
      });
    } catch (e) {
      dev.log("Error loading routes: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _fitMapToRoute(List<LatLng> routePoints) {
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
    _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50.0)));
  }

  Color getColorForRoute(int index) {
    List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange
    ];
    return colors[index % colors.length];
  }

  String formatDuration(double seconds) {
    int totalSeconds = seconds.round();
    int minutes = totalSeconds ~/ 60;
    int remainingSeconds = totalSeconds % 60;
    return "$minutes min $remainingSeconds sec";
  }

  // m -> km
  String formatDistance(double meters) {
    double km = meters / 1000;
    return "${km.toStringAsFixed(2)} km";
  }

  // directions widget for every route
  Widget buildDetailedDirections(RouteModel route) {
    if (route.legs.isEmpty) return Container(); // route got no legs :/
    Leg leg = route.legs.first;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: leg.steps.length,
      padding: EdgeInsets.zero,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        Step step = leg.steps[index];
        String instruction = step.maneuver.type;
        if (step.maneuver.modifier != null) {
          instruction += " (${step.maneuver.modifier})";
        }
        instruction += " on ${step.name}";
        return ListTile(
          leading: Text("${index + 1}"),
          title: Text(
            instruction,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
              "Distance: ${step.distance.toStringAsFixed(0)} m, Duration: ${step.duration.toStringAsFixed(0)} sec"),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SlidingUpPanel(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0)),
              minHeight: 200,
              maxHeight: 700,
              panel: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      "Select a Route",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    // list of routes
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: routes.length,
                      itemBuilder: (context, index) {
                        final route = routes[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: getColorForRoute(index),
                            child: Text('${index + 1}'),
                          ),
                          title: Text(
                            "Route ${index + 1}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Distance: ${formatDistance(route.distance)} | Duration: ${formatDuration(route.duration)}",
                          ),
                          selected: selectedRouteIndex == index,
                          onTap: () {
                            setState(() {
                              selectedRouteIndex = index;
                              _fitMapToRoute(alternativeRoutes[index]);
                            });
                          },
                        );
                      },
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    if (selectedRouteIndex >= 0 &&
                        selectedRouteIndex < routes.length)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const Text(
                                "Detailed Directions",
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              buildDetailedDirections(
                                  routes[selectedRouteIndex]),
                            ],
                          ),
                        ),
                      )
                  ],
                ),
              ),
              body: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(startLat, startLng),
                  initialZoom: 14.0,
                  // onMapReady: () {
                  //   if (alternativeRoutes.isNotEmpty &&
                  //       selectedRouteIndex >= 0) {
                  //     _fitMapToRoute(alternativeRoutes[selectedRouteIndex]);
                  //   }
                  // },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  // Draw all alternative routes.
                  PolylineLayer(
                    polylines: [
                      for (int i = 0; i < alternativeRoutes.length; i++)
                        Polyline(
                          points: alternativeRoutes[i],
                          strokeWidth: selectedRouteIndex == i ? 6.0 : 4.0,
                          color: selectedRouteIndex == i
                              ? getColorForRoute(i).withOpacity(0.8)
                              : getColorForRoute(i).withOpacity(0.5),
                        ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

import 'package:admin_app/utils/marker_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../components/attribution.dart';
import '../data/models/anomaly_marker_model.dart';
import '../services/providers/user_settings.dart';
import '../utils/fix_anomaly_dialog.dart';
import '../utils/map_utils.dart';
import 'map_route_screen.dart';

class AnomalyDetailPage extends StatelessWidget {
  final AnomalyMarker anomaly;

  const AnomalyDetailPage({super.key, required this.anomaly});

  Future<String> _getAddress(LatLng location) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(location.latitude, location.longitude);
      if (placemarks.isNotEmpty) {
        return "${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country}";
      }
    } catch (e) {
      return "Address not available";
    }
    return "Address not available";
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<UserSettingsProvider, ThemeMode>(
      (settings) => settings.themeMode,
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Top half: Map view
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: anomaly.location,
                      initialZoom: 18.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://tile.sorciermahep.tech/{z}/{x}/{y}.png",
                        // tileBuilder: themeMode == ThemeMode.dark
                        //     ? customDarkModeTileBuilder
                        //     : null,
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 50.0,
                            height: 50.0,
                            point: anomaly.location,
                            child: mapMarkerIcon(
                                getAnomalyIcon(anomaly.category),
                                colorScheme.surfaceDim),
                          ),
                        ],
                      ),
                      const Attribution(),
                    ],
                  ),
                ),
              ),

              // Bottom half: Details
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        anomaly.category,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<String>(
                        future: _getAddress(anomaly.location),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? "Fetching address...",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // "Go to Anomaly" Button
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MapRouteScreen(
                                      endLat: anomaly.location.latitude,
                                      endLng: anomaly.location.longitude,
                                    ),
                                  ),
                                );
                              },
                              child: const Text("Go to Anomaly"),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                showAnomalyDialog(
                                    context,
                                    anomaly.location.latitude,
                                    anomaly.location.longitude);
                              },
                              child: const Text("Fix Anomaly"),
                            ),
                          ),
                        ],
                      )

                      // const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating back button
          Positioned(
            top: 50,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

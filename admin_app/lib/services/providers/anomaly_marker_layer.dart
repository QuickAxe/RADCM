import 'package:admin_app/services/providers/permissions.dart';
import 'package:admin_app/services/providers/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../data/models/anomaly_marker.dart';
import '../anomaly_marker_service.dart';

// This is the layer that displays the anomalies
class AnomalyMarkerLayer extends StatelessWidget {
  const AnomalyMarkerLayer({super.key});

  // gets the appropriate icon (image asset path) TODO: Mapping redundant, also exists in settings create a single src
  String getAnomalyIcon(String cat) {
    String imageAssetPath = switch (cat) {
      "Speedbreaker" => "assets/icons/ic_speedbreaker.png",
      "Rumbler" => "assets/icons/ic_rumbler.png",
      "Obstacle" => "assets/icons/ic_obstacle.png",
      "Pothole" => "assets/icons/ic_pothole.png",
      _ => "assets/icons/ic_obstacle.png",
    };
    return imageAssetPath;
  }

  Future<void> _showAnomalyDialog(
      BuildContext context, AnomalyMarker anomaly) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        anomaly.location.latitude, anomaly.location.longitude);
    print(placemarks.toString());

    showDialog(
      context: context,
      builder: (context) {
        bool checkboxOne = false; // Initial state
        bool checkboxTwo = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(anomaly.category),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      "${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country} - ${placemarks[0].postalCode}"),
                  Row(
                    children: [
                      Checkbox(
                          value: checkboxOne,
                          onChanged: (bool? value) {
                            setState(() {
                              checkboxOne = value ?? false;
                            });
                          }),
                      const Text("Confirm Inspection")
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                          value: checkboxTwo,
                          onChanged: (bool? value) {
                            setState(() {
                              checkboxTwo = value ?? false;
                            });
                          }),
                      const Text("Attach my signature")
                    ],
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: (checkboxOne && checkboxTwo)
                          ? () {
                              Position? pos = Provider.of<Permissions>(context,
                                      listen: false)
                                  .position;

                              double distance = pos == null
                                  ? 1000.0
                                  : Geolocator.distanceBetween(
                                      pos.latitude,
                                      pos.longitude,
                                      anomaly.location.latitude,
                                      anomaly.location.longitude);

                              if (distance >= 1000.0) {
                                Fluttertoast.showToast(
                                  msg:
                                      "Anomaly is more than a kilometer away!!",
                                  toastLength: Toast.LENGTH_LONG,
                                );
                              } else {
                                Fluttertoast.showToast(
                                  msg: "Anomaly Fixed!",
                                  toastLength: Toast.LENGTH_LONG,
                                );

                                // remove this anomaly or whatever..

                                Navigator.pop(context);
                              }
                            }
                          : null,
                      child: const Text("Mark fixed"),
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // consumes filter because the markers displayed must react to change in filters
    return Consumer<UserSettingsProvider>(
      builder: (context, userSettings, child) {
        // filters list first
        List<AnomalyMarker> visibleAnomalies = AnomalyService.anomalies
            .where(
                (anomaly) => userSettings.showOnMap[anomaly.category] ?? true)
            .toList();

        return MarkerLayer(
          // anomalies from the service class
          markers: visibleAnomalies.map((anomaly) {
            return Marker(
                rotate: true, // so the icon stays upright
                point: anomaly.location,
                child: GestureDetector(
                  onTap: () => _showAnomalyDialog(context, anomaly),
                  child: Image.asset(
                    getAnomalyIcon(anomaly.category),
                    width: 20.0,
                    height: 20.0,
                  ),
                ));
          }).toList(),
        );
      },
    );
  }
}

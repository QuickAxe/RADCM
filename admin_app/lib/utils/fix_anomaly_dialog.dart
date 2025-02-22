import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../services/providers/permissions.dart';

// util to show the dialog box and fix anomaly
Future<void> showAnomalyDialog(
    BuildContext context, double lat, double lon) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
  print(placemarks.toString());

  showDialog(
    context: context,
    builder: (context) {
      bool checkboxOne = false; // Initial state
      bool checkboxTwo = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Center(child: Text('Fix Anomaly')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (checkboxOne && checkboxTwo)
                          ? () {
                              Position? pos = Provider.of<Permissions>(context,
                                      listen: false)
                                  .position;

                              double distance = pos == null
                                  ? 250.0
                                  : Geolocator.distanceBetween(
                                      pos.latitude,
                                      pos.longitude,
                                      lat,
                                      lon,
                                    );

                              if (distance >= 250.0) {
                                Fluttertoast.showToast(
                                  msg: "Anomaly is more than 250m away!!",
                                  toastLength: Toast.LENGTH_LONG,
                                );
                              } else {
                                Fluttertoast.showToast(
                                  msg: "Anomaly Fixed!",
                                  toastLength: Toast.LENGTH_LONG,
                                );

                                // perform map updates here

                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        // Reduced padding
                        textStyle: const TextStyle(fontSize: 14),
                        // Slightly smaller text
                        minimumSize:
                            const Size(0, 40), // Ensures smaller height
                      ),
                      child:
                          const Text("Mark Fixed", textAlign: TextAlign.center),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontSize: 14),
                        minimumSize: const Size(0, 40),
                      ),
                      child: const Text("Cancel", textAlign: TextAlign.center),
                    ),
                  ),
                ],
              )
            ],
          );
        },
      );
    },
  );
}

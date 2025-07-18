import 'package:admin_app/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api services/authority_service.dart';
import '../services/api services/dio_client_auth_service.dart';
import '../services/providers/permissions.dart';
import '../services/providers/route_provider.dart';
import '../services/providers/search.dart';
import '../services/providers/user_settings.dart';

// util to show the dialog box and fix anomaly
Future<void> showAnomalyDialog(
  BuildContext context,
  double lat,
  double lon,
  int cid,
  String cat,
) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
  print(placemarks.toString());
  String anomalyAddress =
      "${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country}";

  showDialog(
    context: context,
    builder: (context) {
      bool checkboxOne = false; // Initial state
      bool checkboxTwo = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            icon: const Icon(Icons.construction_rounded),
            title: Center(child: Text('Fix $cat')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    "$cat Location: $anomalyAddress\n\nPlease confirm the following before marking the anomaly as fixed",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                const Divider(),
                CheckboxListTile(
                  title: Text(
                    "Confirm Inspection",
                    style: context.theme.textTheme.labelLarge,
                  ),
                  value: checkboxOne,
                  onChanged: (bool? value) {
                    setState(() {
                      checkboxOne = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(
                    "Attach my signature",
                    style: context.theme.textTheme.labelLarge,
                  ),
                  value: checkboxTwo,
                  onChanged: (bool? value) {
                    setState(() {
                      checkboxTwo = value ?? false;
                    });
                  },
                ),
              ],
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (checkboxOne && checkboxTwo)
                          ? () async {
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
                                Navigator.pop(context);
                              } else {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                print(prefs.getString(
                                    "--------------------------------------------------"));

                                print(prefs.getString("isDev"));
                                print(prefs.getString("isUser"));
                                if (prefs.getString("isDev") == "true") {
                                  Fluttertoast.showToast(
                                    msg: "No server, brother. Don't be silly!",
                                    toastLength: Toast.LENGTH_LONG,
                                  );
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                } else {
                                  // perform anomaly fix
                                  final authService =
                                      AuthorityService(DioClientAuth());
                                  bool isAuthenticated = await authService
                                      .fixAnomaly(lat, lon, cid);

                                  if (isAuthenticated) {
                                    Fluttertoast.showToast(
                                      msg: "Anomaly Fixed!",
                                      toastLength: Toast.LENGTH_LONG,
                                    );

                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  } else {
                                    Fluttertoast.showToast(
                                      msg:
                                          "Your Session has expired, please login again",
                                      toastLength: Toast.LENGTH_LONG,
                                    );

                                    // LOG OUT AUTHORITY

                                    // clear storage
                                    await DioClientAuth().logout();

                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.remove("isDev");
                                    await prefs.remove("isUser");

                                    if (!context.mounted) return;

                                    // reset providers
                                    Provider.of<Permissions>(context,
                                            listen: false)
                                        .logout();
                                    Provider.of<RouteProvider>(context,
                                            listen: false)
                                        .logout();
                                    Provider.of<Search>(context, listen: false)
                                        .logout();
                                    Provider.of<UserSettingsProvider>(context,
                                            listen: false)
                                        .logout();

                                    await Restart.restartApp();
                                  }
                                }
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
                  const SizedBox(width: 10),
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

import 'dart:convert';
import 'dart:developer' as dev;

import 'package:app/components/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:http/http.dart' as http;
import '../services/providers/permissions.dart';
import '../util/bg_process.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FlutterIsolate dataCollectorIsolate;
  late final MapController _mapController;
  LatLng userLocation = const LatLng(15.49613530624519, 73.82646130357969);
  List<dynamic> searchSuggestions = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  // Fetch multiple places for a search query
  Future<void> getSuggestions(String query) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=50');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        searchSuggestions = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to fetch search results');
    }
    dev.log(searchSuggestions.toString());
  }

  ListTile buildPlaceItem(dynamic place, SearchController controller) {
    return ListTile(
      title: Text(
        place['display_name'] ?? 'Unknown Place',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        place['address']?['country'] ?? 'Address not available',
      ),
      leading: const Icon(Icons.location_on, color: Colors.blue),
      onTap: () {
        LatLng loc = LatLng(double.parse(place['lat']), double.parse(place['lon']));
        userTapsSearchResult(place['display_name'] ?? 'Unknown Place', loc, controller);
      },
    );
  }

  void userTapsSearchResult(String displayName, LatLng loc, SearchController controller) {
    _mapController.move(loc, _mapController.camera.zoom);
    controller.closeView(displayName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      drawer: AppDrawer(),
      body: SlidingUpPanel(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
        maxHeight: 400,
        panel: Column(
          children: [
            // Drag Indicator
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
              child: SearchAnchor(
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    controller: controller,
                    onSubmitted: (_) async {
                      await getSuggestions(controller.text.toString());
                      dev.log(controller.text.toString());
                      controller.openView();
                    },
                    trailing: const <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.search),
                      )
                    ],
                    hintText: "Search Map",
                    elevation: WidgetStateProperty.all(0), // Remove shadow
                  );
                },
                suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                  return List<ListTile>.generate(searchSuggestions.length, (int index) {
                    dev.log(searchSuggestions[index].toString());
                    return buildPlaceItem(searchSuggestions[index], controller);
                  });
                },
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Consumer, listening for position changes
            Consumer<Permissions>(
              builder: (context, permissions, child) {
                if (permissions.position != null) {
                  userLocation = LatLng(
                    permissions.position!.latitude,
                    permissions.position!.longitude,
                  );
                  _mapController.move(userLocation, _mapController.camera.zoom);

                  // Background process spawns
                  dev.log('position: ${permissions.position}');
                  dev.log('background process started.');
                  FlutterIsolate.spawn(theDataCollector, "bg process isolate")
                      .then((isolate) {
                    dataCollectorIsolate = isolate;
                  });
                }

                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: userLocation,
                    initialZoom: 13,
                    maxZoom: 18,
                    minZoom: 3,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    // updates the user location marker
                    if (permissions.position != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: userLocation,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 30.0,
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:app/components/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      drawer: AppDrawer(),
      // floatingActionButton: FloatingActionButton(onPressed: () {/* TODO */}),
      body: SlidingUpPanel(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
        panel: const Center(
          child: Text("This is the bottom panel"),
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: MapController(),
              options: const MapOptions(
                initialCenter: LatLng(15.49613530624519, 73.82646130357969),
                initialZoom: 13,
                maxZoom: 18,
                minZoom: 3,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.radcm',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ToggleAnomaliesScreen extends StatelessWidget {
  const ToggleAnomaliesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Toggle Anomalies'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text('Toggle Settings for additional anomalies.'),
            ),
          ),
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  leading: Image(
                    image: AssetImage('assets/icons/ic_speedbreaker.png'),
                    width: 32,
                    height: 32,
                  ),
                  title: Text('Speedbreakers'),
                  subtitle: Text('Show on Map, Alert while riding'),
                ),
                ListTile(
                  leading: Image(
                    image: AssetImage('assets/icons/ic_rumbler.png'),
                    width: 32,
                    height: 32,
                  ),
                  title: Text('Rumblers'),
                  subtitle: Text('Show on Map, Alert while riding'),
                ),
                ListTile(
                  leading: Image(
                    image: AssetImage('assets/icons/ic_obstacle.png'),
                    width: 32,
                    height: 32,
                  ),
                  title: Text('Obstacles'),
                  subtitle: Text('Show on Map, Alert while riding'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

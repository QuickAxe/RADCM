import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';

class Attribution extends StatelessWidget {
  const Attribution({super.key});

  @override
  Widget build(BuildContext context) {
    return RichAttributionWidget(
      popupBackgroundColor: Theme.of(context).colorScheme.surfaceDim,
      attributions: [
        TextSourceAttribution(
          'OpenStreetMap contributors',
          onTap: () =>
              launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
        ),
      ],
    );
  }
}

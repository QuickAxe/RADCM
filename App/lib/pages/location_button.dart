import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/providers/permissions.dart';

class LocationButton extends StatelessWidget {
  const LocationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final permissions = Provider.of<Permissions>(context);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: FloatingActionButton(
        heroTag: "my_location",
        backgroundColor: colorScheme.secondaryContainer,
        onPressed: () async {
          await permissions.fetchPosition();
        },
        child: const Icon(Icons.my_location_rounded),
      ),
    );
  }
}

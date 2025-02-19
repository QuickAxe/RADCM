import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/providers/user_settings.dart';

class NavigationPreferences extends StatelessWidget {
  const NavigationPreferences({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the current theme

    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Preferences')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<UserSettingsProvider>(
          builder: (context, userSettings, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Transport Mode:',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _transportOption(
                      context,
                      mode: "driving",
                      title: "Driving",
                      subtitle: "Fastest route via roads",
                      icon: Icons.directions_car,
                      selected: userSettings.profile == "driving",
                      onTap: () => userSettings.setProfile("driving"),
                    ),
                    _transportOption(
                      context,
                      mode: "walking",
                      title: "Walking",
                      subtitle: "Scenic pedestrian paths",
                      icon: Icons.directions_walk,
                      selected: userSettings.profile == "walking",
                      onTap: () => userSettings.setProfile("walking"),
                    ),
                    _transportOption(
                      context,
                      mode: "cycling",
                      title: "Cycling",
                      subtitle: "Bike-friendly routes",
                      icon: Icons.directions_bike,
                      selected: userSettings.profile == "cycling",
                      onTap: () => userSettings.setProfile("cycling"),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _transportOption(
    BuildContext context, {
    required String mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: MediaQuery.of(context).size.width / 3.5,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color:
                  selected ? theme.colorScheme.primary : theme.iconTheme.color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

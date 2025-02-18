import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/providers/user_settings.dart';

class TransportProfileSelectorRow extends StatelessWidget {
  const TransportProfileSelectorRow({super.key});

  @override
  Widget build(BuildContext context) {
    final userSettings = Provider.of<UserSettingsProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: userSettings.profiles.map((mode) {
          final isSelected = userSettings.profile == mode["value"];

          return GestureDetector(
            onTap: () {
              userSettings.setProfile(mode["value"]);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                // border: Border.all(
                //   color: isSelected
                //       ? theme.colorScheme.primary
                //       : Colors.transparent,
                //   width: 2,
                // ),
                // boxShadow: isSelected
                //     ? [
                //         BoxShadow(
                //           color: colorScheme.primary.withOpacity(0.3),
                //           blurRadius: 2,
                //           offset: const Offset(0, 3),
                //         ),
                //       ]
                //     : [],
              ),
              child: Row(
                children: [
                  Icon(
                    mode["icon"],
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    mode["name"],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

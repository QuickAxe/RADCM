import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/providers/user_settings.dart';

class TransportProfileSelectorRow extends StatelessWidget {
  const TransportProfileSelectorRow({super.key});

  @override
  Widget build(BuildContext context) {
    final userSettings = Provider.of<UserSettingsProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: userSettings.profiles.map((mode) {
        final isSelected = userSettings.profile == mode["value"];
        return GestureDetector(
          onTap: () {
            userSettings.setProfile(mode["value"]);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.deepPurple : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(mode["icon"],
                    color: isSelected ? Colors.white : Colors.black),
                const SizedBox(width: 5),
                Text(
                  mode["name"],
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

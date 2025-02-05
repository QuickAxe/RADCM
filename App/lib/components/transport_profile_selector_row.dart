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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.deepPurple : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isSelected ? Colors.deepPurpleAccent : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Icon(
                  mode["icon"],
                  color: isSelected ? Colors.white : Colors.black87,
                  size: 24,
                ),
                const SizedBox(width: 6),
                Text(
                  mode["name"],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        children: [
          const DrawerHeader(
            child: Center(
              child: Text(
                'RADCM',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ListTile(
            leading: const Icon(LucideIcons.settings2),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const SizedBox(
            height: 10,
          ),
          ListTile(
            leading: const Icon(LucideIcons.camera),
            title: const Text('Capture'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/capture');
            },
          ),
        ],
      ),
    );
  }
}

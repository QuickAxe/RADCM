import 'package:admin_app/components/restart_app.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                'RADCM Admin',
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
          ListTile(
            leading: const Icon(LucideIcons.logOut),
            title: const Text('Logout'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();  // Removes all keys and values

              RestartWidget.restartApp(context);
            },
          ),
        ],
      ),
    );
  }
}

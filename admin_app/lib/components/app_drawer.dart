import 'package:admin_app/services/providers/permissions.dart';
import 'package:admin_app/services/providers/search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/providers/route_provider.dart';
import '../services/providers/user_settings.dart';

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
            leading: const Icon(Icons.settings_rounded),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.login_rounded),
            title: const Text('Logout'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

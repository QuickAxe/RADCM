import 'package:admin_app/services/api%20services/dio_client_service.dart';
import 'package:admin_app/services/providers/permissions.dart';
import 'package:admin_app/services/providers/route_provider.dart';
import 'package:admin_app/services/providers/search.dart';
import 'package:admin_app/services/providers/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
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
              // clear storage
              await DioClient().logout();

              final prefs = await SharedPreferences.getInstance();
              await prefs.remove("isDev");
              await prefs.remove("isUser");

              if (!context.mounted) return;

              // reset providers
              Provider.of<Permissions>(context, listen: false).logout();
              Provider.of<MapRouteProvider>(context, listen: false).logout();
              Provider.of<Search>(context, listen: false).logout();
              Provider.of<UserSettingsProvider>(context, listen: false)
                  .logout();

              await Restart.restartApp();
            },
          ),
        ],
      ),
    );
  }
}

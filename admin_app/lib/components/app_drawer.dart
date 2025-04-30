import 'package:admin_app/services/api%20services/dio_client_auth_service.dart';
import 'package:admin_app/services/providers/permissions.dart';
import 'package:admin_app/services/providers/route_provider.dart';
import 'package:admin_app/services/providers/search.dart';
import 'package:admin_app/services/providers/user_settings.dart';
import 'package:admin_app/utils/context_extensions.dart';
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
      backgroundColor: context.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            DrawerHeader(
              child: Center(
                child: Text(
                  'Rosto Radar: Admin',
                  style: TextStyle(
                    fontSize: 20,
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(LucideIcons.settings2),
              title: Text(
                'Settings',
                style: context.theme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            const Spacer(),
            ListTile(
              leading: Icon(
                LucideIcons.logOut,
                color: context.colorScheme.onErrorContainer,
              ),
              title: Text(
                'Logout',
                style: context.theme.textTheme.titleMedium
                    ?.copyWith(color: context.colorScheme.onErrorContainer),
              ),
              onTap: () async {
                await DioClientAuth().logout();

                final prefs = await SharedPreferences.getInstance();
                await prefs.remove("isDev");
                await prefs.remove("isUser");

                if (!context.mounted) return;

                Provider.of<Permissions>(context, listen: false).logout();
                Provider.of<RouteProvider>(context, listen: false).logout();
                Provider.of<Search>(context, listen: false).logout();
                Provider.of<UserSettingsProvider>(context, listen: false)
                    .logout();

                await Restart.restartApp();
              },
              tileColor: context.colorScheme.errorContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: context.colorScheme.errorContainer,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

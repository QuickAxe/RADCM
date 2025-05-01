import 'package:app/util/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../services/providers/user_settings.dart';

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
                  "Rosto Radar",
                  style: TextStyle(
                    fontSize: 20,
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
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
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: Text(
                'Capture',
                style: context.theme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/capture');
              },
            ),
            const Spacer(),
            Consumer<UserSettingsProvider>(
              builder: (context, settings, _) {
                bool isDark = settings.themeMode == ThemeMode.dark;
                return ListTile(
                  tileColor: context.colorScheme.secondaryContainer,
                  leading: Icon(
                    isDark ? LucideIcons.sun : LucideIcons.moon,
                    color: context.colorScheme.onSecondaryContainer,
                  ),
                  title: Text(isDark ? 'Light Mode' : 'Dark Mode',
                      style: context.theme.textTheme.titleMedium?.copyWith(
                          color: context.colorScheme.onSecondaryContainer)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: context.colorScheme.secondaryContainer,
                    ),
                  ),
                  onTap: () {
                    settings.setThemeMode(
                      isDark ? ThemeMode.light : ThemeMode.dark,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

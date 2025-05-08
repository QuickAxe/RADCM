import 'package:app/util/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../components/app_drawer.dart';
import '../services/providers/search.dart';
import '../services/providers/user_settings.dart';
import 'custom_buttons.dart';
import 'loading_overlay.dart';
import 'map_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userSettingsProvider = context.read<UserSettingsProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      key: GlobalKey<ScaffoldState>(),
      appBar: _buildAppBar(context, context.colorScheme),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          MapView(
            userSettingsProvider: context.read<UserSettingsProvider>(),
          ),
          Positioned(
            left: 16,
            bottom: MediaQuery.of(context).size.height * 0.25,
            child: FloatingActionButton(
              heroTag: "capture_anomaly",
              onPressed: () => Navigator.pushNamed(context, '/capture'),
              backgroundColor: context.colorScheme.primaryContainer,
              tooltip: "See an anomaly? Capture it!",
              elevation: 6,
              child: const Icon(LucideIcons.camera),
            ),
          ),
          const LoadingOverlay(), // Handles UI loading state
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      // A builder was used here, because we cant refer to the Scaffold using context, from the same widget that builds the scaffold
      leading: Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.all(10.0),
          child: FloatingActionButton(
            backgroundColor: colorScheme.secondaryContainer,
            heroTag: "hamburger",
            onPressed: () => Scaffold.of(context).openDrawer(),
            child: const Icon(Icons.menu_rounded),
          ),
        ),
      ),
      actions: [
        ValueListenableBuilder<bool>(
          valueListenable: context.read<UserSettingsProvider>().dirtyAnomalies,
          builder: (context, isDirty, _) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 1000),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: isDirty
                  ? const DirtyAnomalies(key: ValueKey('dirty'))
                  : const SizedBox.shrink(key: ValueKey('clean')),
            );
          },
        ),
        Consumer<Search>(builder: (context, search, child) {
          if (search.isCurrentSelected) {
            return const ReturnButton();
          } else {
            return const LocationButton();
          }
        }),
      ],
    );
  }
}

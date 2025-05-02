import 'package:admin_app/pages/map_view.dart';
import 'package:admin_app/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:wifi_iot/wifi_iot.dart';

import '../components/app_drawer.dart';
import '../services/providers/permissions.dart';
import '../services/providers/search.dart';
import '../services/providers/user_settings.dart';
import 'custom_buttons.dart';
import 'loading_overlay.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Wi-Fi access'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'To connect to the UAV, Wi-Fi access and nearby devices permissions are required.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _onSurveyPressed() async {
    Provider.of<Permissions>(context, listen: false)
        .requestNearbyDevicesPermission();

    bool isWifiEnabled = await WiFiForIoTPlugin.isEnabled();
    if (isWifiEnabled == false) {
      await _showMyDialog();
      await WiFiForIoTPlugin.setEnabled(true, shouldOpenSettings: true);
    } else {
      Navigator.pushNamed(context, '/survey');
    }
  }

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
            bottom: 210,
            child: FloatingActionButton.extended(
              heroTag: "survey",
              onPressed: () async => await _onSurveyPressed(),
              tooltip: "Start a survey by scanning a QR code",
              elevation: 6,
              label: Text(
                'Survey',
                style: context.theme.textTheme.labelLarge,
              ),
              icon: const Icon(LucideIcons.qrCode),
            ),
          ),
          const LoadingOverlay(),
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

//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//
// Future<void> _showMyDialog() async {
//   return showDialog<void>(
//     context: context,
//     barrierDismissible: false, // user must tap button!
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('Wi-Fi access'),
//         content: const SingleChildScrollView(
//           child: ListBody(
//             children: <Widget>[
//               Text('To connect to the UAV, Wi-Fi access is required.'),
//             ],
//           ),
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('Approve'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
//
//
// Future<void> _onSurveyPressed() async {
//   bool isWifiEnabled = await WiFiForIoTPlugin.isEnabled();
//   if (isWifiEnabled == false) {
//     await _showMyDialog();
//     isWifiEnabled = await WiFiForIoTPlugin.setEnabled(true,
//         shouldOpenSettings: true);
//   }
// }
//
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     extendBodyBehindAppBar: true,
//     key: GlobalKey<ScaffoldState>(),
//     appBar: _buildAppBar(context, context.colorScheme),
//     drawer: const AppDrawer(),
//     body: Stack(
//       children: [
//         const MapView(),
//         Positioned(
//           left: 16,
//           bottom: 210,
//           child: FloatingActionButton.extended(
//             heroTag: "survey",
//             onPressed: () => {
//
//               Navigator.pushNamed(context, '/survey')
//             },
//             tooltip: "Start a survey by scanning a QR code",
//             elevation: 6,
//             label: Text(
//               'Survey',
//               style: context.theme.textTheme.labelLarge,
//             ),
//             icon: const Icon(LucideIcons.qrCode),
//           ),
//         ),
//         const LoadingOverlay(),
//       ],
//     ),
//   );
// }
//
// AppBar _buildAppBar(BuildContext context, ColorScheme colorScheme) {
//   return AppBar(
//     backgroundColor: Colors.transparent,
//     // A builder was used here, because we cant refer to the Scaffold using context, from the same widget that builds the scaffold
//     leading: Builder(
//       builder: (context) => Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: FloatingActionButton(
//           backgroundColor: colorScheme.secondaryContainer,
//           heroTag: "hamburger",
//           onPressed: () => Scaffold.of(context).openDrawer(),
//           child: const Icon(Icons.menu_rounded),
//         ),
//       ),
//     ),
//     actions: [
//       ValueListenableBuilder<bool>(
//         valueListenable: context.read<UserSettingsProvider>().dirtyAnomalies,
//         builder: (context, isDirty, _) {
//           return AnimatedSwitcher(
//             duration: const Duration(milliseconds: 1000),
//             transitionBuilder: (child, animation) {
//               return FadeTransition(opacity: animation, child: child);
//             },
//             child: isDirty
//                 ? const DirtyAnomalies(key: ValueKey('dirty'))
//                 : const SizedBox.shrink(key: ValueKey('clean')),
//           );
//         },
//       ),
//       Consumer<Search>(builder: (context, search, child) {
//         if (search.isCurrentSelected) {
//           return const ReturnButton();
//         } else {
//           return const LocationButton();
//         }
//       }),
//     ],
//   );
// }
// }

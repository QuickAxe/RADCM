import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../components/UI/blur_with_loading.dart';
import '../components/bottom_panel.dart';
import '../components/bottom_panel_nav.dart';
import '../services/providers/permissions.dart';
import '../services/providers/search.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Permissions>(
      builder: (context, permissions, child) {
        return Consumer<Search>(
          builder: (context, search, child) {
            if (permissions.loadingLocation) {
              return const BlurWithLoading();
            } else if (search.isCurrentSelected) {
              return BottomPanelNav(mapController: MapController());
            } else {
              return BottomPanel(mapController: MapController());
            }
          },
        );
      },
    );
  }
}

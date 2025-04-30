import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../components/UI/blur_with_loading.dart';
import '../components/bottom_panel.dart';
import '../components/bottom_panel_nav.dart';
import '../services/providers/map_controller_provider.dart';
import '../services/providers/permissions.dart';
import '../services/providers/search.dart';

class LoadingOverlay extends StatelessWidget {
  // final MapController mapController;
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final permissions = Provider.of<Permissions>(context);
    final search = Provider.of<Search>(context);
    final mapController = context.read<MapControllerProvider>().mapController;

    return Stack(
      children: [
        if (search.isCurrentSelected)
          BottomPanelNav(mapController: mapController)
        else
          BottomPanel(mapController: mapController),
        if (permissions.loadingLocation)
          const Positioned.fill(child: BlurWithLoading()),
      ],
    );
  }
}

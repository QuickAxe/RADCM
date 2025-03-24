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
    final permissions = Provider.of<Permissions>(context);
    final search = Provider.of<Search>(context);

    return Stack(
      children: [
        if (search.isCurrentSelected)
          BottomPanelNav(mapController: MapController())
        else
          BottomPanel(mapController: MapController()),
        if (permissions.loadingLocation)
          const Positioned.fill(child: BlurWithLoading()),
      ],
    );
  }
}

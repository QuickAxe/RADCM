import 'package:admin_app/pages/map_route_screen.dart';
import 'package:admin_app/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../services/providers/search.dart';
import '../utils/string_utils.dart';

class BottomPanelNav extends StatefulWidget {
  final MapController mapController;

  const BottomPanelNav({
    super.key,
    required this.mapController,
  });

  @override
  State<BottomPanelNav> createState() => _BottomPanelState();
}

class _BottomPanelState extends State<BottomPanelNav> {
  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<Search>(context, listen: true);

    return SlidingUpPanel(
      isDraggable: false,
      color: context.colorScheme.surfaceContainer, // Use themed surface color
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(25.0),
        topRight: Radius.circular(25.0),
      ),
      // TODO: Mediauery dis
      minHeight: 200,
      maxHeight: 700,
      // NOTE: Change the maxHeight if content overflows (Alternatively, adjust the text style)
      panel: Column(
        children: [
          const SizedBox(
            height: 25,
          ),

          /// Name and address of the currently selected place
          if (searchProvider.isCurrentSelected)
            Column(
              children: [
                ListTile(
                  leading: Icon(Icons.location_on_rounded,
                      color: context.colorScheme.primary),
                  title: Text(
                    searchProvider.currentSelected['name'] ??
                        'Unknown Location',
                    style: context.theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (searchProvider.currentSelected['type'] != null)
                        Text(
                          capitalize(searchProvider.currentSelected['type']
                              .toString()),
                          style: TextStyle(
                              color: context.colorScheme.onSurfaceVariant),
                        ),
                      if (searchProvider.currentSelected['address'] != null)
                        Text(
                          [
                            searchProvider.currentSelected['address']
                                    ?['road'] ??
                                '',
                            searchProvider.currentSelected['address']
                                    ?['suburb'] ??
                                '',
                            searchProvider.currentSelected['address']
                                    ?['postcode'] ??
                                ''
                          ].where((element) => element.isNotEmpty).join(', '),
                          style: TextStyle(
                              fontSize: 12,
                              color: context.colorScheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ],
            ),

          /// Transport options
          // const TransportProfileSelectorRow(),

          /// CTA -> Go to
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colorScheme.primary,
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: () => Navigator.push(
                context,
                // COMPARE
                MaterialPageRoute(
                  builder: (context) => MapRouteScreen(
                    endLat: double.parse(searchProvider.currentSelected['lat']),
                    endLng: double.parse(searchProvider.currentSelected['lon']),
                  ),
                ),
              ),
              child: Text(
                "Get Routes",
                style: context.theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onPrimary),
              ),
            ),
          )
        ],
      ),
    );
  }
}

import 'package:app/components/transport_profile_selector_row.dart';
import 'package:app/util/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../services/providers/search.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SlidingUpPanel(
      isDraggable: false,
      color: colorScheme.surfaceContainer, // Use themed surface color
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(25.0),
        topRight: Radius.circular(25.0),
      ),
      minHeight: 266, // this number is weirdly exact for a reason, dont change
      maxHeight: 420,
      panel: Column(
        children: [
          const SizedBox(
            height: 25,
          ),
          if (searchProvider.isCurrentSelected)
            // Currently selected place
            Column(
              children: [
                ListTile(
                  leading: Icon(Icons.location_on_rounded,
                      color: colorScheme.primary),
                  title: Text(
                    searchProvider.currentSelected['name'] ??
                        'Unknown Location',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (searchProvider.currentSelected['type'] != null)
                        Text(
                          capitalize(searchProvider.currentSelected['type']
                              .toString()),
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
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
                              color: colorScheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          // Transport options
          const TransportProfileSelectorRow(),
          // CTA -> Go to
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: () => Navigator.pushNamed(context, '/map_route'),
              child: Text(
                "Get Routes",
                style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold, color: colorScheme.onPrimary),
              ),
            ),
          )
        ],
      ),
    );
  }
}

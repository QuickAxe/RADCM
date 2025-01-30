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
    // final userSettings = Provider.of<UserSettingsProvider>(context);

    return SlidingUpPanel(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(25.0),
        topRight: Radius.circular(25.0),
      ),
      minHeight: 200,
      maxHeight: 700,
      panel: Column(
        children: [
          // Drag Indicator
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (Provider.of<Search>(context, listen: true).isCurrentSelected)
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
              child: ListTile(
                leading: const Icon(Icons.location_on_rounded),
                title: Text(Provider.of<Search>(context, listen: true).currentSelected['name']),
                subtitle: Text(Provider.of<Search>(context, listen: true)
                    .currentSelected['addresstype']),
              ),
            ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
          //   child: ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Theme.of(context).colorScheme.primary,
          //       foregroundColor: Theme.of(context).colorScheme.onPrimary,
          //       minimumSize: const Size.fromHeight(40),
          //     ),
          //     onPressed: () {},
          //     child: const Text("Get Routes"),
          //   ),
          // )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../services/providers/filters.dart';
import 'search_place.dart';

class BottomPanel extends StatefulWidget {
  final MapController mapController;

  const BottomPanel({
    super.key,
    required this.mapController,
  });

  @override
  State<BottomPanel> createState() => _BottomPanelState();
}

class _BottomPanelState extends State<BottomPanel> {
  @override
  Widget build(BuildContext context) {
    final filterProvider = Provider.of<Filters>(context);

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
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 10.0),
            child: SearchPlace(
              mapController: widget.mapController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: SizedBox(
              height: 50,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filterProvider.filters.map((option) {
                    bool isSelected = filterProvider.selectedFilter == option;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: ChoiceChip(
                        label: Text(option),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          filterProvider.setFilter(selected ? option : null);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

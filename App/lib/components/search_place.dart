import 'dart:developer' as dev;

import 'package:app/services/providers/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class SearchPlace extends StatefulWidget {
  final MapController mapController;

  const SearchPlace({super.key, required this.mapController});

  @override
  State<SearchPlace> createState() => _SearchPlaceState();
}

class _SearchPlaceState extends State<SearchPlace> {
  late SearchController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = SearchController();
  }

  // returns a single suggestion ListTile
  ListTile buildPlaceItem(dynamic place, SearchController controller) {
    return ListTile(
      title: Text(
        place['display_name'] ?? 'Unknown Place',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        place['address']?['country'] ?? 'Address not available',
      ),
      leading: const Icon(Icons.location_on, color: Colors.blue),
      onTap: () {
        userTapsSearchResult(place, controller);
      },
    );
  }

  void userTapsSearchResult(dynamic place, SearchController controller) {
    dev.log(place.toString());

    Provider.of<Search>(context, listen: false).performSelection(place);

    // bounding box
    LatLngBounds bounds = LatLngBounds(
      LatLng(double.parse(place['boundingbox'][0]),
          double.parse(place['boundingbox'][2])),
      LatLng(double.parse(place['boundingbox'][1]),
          double.parse(place['boundingbox'][3])),
    );

    widget.mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50.0)));
    widget.mapController.rotate(0);
    controller.closeView(place['display_name']);
  }

  @override
  Widget build(BuildContext context) {
    // hello darkness
    return Consumer<Search>(builder: (context, search, child) {
      return SearchAnchor(
        builder: (BuildContext context, SearchController controller) {
          _searchController = controller;
          return search.loadingResults
              ? Center(
                  child: LoadingAnimationWidget.waveDots(
                    color: Theme.of(context).hintColor,
                    size: 65,
                  ),
                )
              : SearchBar(
                  controller: controller,
                  onSubmitted: (_) async {
                    await search.getSuggestions(controller.text.toString());
                    controller.openView();
                  },
                  trailing: [
                    IconButton(
                        onPressed: () async {
                          await search
                              .getSuggestions(controller.text.toString())
                              .then((_) {
                            controller.openView();
                          });
                          // controller.openView();
                        },
                        icon: const Icon(Icons.search)),
                  ],
                  hintText: "Search Map",
                  elevation: WidgetStateProperty.all(0), // Remove shadow
                );
        },
        suggestionsBuilder:
            (BuildContext context, SearchController controller) {
          List<ListTile> suggestions = search.searchSuggestions
              .map((place) => buildPlaceItem(place, controller))
              .toList();

          dev.log('Total search results: ${suggestions.length}');

          return suggestions;
        },
        viewOnSubmitted: (_) async {
          await search.getSuggestions(_searchController.text.toString());
          _searchController.closeView(_searchController.text.toString());
          _searchController.openView();
        },
      );
    });
  }
}

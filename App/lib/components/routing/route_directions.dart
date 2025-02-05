import 'package:flutter/material.dart';

import '../../data/models/osrm_models.dart';
import '../../util/route_utils.dart';

/// A widget that displays the turn by turn directions for a chosen route
class RouteDirections extends StatelessWidget {
  final RouteModel route;
  const RouteDirections({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    if (route.legs.isEmpty) return Container();
    final leg = route.legs.first;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: leg.steps.length,
      padding: EdgeInsets.zero,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final step = leg.steps[index];
        String instruction = step.maneuver.type;
        if (step.maneuver.modifier != null) {
          instruction += " (${step.maneuver.modifier})";
        }
        instruction += " on ${step.name}";
        return ListTile(
          leading: Text("${index + 1}"),
          title: Text(
            instruction,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "Distance: ${formatDistance(step.distance)} | Duration: ${formatDuration(step.duration)}",
          ),
        );
      },
    );
  }
}

import 'package:app/util/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:popover/popover.dart';

class Attribution extends StatelessWidget {
  const Attribution({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPopover(
        backgroundColor: context.colorScheme.surfaceContainer,
        barrierColor: Colors.transparent,
        direction: PopoverDirection.top,
        context: context,
        bodyBuilder: (context) => Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            '© OpenStreetMap\nBuilt using flutter_map',
            style: TextStyle(color: context.colorScheme.onSecondaryContainer),
          ),
        ),
      ),
      child: Icon(
        LucideIcons.map,
        color: context.colorScheme.secondary,
      ),
    );
  }
}

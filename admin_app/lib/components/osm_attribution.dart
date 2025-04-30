import 'package:admin_app/utils/context_extensions.dart';
import 'package:flutter/material.dart';
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
      child: Image.network(
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Openstreetmap_logo.svg/256px-Openstreetmap_logo.svg.png',
        width: 35,
        height: 35,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(
            width: 35,
            height: 35,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class RestartWidget extends StatefulWidget {
  final Widget child;
  RestartWidget({required this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  // Unique key forces a rebuild
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      // Change key to trigger a full rebuild
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Use showSnackBar instead
void showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    // gravity: ToastGravity.CENTER,
  );
}

// To be preferred over showToast
void showSnackBar(
  String label,
  BuildContext context, {
  String? actionLabel,
  VoidCallback? onActionPressed,
  int? seconds,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(label),
      duration: Duration(seconds: seconds ?? 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      action: (actionLabel != null && onActionPressed != null)
          ? SnackBarAction(
              label: actionLabel,
              onPressed: onActionPressed,
            )
          : null,
    ),
  );
}

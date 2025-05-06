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
void showSnackBar(String label, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(label),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
}

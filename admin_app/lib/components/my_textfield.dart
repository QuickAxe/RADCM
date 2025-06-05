import 'package:admin_app/utils/context_extensions.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Color borderColor;
  final Color focusedBorderColor;
  final TextInputType? keyboardType;
  final String? errorText;
  final IconData? prefixIcon;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.borderColor,
    required this.focusedBorderColor,
    required this.keyboardType,
    required this.errorText,
    required this.prefixIcon,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,
        // this modifies the keyboard action button
        textInputAction: widget.textInputAction,
        // callback for the keyboard action button
        onSubmitted: (_) => widget.onSubmitted?.call(),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: widget.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: widget.focusedBorderColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide:
                BorderSide(color: context.colorScheme.error, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide:
                BorderSide(color: context.colorScheme.error, width: 2.0),
          ),
          filled: true,
          labelText: widget.hintText,
          errorText: widget.errorText,
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: widget.errorText != null
                      ? context.colorScheme.error
                      : context.colorScheme.onSurfaceVariant,
                )
              : null,
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: _toggleObscureText,
                )
              : null,
        ),
      ),
    );
  }
}

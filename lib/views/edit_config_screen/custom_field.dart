import 'package:flutter/material.dart';

class CustomField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? textInputType;
  final String? Function(String?)? validator;

  const CustomField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.textInputType,
    this.validator,
  });

  @override
  State<CustomField> createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
      ),
      validator: widget.validator,
    );
  }
}

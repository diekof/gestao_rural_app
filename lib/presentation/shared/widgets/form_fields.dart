import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({super.key, required this.controller, required this.label, this.validator, this.keyboardType});
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => TextFormField(controller: controller, decoration: InputDecoration(labelText: label), validator: validator, keyboardType: keyboardType);
}

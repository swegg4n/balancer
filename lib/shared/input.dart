import 'package:flutter/material.dart';

class TextFieldPrimary extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType inputType;
  final TextInputAction textInputAction;
  final bool obscure;
  final bool autofocus;
  final int? maxLength;
  final bool enabled;

  const TextFieldPrimary({
    Key? key,
    required this.label,
    required this.icon,
    required this.controller,
    this.inputType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscure = false,
    this.autofocus = true,
    this.maxLength,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: TextField(
        enabled: enabled,
        maxLength: maxLength,
        autofocus: autofocus,
        textInputAction: textInputAction,
        keyboardType: inputType,
        textAlignVertical: TextAlignVertical.bottom,
        style: const TextStyle(fontSize: 17),
        obscureText: obscure,
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
          filled: false,
          hintText: label,
          prefixIcon: Icon(icon, size: 18),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
        ),
      ),
    );
  }
}

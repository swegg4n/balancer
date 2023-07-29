import 'package:flutter/material.dart';

class TextFieldPrimary extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final IconData? icon;
  final TextInputType inputType;
  final TextInputAction textInputAction;
  final bool obscure;
  final bool autofocus;
  final int? maxLength;
  final bool enabled;
  final bool outline;
  final double fontSize;
  final Function? onChanged;
  final TextCapitalization textCapitalization;

  const TextFieldPrimary({
    Key? key,
    required this.controller,
    this.label,
    this.icon,
    this.inputType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscure = false,
    this.autofocus = true,
    this.maxLength,
    this.enabled = true,
    this.outline = true,
    this.fontSize = 17,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: outline ? 60 : 50,
      child: TextField(
        enabled: enabled,
        maxLength: maxLength,
        autofocus: autofocus,
        textInputAction: textInputAction,
        keyboardType: inputType,
        textCapitalization: textCapitalization,
        textAlignVertical: TextAlignVertical.bottom,
        style: TextStyle(fontSize: fontSize),
        obscureText: obscure,
        controller: controller,
        decoration: InputDecoration(
          border: outline
              ? OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!))
              : UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
          filled: false,
          hintText: label,
          prefixIcon: icon != null ? Icon(icon, size: 18) : null,
          enabledBorder: outline
              ? OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!))
              : UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
          focusedBorder: outline
              ? OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor))
              : UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
        ),
        onChanged: (value) => (onChanged == null) ? null : onChanged!(),
      ),
    );
  }
}

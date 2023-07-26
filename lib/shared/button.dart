import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Button extends StatelessWidget {
  final String text;
  final Function? onPressed;
  final double fontSize;
  final double paddingHorizontal;
  final double paddingVertical;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  final double? borderSize;
  final bool disabled;

  const Button(
      {Key? key,
      required this.text,
      required this.onPressed,
      this.fontSize = 20,
      this.paddingHorizontal = 12,
      this.paddingVertical = 15,
      this.color,
      this.textColor,
      this.borderColor,
      this.borderSize,
      this.disabled = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all((onPressed != null && disabled == false)
              ? (color ?? Colors.grey[700])
              : (color != null ? color!.withOpacity(0.5) : Colors.grey[700]!.withOpacity(0.5))),
          side: MaterialStateProperty.all(
            BorderSide(
              style: borderColor != null ? BorderStyle.solid : BorderStyle.none,
              width: borderSize ?? 3.0,
              color: borderColor ?? (color ?? Colors.grey[700]!),
            ),
          )),
      onPressed: disabled
          ? null
          : onPressed != null
              ? () => onPressed!()
              : null,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: paddingVertical, horizontal: paddingHorizontal),
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize, color: textColor ?? Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

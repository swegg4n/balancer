import 'package:flutter/material.dart';

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
          style: TextStyle(fontSize: fontSize, color: disabled ? const Color(0xffcccccc) : textColor ?? Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class ButtonIcon extends StatelessWidget {
  final String text;
  final String subtext;
  final Function? onPressed;
  final double fontSize;
  final double paddingHorizontal;
  final double paddingVertical;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  final double? borderSize;
  final bool disabled;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;

  const ButtonIcon(
      {Key? key,
      required this.text,
      this.subtext = '',
      required this.onPressed,
      this.fontSize = 20,
      this.paddingHorizontal = 12,
      this.paddingVertical = 15,
      this.color,
      this.textColor,
      this.borderColor,
      this.borderSize,
      this.disabled = false,
      required this.icon,
      this.iconSize = 20,
      this.iconColor = Colors.white})
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
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Icon(icon, size: iconSize, color: iconColor),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                text,
                style: TextStyle(fontSize: fontSize, color: disabled ? const Color(0xffcccccc) : textColor ?? Colors.white),
                textAlign: TextAlign.right,
              ),
              Visibility(
                visible: subtext != '',
                child: Text(
                  subtext,
                  style: TextStyle(fontSize: fontSize - 5, color: const Color(0xffcccccc)),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final IconData icon;
  final Function? onPressed;
  final double iconSize;
  final Color? iconColor;
  final Color? backgroundColor;

  const CategoryButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.iconSize = 36,
    this.iconColor = Colors.white,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey[800],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => onPressed == null ? null : onPressed!(),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonText extends StatelessWidget {
  final String text;
  final Function? onPressed;
  final double fontSize;
  final bool disabled;

  const ButtonText({Key? key, required this.text, required this.onPressed, this.fontSize = 20, this.disabled = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        textStyle: TextStyle(fontSize: fontSize),
      ),
      onPressed: (disabled || onPressed == null) ? null : () async => onPressed!(),
      child: Text(text),
    );
  }
}

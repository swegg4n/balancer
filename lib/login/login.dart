import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:Balancer/login/sign_in.dart';
import 'package:Balancer/services/auth.dart';
import 'package:Balancer/shared/button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class LoginButton extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final String text;
  final Color textColor;
  final Function? loginMethod;

  const LoginButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.textColor,
    required this.backgroundColor,
    required this.loginMethod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Container(
        margin: const EdgeInsets.only(right: 10),
        child: Icon(
          icon,
          color: textColor,
          size: 25,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(13),
        backgroundColor: backgroundColor,
      ),
      onPressed: loginMethod != null ? () async => await loginMethod!() : null,
      label: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
        ),
      ),
    );
  }
}

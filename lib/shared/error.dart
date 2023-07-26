import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String message;

  const ErrorMessage({super.key, this.message = 'it broke'});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 50),
      child: Text(
        message,
        textDirection: TextDirection.ltr,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}

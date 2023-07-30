import 'package:flutter/material.dart';

class ForegroundScreen extends StatelessWidget {
  const ForegroundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Image(
          width: 150,
          color: Color(0xffcccccc),
          image: AssetImage('assets/logo_t.png'),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Loader(),
      ),
    );
  }
}

class Loader extends StatelessWidget {
  final double size;
  final bool running;

  const Loader({Key? key, this.size = 65, this.running = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(strokeWidth: 3.0, value: running ? null : 0),
    );
  }
}

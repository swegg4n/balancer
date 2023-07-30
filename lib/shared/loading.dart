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
  final Color? color;

  const Loader({Key? key, this.size = 65, this.running = true, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(strokeWidth: 3.0, value: running ? null : 0, color: color ?? Theme.of(context).primaryColor),
    );
  }
}

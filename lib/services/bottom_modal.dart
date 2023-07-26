import 'package:flutter/material.dart';

class BottomModal {
  static void _showModal(dynamic context, String header, String body, Color? color, Color? barrierColor) {
    showModalBottomSheet(
        context: context,
        backgroundColor: color,
        barrierColor: barrierColor,
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () => Navigator.pop(context),
            onLongPress: () => Navigator.pop(context),
            onDoubleTap: () => Navigator.pop(context),
            child: Container(
              height: 100,
              margin: const EdgeInsets.only(left: 30, right: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    header,
                    style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    body,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        });
  }

  static void showErrorModal(dynamic context, String header, String body) {
    _showModal(context, header, body, Colors.red[400], null);
  }

  static void showSuccessModal(dynamic context, String header, String body) {
    _showModal(context, header, body, Colors.green, Colors.transparent);
  }
}

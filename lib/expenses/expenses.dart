import 'package:Balancer/main.dart';
import 'package:Balancer/shared/button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class NewExpenseButton extends StatelessWidget {
  final String heroTag;
  const NewExpenseButton({super.key, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 5),
      child: FloatingActionButton.extended(
        heroTag: heroTag,
        label: Text('new expense',
            style: TextStyle(
              fontSize: 20,
              fontFamily: GoogleFonts.nunito().fontFamily,
              fontWeight: FontWeight.w600,
            )),
        icon: const Icon(FontAwesomeIcons.plus, size: 20),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const NewExpenseScreen()));
        },
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}

class NewExpenseScreen extends StatelessWidget {
  const NewExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(fit: BoxFit.fitWidth, child: Text('add a new expense', style: TextStyle(fontSize: 20))),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.xmark),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.grey[850],
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 50, left: 25, right: 25, bottom: 60),
        child: Placeholder(),
      ),
    );
  }
}

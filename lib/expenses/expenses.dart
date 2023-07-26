import 'package:Balancer/shared/button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class NewExpenseButton extends StatelessWidget {
  const NewExpenseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 5),
      child: FloatingActionButton.extended(
        label: Text('new expense',
            style: TextStyle(
              fontSize: 20,
              fontFamily: GoogleFonts.nunito().fontFamily,
              fontWeight: FontWeight.w600,
            )),
        icon: const Icon(FontAwesomeIcons.plus, size: 20),
        onPressed: () {},
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

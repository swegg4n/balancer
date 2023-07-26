import 'package:Balancer/expenses/expenses.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: NewExpenseButton(),
      body: Container(
        margin: EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 60),
        child: Placeholder(),
      ),
    );
  }
}

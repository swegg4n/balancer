import 'package:flutter/material.dart';

import '../expenses/expenses.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: NewExpenseButton(heroTag: "floating_analytics"),
      body: Container(
        margin: EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 60),
        child: Placeholder(),
      ),
    );
  }
}

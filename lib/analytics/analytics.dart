import 'package:Balancer/expenses/categories.dart';
import 'package:Balancer/history/history.dart';
import 'package:Balancer/services/auth.dart';
import 'package:Balancer/services/firestore.dart';
import 'package:Balancer/services/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../expenses/expenses.dart';
import 'package:provider/provider.dart';

final monthNames = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

// ignore: must_be_immutable
class AnalyticsScreen extends StatefulWidget {
  final double iconSize = 65;
  DateTime selectedDate = DateTime.now();
  DateTime fromDateTime = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime toDateTime = DateTime.fromMillisecondsSinceEpoch(0);

  AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late Future<List<Expense>> _monthlyExpensesFuture;
  int totalSumUser1 = 0;
  int totalLentUser1 = 0;
  int totalSumUser2 = 0;
  int totalLentUser2 = 0;
  double payFractionUser1 = 0;
  double payFractionUser2 = 0;
  List<double> categoryExpensesUser1 = List.filled(6, 0);
  List<double> categoryExpensesUser2 = List.filled(6, 0);

  @override
  void initState() {
    super.initState();
    updateMonthlyReports();
  }

  void subtractMonth() {
    int year = widget.selectedDate.year;
    int month = widget.selectedDate.month;
    widget.selectedDate = DateTime(year, month - 1);
  }

  void addMonth() {
    int year = widget.selectedDate.year;
    int month = widget.selectedDate.month;
    widget.selectedDate = DateTime(year, month + 1);
  }

  Future<void> updateMonthlyReports() async {
    int year = widget.selectedDate.year;
    int month = widget.selectedDate.month;
    widget.fromDateTime = DateTime(year, month);
    widget.toDateTime = DateTime(year, month + 1).subtract(const Duration(milliseconds: 1));

    _monthlyExpensesFuture =
        FirestoreService().getDocumentsBetween(widget.fromDateTime.millisecondsSinceEpoch, widget.toDateTime.millisecondsSinceEpoch);

    List<Expense> monthlyExpenses = await _monthlyExpensesFuture;
    User user = AuthService().user!;

    double sumUser1 = 0;
    double lentUser1 = 0;
    double sumUser2 = 0;
    double lentUser2 = 0;
    List<double> categorySumsUser1 = List.filled(6, 0);
    List<double> categorySumsUser2 = List.filled(6, 0);

    for (var expense in monthlyExpenses) {
      double amount = expense.amount;
      double lent = amount * (1 - expense.split);
      int categoryIndex = expense.categoryIndex;

      if (expense.userId == user.uid) {
        // my expense
        sumUser1 += amount;
        lentUser1 += lent;
        categorySumsUser1[categoryIndex] += amount;
      } else {
        // housemate's expense
        sumUser2 += amount;
        lentUser2 += lent;
        categorySumsUser2[categoryIndex] += amount;
      }
    }

    setState(() {
      totalSumUser1 = sumUser1.toInt();
      totalLentUser1 = lentUser1.toInt();
      totalSumUser2 = sumUser2.toInt();
      totalLentUser2 = lentUser2.toInt();

      if (totalLentUser1 == 0 && totalLentUser2 == 0) {
        payFractionUser1 = 0;
        payFractionUser2 = 0;
      } else if (totalLentUser2 == 0) {
        payFractionUser1 = 1;
        payFractionUser2 = 0;
      } else {
        payFractionUser1 = totalLentUser1 / (totalLentUser1 + totalLentUser2);
        payFractionUser2 = 1 - payFractionUser1;
      }

      categoryExpensesUser1 = categorySumsUser1;
      categoryExpensesUser2 = categorySumsUser2;
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<MyUser>(context);

    return FutureBuilder<List<Expense>>(
      future: _monthlyExpensesFuture,
      initialData: const [],
      builder: (context, snapshot) {
        return Scaffold(
          floatingActionButton: const NewExpenseButton(heroTag: "floating_analytics"),
          body: RefreshIndicator(
            onRefresh: () async {
              await updateMonthlyReports();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                margin: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 60),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () {
                              subtractMonth();
                              updateMonthlyReports();
                            },
                            icon: const Icon(FontAwesomeIcons.angleLeft, size: 20)),
                        Text('${monthNames[widget.selectedDate.month]} ${widget.selectedDate.year}', style: const TextStyle(fontSize: 24)),
                        IconButton(
                            onPressed: !DateTime.now().isLaterMonth(widget.selectedDate)
                                ? null
                                : () {
                                    addMonth();
                                    updateMonthlyReports();
                                  },
                            icon: const Icon(FontAwesomeIcons.angleRight, size: 20)),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 25)),
                    Row(
                      children: [
                        Container(
                          width: widget.iconSize,
                          height: widget.iconSize,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            shape: BoxShape.circle,
                            image: user.pfpUrl.isEmpty
                                ? null
                                : DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(user.pfpUrl),
                                  ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(right: 15)),
                        Expanded(
                            child: LinearPercentIndicator(
                          percent: payFractionUser1,
                          lineHeight: 40,
                          barRadius: const Radius.circular(50),
                          animation: true,
                          center: Text('${(payFractionUser1 * 100).ceil()}%', style: const TextStyle(fontSize: 18)),
                          backgroundColor: Colors.grey[800],
                          progressColor: Colors.grey[600],
                        )),
                        SizedBox(
                          width: 120,
                          child: Column(
                            children: [
                              FittedBox(child: Text('$totalLentUser1 kr', style: const TextStyle(fontSize: 24))),
                              FittedBox(child: Text('($totalSumUser1 kr)', style: TextStyle(fontSize: 16, color: Colors.grey[400]))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 10)),
                    Row(
                      children: [
                        FutureBuilder<MyUser>(
                          future: FirestoreService().getHouseholdUser(),
                          initialData: null,
                          builder: (context, snapshot) {
                            return Container(
                              width: widget.iconSize,
                              height: widget.iconSize,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                shape: BoxShape.circle,
                                image: !snapshot.hasData
                                    ? null
                                    : DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(snapshot.data!.pfpUrl),
                                      ),
                              ),
                            );
                          },
                        ),
                        const Padding(padding: EdgeInsets.only(right: 10)),
                        Expanded(
                            child: LinearPercentIndicator(
                          percent: payFractionUser2,
                          lineHeight: 40,
                          barRadius: const Radius.circular(50),
                          animation: true,
                          center: Text('${(payFractionUser2 * 100).floor()}%', style: const TextStyle(fontSize: 18)),
                          backgroundColor: Colors.grey[800],
                          progressColor: Colors.grey[600],
                        )),
                        SizedBox(
                          width: 120,
                          child: Column(
                            children: [
                              FittedBox(child: Text('$totalLentUser2 kr', style: const TextStyle(fontSize: 24))),
                              FittedBox(child: Text('($totalSumUser2 kr)', style: TextStyle(fontSize: 16, color: Colors.grey[400]))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 100)),
                    StackedCategoryBars(
                      categoryExpensesUser1: categoryExpensesUser1,
                      categoryExpensesUser2: categoryExpensesUser2,
                      totalSumUser1: totalSumUser1,
                      totalSumUser2: totalSumUser2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class StackedCategoryBars extends StatelessWidget {
  final List<double> categoryExpensesUser1;
  final List<double> categoryExpensesUser2;
  final int totalSumUser1;
  final int totalSumUser2;

  const StackedCategoryBars(
      {super.key,
      required this.categoryExpensesUser1,
      required this.categoryExpensesUser2,
      required this.totalSumUser1,
      required this.totalSumUser2});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
          6,
          (index) => CategoryBar(
                expenseFractionUser1: totalSumUser1 == 0 ? 0 : categoryExpensesUser1[index] / (totalSumUser1 + totalSumUser2),
                expenseFractionUser2: totalSumUser2 == 0 ? 0 : categoryExpensesUser2[index] / (totalSumUser1 + totalSumUser2),
                index: index,
                categorySum: (categoryExpensesUser1[index] + categoryExpensesUser2[index]).toInt(),
              )),
    );
  }
}

class CategoryBar extends StatelessWidget {
  final double expenseFractionUser1;
  final double expenseFractionUser2;
  final int index;
  final int categorySum;

  final double maxHeight = 200;

  const CategoryBar(
      {super.key, required this.expenseFractionUser1, required this.expenseFractionUser2, required this.index, required this.categorySum});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: maxHeight,
              width: 20,
              decoration: BoxDecoration(color: Colors.grey[800], borderRadius: const BorderRadius.all(Radius.circular(50))),
            ),
            Visibility(
              visible: expenseFractionUser1 > 0.05,
              child: Container(
                height: expenseFractionUser1 * maxHeight,
                width: 20,
                decoration: BoxDecoration(color: categories[index].color, borderRadius: const BorderRadius.all(Radius.circular(50))),
              ),
            ),
            Visibility(
              visible: expenseFractionUser2 > 0.05,
              child: Container(
                height: (expenseFractionUser1 + expenseFractionUser2) * maxHeight,
                width: 20,
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: categories[index].color, width: 0.75),
                    borderRadius: const BorderRadius.all(Radius.circular(50))),
              ),
            ),
          ],
        ),
        const Padding(padding: EdgeInsets.only(bottom: 15)),
        Icon(
          categories[index].icon,
          color: categories[index].color,
          size: 26,
        ),
        const Padding(padding: EdgeInsets.only(bottom: 10)),
        SizedBox(
          width: 50,
          child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$categorySum kr',
                style: TextStyle(fontSize: 18, color: categories[index].color),
              )),
        ),
      ],
    );
  }
}

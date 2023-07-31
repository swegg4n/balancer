import 'package:Balancer/expenses/categories.dart';
import 'package:Balancer/expenses/expenses.dart';
import 'package:Balancer/history/history_state.dart';
import 'package:Balancer/services/app_preferences.dart';
import 'package:Balancer/services/firestore.dart';
import 'package:Balancer/services/models.dart';
import 'package:Balancer/shared/button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ChipButton extends StatelessWidget {
  final Category category;
  final HistoryState historyState;

  const ChipButton({super.key, required this.category, required this.historyState});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(historyState.selectedCategories[category.index] ? category.color : Colors.grey[850]),
        side: MaterialStateProperty.all(
          BorderSide(style: BorderStyle.solid, width: 1.0, color: category.color),
        ),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
      ),
      onPressed: () {
        historyState.toggleSelectedCategory(category.index);
      },
      onLongPress: () {
        if (historyState.selectedCategories.where((x) => x == true).length > 1 || historyState.selectedCategories[category.index] == false) {
          List<bool> newSelection = [false, false, false, false, false, false];
          newSelection[category.index] = true;
          historyState.selectedCategories = newSelection;
        } else {
          List<bool> newSelection = [true, true, true, true, true, true];
          historyState.selectedCategories = newSelection;
        }
      },
      child: Text(
        category.name,
        style: TextStyle(color: historyState.selectedCategories[category.index] ? Colors.grey[850] : category.color),
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  var scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getDocuments();
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          getDocumentsNext();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var historyState = Provider.of<HistoryState>(context);

    return Scaffold(
      floatingActionButton: const NewExpenseButton(heroTag: "floating_history"),
      body: Container(
        margin: const EdgeInsets.only(top: 55, left: 15, right: 15, bottom: 0),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 20),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 10,
                    children: [
                      ChipButton(category: categories[0], historyState: historyState),
                      ChipButton(category: categories[1], historyState: historyState),
                      ChipButton(category: categories[2], historyState: historyState),
                      ChipButton(category: categories[3], historyState: historyState),
                      ChipButton(category: categories[4], historyState: historyState),
                      ChipButton(category: categories[5], historyState: historyState),
                    ],
                  ),
                ),
                Column(
                  children: [
                    SizedBox(
                      width: 65,
                      child: CategoryButton(
                        backgroundColor: Colors.grey[850],
                        icon: FontAwesomeIcons.calendar,
                        iconSize: 30,
                        iconColor: Colors.white,
                        onPressed: () {
                          showDialog(context: context, builder: (context) => DateTimePickerHistory(historyState: historyState));
                        },
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 5)),
                    Text(historyState.fromDate.toString().split(' ')[0], style: const TextStyle(fontSize: 16)),
                    Button(
                      text: 'today',
                      onPressed: () {
                        historyState.fromDate = DateTime.now();
                      },
                      paddingVertical: 3,
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 9,
            child: expenses.isNotEmpty
                ? RefreshIndicator(
                    onRefresh: getDocuments,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: scrollController,
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        if (index == expenses.length - 1) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 80),
                            child: ExpenseItem(expense: expenses[index], documentId: documentIds[index]),
                          );
                        } else {
                          return ExpenseItem(expense: expenses[index], documentId: documentIds[index]);
                        }
                      },
                    ),
                  )
                : Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      RefreshIndicator(
                        onRefresh: getDocuments,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: 0,
                          itemBuilder: (context, index) => null,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: Text('Nothing to show ):', style: TextStyle(fontSize: 20)),
                      ),
                    ],
                  ),
          ),
        ]),
      ),
    );
  }

  List<Expense> expenses = [];
  List<String> documentIds = [];
  late QuerySnapshot collectionState;
  Future<void> getDocuments() async {
    AppPreferences.householdId ??= await FirestoreService().getHouseholdId();
    expenses = [];
    documentIds = [];
    var collection = FirebaseFirestore.instance
        .collection('expenses')
        .where('householdId', isEqualTo: AppPreferences.householdId)
        .orderBy("epoch", descending: true)
        .limit(10);
    fetchDocuments(collection);
  }

  Future<void> getDocumentsNext() async {
    AppPreferences.householdId ??= await FirestoreService().getHouseholdId();
    debugPrint(collectionState.docs.length.toString());
    var lastVisible = collectionState.docs[collectionState.docs.length - 1];
    var collection = FirebaseFirestore.instance
        .collection('expenses')
        .where('householdId', isEqualTo: AppPreferences.householdId)
        .orderBy("epoch", descending: true)
        .startAfterDocument(lastVisible)
        .limit(5);
    fetchDocuments(collection);
  }

  fetchDocuments(Query collection) {
    collection.get().then((value) {
      collectionState = value;
      value.docs.forEach((element) {
        setState(() {
          expenses.add(Expense.fromJson(element.data() as Map<String, dynamic>));
          documentIds.add(element.reference.id);
          for (var expense in expenses) {
            DateTime expenseDate = DateTime.fromMillisecondsSinceEpoch(expense.epoch);
            String expenseDateString =
                '${expenseDate.year.toString().padLeft(2, '0')}-${expenseDate.month.toString().padLeft(2, '0')}-${expenseDate.day.toString().padLeft(2, '0')}';
            AppPreferences.addExpenseDate(expenseDateString);
          }
        });
      });
    });
  }
}

// class HistoryScreen_ extends StatelessWidget {
//   const HistoryScreen_({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var historyState = Provider.of<HistoryState>(context);

//     // var household = Provider.of<Household>(context);

//     // List<Expense> expenses = List.from(household.expenses);
//     // expenses.sort((b, a) => a.epoch.compareTo(b.epoch));
//     // List<DateTime> expensesDates = expenses.map((e) => DateTime.fromMillisecondsSinceEpoch(e.epoch)).toList();

//     return Scaffold(
//       floatingActionButton: const NewExpenseButton(heroTag: "floating_history"),
//       body: Container(
//         margin: const EdgeInsets.only(top: 55, left: 15, right: 15, bottom: 30),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 20),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Wrap(
//                       spacing: 10,
//                       children: [
//                         ChipButton(category: categories[0], historyState: historyState),
//                         ChipButton(category: categories[1], historyState: historyState),
//                         ChipButton(category: categories[2], historyState: historyState),
//                         ChipButton(category: categories[3], historyState: historyState),
//                         ChipButton(category: categories[4], historyState: historyState),
//                         ChipButton(category: categories[5], historyState: historyState),
//                       ],
//                     ),
//                   ),
//                   Column(
//                     children: [
//                       SizedBox(
//                         width: 65,
//                         child: CategoryButton(
//                           backgroundColor: Colors.grey[850],
//                           icon: FontAwesomeIcons.calendar,
//                           iconSize: 30,
//                           iconColor: Colors.white,
//                           onPressed: () {
//                             // showDialog(
//                             //     context: context,
//                             //     builder: (context) => DateTimePickerHistory(historyState: historyState, expenseDates: expensesDates));
//                           },
//                         ),
//                       ),
//                       const Padding(padding: EdgeInsets.only(bottom: 5)),
//                       Text(historyState.fromDate.toString().split(' ')[0], style: const TextStyle(fontSize: 16)),
//                       Button(
//                         text: 'today',
//                         onPressed: () {
//                           historyState.fromDate = DateTime.now();
//                         },
//                         paddingVertical: 3,
//                         fontSize: 16,
//                         color: Theme.of(context).primaryColor,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             // Expanded(
//             //   flex: 9,
//             //   child: ListView.builder(
//             //     padding: EdgeInsets.zero,
//             //     itemCount: expenses.length,
//             //     scrollDirection: Axis.vertical,
//             //     itemBuilder: (context, index) {
//             //       if (historyState.selectedCategories[expenses[index].categoryIndex] == false) return const SizedBox.shrink();
//             //       if (expensesDates[index].isLaterDate(historyState.fromDate)) return const SizedBox.shrink();

//             //       if (index == expenses.length - 1) {
//             //         return Padding(
//             //           padding: const EdgeInsets.only(bottom: 50),
//             //           child: ExpenseItem(expense: expenses[index], idx: index),
//             //         );
//             //       } else {
//             //         return ExpenseItem(expense: expenses[index], idx: index);
//             //       }
//             //     },
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }

extension DateOnlyCompare on DateTime {
  bool isLaterDate(DateTime other) {
    return (year > other.year) || (year == other.year && month > other.month) || (year == other.year && month == other.month && day > other.day);
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

class DateTimePickerHistory extends StatelessWidget {
  final HistoryState historyState;

  const DateTimePickerHistory({super.key, required this.historyState});

  @override
  Widget build(BuildContext context) {
    List<DateTime> specialDates = AppPreferences.getExpenseDatesHistory().map((item) => DateTime.parse(item)).toList();

    return FractionallySizedBox(
      heightFactor: 0.4,
      widthFactor: 0.8,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          color: Colors.grey[850],
        ),
        child: SfDateRangePicker(
          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
            DateTime selectedDate = args.value;
            historyState.fromDate = selectedDate;
            Navigator.pop(context);
          },
          selectionMode: DateRangePickerSelectionMode.single,
          showNavigationArrow: true,
          monthViewSettings: DateRangePickerMonthViewSettings(firstDayOfWeek: 1, showWeekNumber: true, specialDates: specialDates),
          monthCellStyle: DateRangePickerMonthCellStyle(
            specialDatesDecoration:
                BoxDecoration(color: Colors.transparent, border: Border.all(color: Colors.grey[700]!, width: 1), shape: BoxShape.circle),
            specialDatesTextStyle: const TextStyle(color: Colors.white),
            textStyle: const TextStyle(color: Colors.grey),
          ),
          initialSelectedDate: historyState.fromDate,
        ),
      ),
    );
  }
}

class ExpenseItem extends StatelessWidget {
  final Expense expense;
  final String documentId;

  const ExpenseItem({super.key, required this.expense, required this.documentId});

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(expense.epoch);
    String dateString;
    if (date.isSameDate(DateTime.now())) {
      dateString = 'today';
    } else if (date.isSameDate(DateTime.now().subtract(const Duration(days: 1)))) {
      dateString = 'yesterday';
    } else {
      dateString = date.toString().split(' ')[0];
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: ElevatedButton(
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey[850]), padding: MaterialStateProperty.all(EdgeInsets.zero)),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => UpdateExpenseScreen(expense, documentId)));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Expanded(
              flex: 1,
              child: Icon(categories[expense.categoryIndex].icon, size: 24, color: categories[expense.categoryIndex].color),
            ),
            const Padding(padding: EdgeInsets.only(right: 10)),
            Expanded(
              flex: 6,
              child: Text(
                expense.description,
                style: TextStyle(fontSize: 18, color: categories[expense.categoryIndex].color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                      '${expense.amount.round().toString()} kr',
                      style: TextStyle(fontSize: 20, color: categories[expense.categoryIndex].color),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Text(
                    dateString,
                    style: const TextStyle(fontSize: 14, color: Color(0xffcccccc)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

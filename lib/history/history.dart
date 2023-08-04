import 'package:Balancer/expenses/categories.dart';
import 'package:Balancer/expenses/expenses.dart';
import 'package:Balancer/history/history_state.dart';
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
    getDocumentsAfter(DateTime.now().getDay().add(const Duration(days: 1)).millisecondsSinceEpoch - 1);
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

    callback() {
      getDocumentsAfter(historyState.fromDate.getDay().add(const Duration(days: 1)).millisecondsSinceEpoch - 1);
    }

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
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  DateTimePickerHistory(historyState: historyState, scrollController: scrollController, callback: callback));
                        },
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 5)),
                    Text(historyState.fromDate.toString().split(' ')[0], style: const TextStyle(fontSize: 16)),
                    Button(
                      text: 'today',
                      onPressed: () {
                        historyState.fromDate = DateTime.now();
                        getDocumentsAfter(historyState.fromDate.getDay().add(const Duration(days: 1)).millisecondsSinceEpoch - 1);
                      },
                      disabled: historyState.fromDate.isSameDate(DateTime.now()),
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
                    onRefresh: () async {
                      historyState.fromDate = DateTime.now();
                      getDocumentsAfter(historyState.fromDate.getDay().add(const Duration(days: 1)).millisecondsSinceEpoch - 1);
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: scrollController,
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        if (DateTime.fromMillisecondsSinceEpoch(expenses[index].epoch).isLaterDate(historyState.fromDate)) {
                          return const SizedBox.shrink();
                        }
                        if (historyState.selectedCategories[expenses[index].categoryIndex] == false) {
                          return const SizedBox.shrink();
                        }

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
                : RefreshIndicator(
                    onRefresh: () async {
                      historyState.fromDate = DateTime.now();
                      getDocumentsAfter(historyState.fromDate.getDay().add(const Duration(days: 1)).millisecondsSinceEpoch - 1);
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: 0,
                      itemBuilder: (context, index) => null,
                    ),
                  ),
          ),
        ]),
      ),
    );
  }

  List<Expense> expenses = [];
  List<String> documentIds = [];
  late QuerySnapshot collectionState;

  Future<void> getDocumentsAfter(int epoch) async {
    expenses = [];
    documentIds = [];
    var collection = await FirestoreService().getDocumentsAfter(epoch);
    fetchDocuments(collection);
  }

  Future<void> getDocumentsNext() async {
    debugPrint(collectionState.docs.length.toString());

    if (collectionState.docs.length < 5) {
      debugPrint('nothing more to show');
    }
    var lastVisible = collectionState.docs[collectionState.docs.length - 1];
    var collection = await FirestoreService().getDocumentsNext(lastVisible);
    fetchDocuments(collection);
  }

  fetchDocuments(Query collection) {
    collection.get().then((value) {
      collectionState = value;
      value.docs.forEach((element) {
        setState(() {
          expenses.add(Expense.fromJson(element.data() as Map<String, dynamic>));
          documentIds.add(element.reference.id);
        });
      });
    });
  }
}

extension DateOnlyCompare on DateTime {
  bool isLaterDate(DateTime other) {
    return (year > other.year) || (year == other.year && month > other.month) || (year == other.year && month == other.month && day > other.day);
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension Day on DateTime {
  DateTime getDay() {
    return DateTime(year, month, day);
  }
}

// ignore: must_be_immutable
class DateTimePickerHistory extends StatefulWidget {
  final HistoryState historyState;
  List<DateTime> starredDates = [];
  ScrollController scrollController;
  final dynamic callback;

  DateTimePickerHistory({super.key, required this.historyState, required this.scrollController, required this.callback});

  @override
  State<DateTimePickerHistory> createState() => _DateTimePickerHistoryState();
}

class _DateTimePickerHistoryState extends State<DateTimePickerHistory> {
  @override
  void initState() {
    super.initState();
    _getStarredDates();
  }

  _getStarredDates() async {
    var ref = await FirestoreService().getStarredDocuments();
    ref.get().then((value) {
      value.docs.forEach((element) {
        setState(() {
          Expense starredExpense = Expense.fromJson(element.data());
          DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(starredExpense.epoch);
          widget.starredDates.add(dateTime);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
          maxDate: DateTime.now().add(const Duration(days: 365)), // hacky way of redrawing the UI
          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
            DateTime selectedDate = args.value;
            widget.historyState.fromDate = selectedDate;
            Navigator.pop(context);
            widget.callback();
            widget.scrollController.jumpTo(widget.scrollController.position.minScrollExtent);
          },
          selectionMode: DateRangePickerSelectionMode.single,
          showNavigationArrow: true,
          monthViewSettings: DateRangePickerMonthViewSettings(
              firstDayOfWeek: 1, showWeekNumber: true, weekNumberStyle: const DateRangePickerWeekNumberStyle(), specialDates: widget.starredDates),
          monthCellStyle: DateRangePickerMonthCellStyle(
            specialDatesDecoration:
                BoxDecoration(color: Colors.transparent, border: Border.all(color: Colors.grey[700]!, width: 1), shape: BoxShape.circle),
            specialDatesTextStyle: const TextStyle(color: Colors.white),
            textStyle: const TextStyle(color: Colors.grey),
          ),
          initialSelectedDate: widget.historyState.fromDate,
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

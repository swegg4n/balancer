import 'package:Balancer/expenses/categories.dart';
import 'package:Balancer/expenses/expenses_state.dart';
import 'package:Balancer/services/app_preferences.dart';
import 'package:Balancer/services/bottom_modal.dart';
import 'package:Balancer/services/firestore.dart';
import 'package:Balancer/services/models.dart';
import 'package:Balancer/shared/button.dart';
import 'package:Balancer/shared/input.dart';
import 'package:Balancer/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:provider/provider.dart';

import '../analytics/analytics_state.dart';

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
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const UpdateExpenseScreen(null, null)));
        },
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}

class UpdateExpenseScreen extends StatefulWidget {
  final Expense? existingExpense;
  final String? documentId;

  const UpdateExpenseScreen(this.existingExpense, this.documentId, {super.key});

  @override
  State<UpdateExpenseScreen> createState() => _UpdateExpenseScreenState();
}

class _UpdateExpenseScreenState extends State<UpdateExpenseScreen> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  double splitPct = 50;
  bool allInfoProvided = false;

  bool loading = false;
  void setLoading(bool value) {
    setState(() {
      loading = value;
    });
  }

  bool loading2 = false;
  void setLoading2(bool value) {
    setState(() {
      loading2 = value;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var expensesState = Provider.of<ExpensesState>(context, listen: false);

      if (widget.existingExpense != null) {
        expensesState.selectedDate = DateTime.fromMillisecondsSinceEpoch(widget.existingExpense!.epoch);
        expensesState.selectedCategory = categories[widget.existingExpense!.categoryIndex];
        descriptionController.text = widget.existingExpense!.description;
        amountController.text = widget.existingExpense!.amount.round().toString();
        splitPct = (widget.existingExpense!.split * 100).roundToDouble();
        expensesState.starred = await FirestoreService().starredDocumentExists(widget.documentId);
      } else {
        expensesState.selectedCategory = categories[AppPreferences.getLastCategoryIndex()];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var expensesState = Provider.of<ExpensesState>(context);
    var analyticsState = Provider.of<AnalyticsState>(context);

    String date = expensesState.selectedDate.toString().split(' ')[0];

    bool editExpense = widget.existingExpense != null;

    return WillPopScope(
      onWillPop: () async {
        expensesState.reset();
        return true;
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: FittedBox(
                fit: BoxFit.fitWidth, child: Text(editExpense ? 'edit expense' : 'add a new expense', style: const TextStyle(fontSize: 20))),
            leading: IconButton(
              icon: const Icon(FontAwesomeIcons.xmark),
              onPressed: () {
                expensesState.reset();
                Navigator.pop(context);
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: IconButton(
                    onPressed: () {
                      expensesState.toggleStarred();
                    },
                    icon: Icon(
                      size: 22,
                      expensesState.starred ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star,
                      fill: 1,
                    )),
              )
            ],
            backgroundColor: Colors.grey[850],
          ),
          body: Container(
            margin: const EdgeInsets.only(top: 25, left: 50, right: 50, bottom: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFieldPrimary(
                        label: editExpense ? '' : '0',
                        fontSize: 20,
                        icon: null,
                        outline: false,
                        controller: amountController,
                        inputType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        autofocus: true,
                        onChanged: () {
                          setState(() {
                            allInfoProvided = amountController.text.isNotEmpty;
                          });
                        },
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(right: 15)),
                    const Text('kr', style: TextStyle(fontSize: 20, color: Color(0xffcccccc))),
                    const Spacer(),
                    CategoryButton(
                      icon: expensesState.selectedCategory.icon!,
                      iconColor: expensesState.selectedCategory.color,
                      onPressed: () {
                        showDialog(context: context, builder: (context) => CategoriesPicker(expensesState: expensesState));
                      },
                    )
                  ],
                ),
                const Spacer(),
                TextFieldPrimary(
                  label: editExpense ? '' : '(description)',
                  fontSize: 20,
                  icon: null,
                  outline: false,
                  controller: descriptionController,
                  inputType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  autofocus: false,
                  onChanged: () {
                    setState(() {
                      allInfoProvided = amountController.text.isNotEmpty;
                    });
                  },
                ),
                const Spacer(flex: 2),
                Visibility(
                  visible: expensesState.selectedCategory.index != 6,
                  maintainSize: true,
                  maintainState: true,
                  maintainAnimation: true,
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 18,
                            width: 2,
                            child: Container(
                                color: Theme.of(context).primaryColor),
                          ),
                          Slider(
                              value: splitPct,
                              min: 0.0,
                              max: 100.0,
                              divisions: 20,
                              label: '${splitPct.round()}%',
                              onChanged: (value) {
                                setState(() {
                                  splitPct = value;
                                });
                              }),
                        ],
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '0%\nfor me',
                            style: TextStyle(
                                fontSize: 15, color: Color(0xffcccccc)),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '100%\nfor me',
                            style: TextStyle(
                                fontSize: 15, color: Color(0xffcccccc)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ButtonIconR(
                  text: date,
                  icon: FontAwesomeIcons.calendar,
                  iconSize: 24,
                  fontSize: 20,
                  paddingHorizontal: 5,
                  color: Colors.grey[850],
                  onPressed: () {
                    showDialog(context: context, builder: (context) => DateTimePickerExpenses(expensesState: expensesState));
                  },
                ),
                const Spacer(flex: 3),
                Stack(alignment: Alignment.center, children: [
                  Visibility(
                    visible: loading,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: const Loader(
                      size: 46,
                    ),
                  ),
                  Visibility(
                    visible: !loading,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: Button(
                      text: editExpense ? 'Update' : 'Add',
                      fontSize: 24,
                      paddingVertical: 20,
                      paddingHorizontal: 50,
                      color: Theme.of(context).primaryColor,
                      onPressed: () async {
                        setLoading(true);

                        FocusManager.instance.primaryFocus?.unfocus();

                        bool success = false;
                        Expense newExpense = Expense(
                          description: descriptionController.text,
                          amount: double.parse(amountController.text).abs(),
                          categoryIndex: expensesState.selectedCategory.index,
                          epoch: expensesState.selectedDate.millisecondsSinceEpoch,
                          split: splitPct / 100,
                        );

                        if (editExpense) {
                          success = await FirestoreService().updateExpense(newExpense, widget.documentId!, expensesState.starred);
                        } else {
                          success = await FirestoreService().createExpense(newExpense, expensesState.starred);
                        }

                        if (success) {
                          BottomModal.showSuccessModal(context, 'Success!', editExpense ? 'The expense was updated' : 'The expense was added');
                          expensesState.hasModifiedExpense = true;
                          analyticsState.hasModifiedDate = true;

                          await Future.delayed(Duration(milliseconds: 1500));
                          Navigator.of(context).popUntil((route) => route.isFirst);

                          expensesState.reset();
                          descriptionController.text = '';
                          amountController.text = '';
                          splitPct = 50;
                          allInfoProvided = false;
                        } else {
                          BottomModal.showErrorModal(context, 'Failed to ${editExpense ? 'edit' : 'add'} expense', 'Please try again');
                        }

                        setLoading(false);
                      },
                      disabled: !allInfoProvided && !editExpense,
                    ),
                  ),
                ]),
                Visibility(
                  visible: editExpense,
                  child: Stack(alignment: Alignment.center, children: [
                    Visibility(
                      visible: loading2,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: Loader(
                        size: 32,
                        color: Colors.red[400],
                      ),
                    ),
                    Visibility(
                      visible: !loading2,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Button(
                          text: 'Delete',
                          fontSize: 20,
                          paddingVertical: 10,
                          paddingHorizontal: 60,
                          color: Colors.red[400],
                          onPressed: () async {
                            setLoading2(true);

                            bool success = false;
                            success = await FirestoreService().deleteExpense(widget.documentId!);

                            if (success) {
                              BottomModal.showSuccessModal(context, 'Success!', 'The expense was deleted');
                              expensesState.hasModifiedExpense = true;
                              analyticsState.hasModifiedDate = true;

                              if (editExpense) {
                                await Future.delayed(Duration(seconds: 2));
                                FocusManager.instance.primaryFocus?.unfocus();
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              }

                              expensesState.reset();
                              descriptionController.text = '';
                              amountController.text = '';
                              splitPct = 50;
                              allInfoProvided = false;
                            } else {
                              BottomModal.showErrorModal(context, 'Failed to delete expense', 'Please try again');
                            }

                            setLoading2(false);
                          },
                          disabled: !allInfoProvided && !editExpense,
                        ),
                      ),
                    ),
                  ]),
                ),
                const Spacer(flex: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoriesPicker extends StatelessWidget {
  final ExpensesState expensesState;

  const CategoriesPicker({super.key, required this.expensesState});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Expanded(flex: 2, child: SizedBox()),
          Expanded(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                color: Colors.grey[900],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: categories
                    .map(
                      (c) => SizedBox(
                        height: (8 / 12 * MediaQuery.of(context).size.height) / 8 - 7,
                        child: ButtonIconL(
                          text: c.name,
                          subtext: c.description,
                          icon: c.icon,
                          iconSize: 28,
                          fontSize: 20,
                          textColor: c.color,
                          iconColor: c.color,
                          paddingVertical: 5,
                          color: Colors.grey[850],
                          fit: true,
                          onPressed: () {
                            expensesState.selectedCategory = categories[c.index];
                            if (c.index != 6) AppPreferences.setLastCategoryIndex(c.index);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const Expanded(flex: 2, child: SizedBox()),
        ],
      ),
    );
  }
}

class DateTimePickerExpenses extends StatelessWidget {
  final ExpensesState expensesState;

  const DateTimePickerExpenses({super.key, required this.expensesState});

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
          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
            DateTime selectedDate = args.value;
            expensesState.selectedDate = selectedDate;
            Navigator.pop(context);
          },
          selectionMode: DateRangePickerSelectionMode.single,
          showNavigationArrow: true,
          monthViewSettings: const DateRangePickerMonthViewSettings(firstDayOfWeek: 1, showWeekNumber: true),
          initialSelectedDate: expensesState.selectedDate,
        ),
      ),
    );
  }
}

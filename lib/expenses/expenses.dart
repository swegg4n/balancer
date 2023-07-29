import 'package:Balancer/expenses/categories.dart';
import 'package:Balancer/expenses/expenses_state.dart';
import 'package:Balancer/main.dart';
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

class NewExpenseScreen extends StatefulWidget {
  const NewExpenseScreen({super.key});

  @override
  State<NewExpenseScreen> createState() => _NewExpenseScreenState();
}

class _NewExpenseScreenState extends State<NewExpenseScreen> {
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

  @override
  Widget build(BuildContext context) {
    var expensesState = Provider.of<ExpensesState>(context);

    String date =
        '${expensesState.selectedDate.year}-${expensesState.selectedDate.month.toString().padLeft(2, '0')}-${expensesState.selectedDate.day.toString().padLeft(2, '0')}';

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
            title: const FittedBox(fit: BoxFit.fitWidth, child: Text('add a new expense', style: TextStyle(fontSize: 20))),
            leading: IconButton(
              icon: const Icon(FontAwesomeIcons.xmark),
              onPressed: () {
                expensesState.reset();
                Navigator.pop(context);
              },
            ),
            backgroundColor: Colors.grey[850],
          ),
          body: Container(
            margin: const EdgeInsets.only(top: 25, left: 50, right: 50, bottom: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFieldPrimary(
                  label: 'Enter a description',
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
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: TextFieldPrimary(
                        label: '0',
                        fontSize: 20,
                        icon: null,
                        outline: false,
                        controller: amountController,
                        inputType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        autofocus: false,
                        onChanged: () {
                          setState(() {
                            allInfoProvided = amountController.text.isNotEmpty;
                          });
                        },
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(right: 15)),
                    const Text('SEK', style: TextStyle(fontSize: 20, color: Color(0xffcccccc))),
                    const Spacer(),
                    CategoryButton(
                      icon: expensesState.selectedCategory.icon!,
                      onPressed: () {
                        showDialog(context: context, builder: (context) => CategoriesPicker(expensesState: expensesState));
                      },
                    )
                  ],
                ),
                const Spacer(flex: 2),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 18,
                      width: 2,
                      child: Container(color: Theme.of(context).primaryColor),
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
                    Text('0% for me', style: TextStyle(fontSize: 16, color: Color(0xffcccccc))),
                    Text('100% for me', style: TextStyle(fontSize: 16, color: Color(0xffcccccc))),
                  ],
                ),
                const Spacer(),
                ButtonIcon(
                  text: date,
                  icon: FontAwesomeIcons.calendar,
                  iconSize: 24,
                  fontSize: 20,
                  paddingHorizontal: 5,
                  color: Colors.grey[850],
                  onPressed: () {
                    showDialog(context: context, builder: (context) => DateTimePicker(expensesState: expensesState));
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
                      text: 'Add',
                      fontSize: 24,
                      paddingVertical: 20,
                      paddingHorizontal: 50,
                      color: Theme.of(context).primaryColor,
                      onPressed: () async {
                        setLoading(true);

                        bool success = await FirestoreService().createExpense(
                          Expense(
                            description: descriptionController.text,
                            amount: double.parse(amountController.text),
                            categoryIndex: expensesState.selectedCategory.index,
                            date: expensesState.selectedDate.toString(),
                            split: splitPct / 100,
                          ),
                        );

                        if (success) {
                          expensesState.reset();
                          descriptionController.text = '';
                          amountController.text = '';
                          splitPct = 50;
                          allInfoProvided = false;
                          BottomModal.showSuccessModal(context, 'Success!', 'The expense was added');
                        } else {
                          BottomModal.showErrorModal(context, 'Failed to add expense', 'Please try again');
                        }
                        setLoading(false);
                      },
                      disabled: !allInfoProvided,
                    ),
                  ),
                ]),
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
                      (c) => ButtonIcon(
                        text: c.name,
                        subtext: c.description,
                        icon: c.icon,
                        iconSize: 28,
                        fontSize: 20,
                        textColor: c.color,
                        iconColor: c.color,
                        color: Colors.grey[850],
                        onPressed: () {
                          expensesState.selectedCategory = categories[c.index];
                          Navigator.pop(context);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const Expanded(flex: 3, child: SizedBox()),
        ],
      ),
    );
  }
}

class DateTimePicker extends StatelessWidget {
  final ExpensesState expensesState;

  const DateTimePicker({super.key, required this.expensesState});

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

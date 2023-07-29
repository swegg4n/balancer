import 'package:Balancer/expenses/categories.dart';
import 'package:flutter/widgets.dart';

class ExpensesState with ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;
  set selectedDate(DateTime value) {
    _selectedDate = value;
    notifyListeners();
  }

  Category _selectedCategory = categories[0];
  Category get selectedCategory => _selectedCategory;
  set selectedCategory(Category value) {
    _selectedCategory = value;
    notifyListeners();
  }

  void reset() {
    _selectedDate = DateTime.now();
    _selectedCategory = categories[0];
  }
}

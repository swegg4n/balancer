import 'package:Balancer/expenses/categories.dart';
import 'package:Balancer/services/app_preferences.dart';
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

  bool _starred = false;
  bool get starred => _starred;
  void set starred(bool value) {
    _starred = value;
    notifyListeners();
  }

  void toggleStarred() {
    _starred = !_starred;
    notifyListeners();
  }

  bool _hasModifiedExpense = false;
  bool get hasModifiedExpense => _hasModifiedExpense;
  void set hasModifiedExpense(bool value) {
    _hasModifiedExpense = value;
    notifyListeners();
  }

  void reset() {
    _selectedDate = DateTime.now();
    _selectedCategory = categories[AppPreferences.getLastCategoryIndex()];
    _starred = false;
  }
}

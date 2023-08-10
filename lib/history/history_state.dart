import 'package:flutter/widgets.dart';

class HistoryState with ChangeNotifier {
  DateTime _fromDate = DateTime.now();
  DateTime get fromDate => _fromDate;
  set fromDate(DateTime value) {
    _fromDate = value;
    notifyListeners();
  }

  List<bool> _selectedCategories = [true, true, true, true, true, true, true];
  List<bool> get selectedCategories => _selectedCategories;
  set selectedCategories(List<bool> values) {
    _selectedCategories = values;
    notifyListeners();
  }

  void toggleSelectedCategory(int idx) {
    _selectedCategories[idx] = !_selectedCategories[idx];
    notifyListeners();
  }

  bool listenerAdded_ = false;
  bool get listenerAdded => listenerAdded_;
  set listenerAdded(bool value) {
    listenerAdded_ = value;
    notifyListeners();
  }

  bool _allDataFetched = false;
  bool get allDataFetched => _allDataFetched;
  set allDataFetched(bool value) {
    _allDataFetched = value;
    notifyListeners();
  }

  void reset() {
    _fromDate = DateTime.now();
    _selectedCategories = [true, true, true, true, true, true, true];
    _allDataFetched = false;
  }
}

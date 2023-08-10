import 'package:flutter/widgets.dart';

class AnalyticsState with ChangeNotifier {
  bool _hasModifiedDate = false;
  bool get hasModifiedDate => _hasModifiedDate;
  void set hasModifiedDate(bool value) {
    _hasModifiedDate = value;
    notifyListeners();
  }

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;
  void set selectedDate(DateTime value) {
    _selectedDate = value;
    notifyListeners();
  }
}

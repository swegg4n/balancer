import 'package:flutter/widgets.dart';

class HomeState with ChangeNotifier {
  int _selectedIndex = 1;

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int value) {
    _selectedIndex = value;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppPreferences {
  static late SharedPreferences _prefs;
  static late PackageInfo packageInfo;
  static late String appVersion;
  static String? householdId;

  static Future init() async {
    packageInfo = await PackageInfo.fromPlatform();
    _prefs = await SharedPreferences.getInstance();

    String version;
    String buildNumber;

    List<String> split = packageInfo.version.split('.');
    version = "${split[0]}.${split[1]}";
    buildNumber = packageInfo.buildNumber;

    appVersion = "version $version ($buildNumber)";
  }

  static const String _expenseDatesHistoryKey = 'expenseDatesHistoryKey';
  static List<String> getExpenseDatesHistory() {
    Object? obj = _prefs.get(_expenseDatesHistoryKey) ?? [];
    List<String> list = (obj as List<dynamic>).map((item) => item as String).toList();

    for (var e in list) {
      debugPrint(e);
    }
    debugPrint('-');
    return list;
  }

  static Future<void> addExpenseDate(String date) async {
    List<String> existingDates = getExpenseDatesHistory();
    if (!existingDates.contains(date)) {
      existingDates.add(date);
      await _prefs.setStringList(_expenseDatesHistoryKey, existingDates);
    }
  }

  static Future<void> removeExpenseDate(String date) async {
    List<String> existingDates = getExpenseDatesHistory();
    if (existingDates.contains(date)) {
      existingDates.remove(date);
      await _prefs.setStringList(_expenseDatesHistoryKey, existingDates);
    }
  }
}

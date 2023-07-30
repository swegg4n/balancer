import 'package:Balancer/services/firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'auth.dart';

class AppPreferences {
  static late SharedPreferences _prefs;
  static late PackageInfo packageInfo;
  static late String appVersion;
  static late String householdId;

  static Future init() async {
    packageInfo = await PackageInfo.fromPlatform();
    _prefs = await SharedPreferences.getInstance();

    String version;
    String buildNumber;

    List<String> split = packageInfo.version.split('.');
    version = "${split[0]}.${split[1]}";
    buildNumber = packageInfo.buildNumber;

    appVersion = "version $version ($buildNumber)";

    householdId = await FirestoreService().getHouseholdId();
  }
}

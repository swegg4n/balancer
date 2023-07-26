import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppPreferences {
  static late SharedPreferences _prefs;
  static late PackageInfo packageInfo;
  static late String appVersion;

  static Future init() async {
    packageInfo = await PackageInfo.fromPlatform();
    _prefs = await SharedPreferences.getInstance();

    String version;
    String buildNumber;

    if (Platform.isAndroid) {
      List<String> split = packageInfo.version.split('.');
      version = "${split[0]}.${split[1]}";
      buildNumber = packageInfo.buildNumber;
    } else {
      List<String> split = packageInfo.buildNumber.split('.');
      version = "${split[0]}.${split[1]}";
      buildNumber = packageInfo.version;
    }
    appVersion = "version $version ($buildNumber)";
  }
}
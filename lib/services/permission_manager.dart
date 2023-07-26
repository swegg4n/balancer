import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  static Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();
    debugPrint('request permission: $permission, isGranted?: ${status.isGranted}');

    return status.isGranted;
  }
}

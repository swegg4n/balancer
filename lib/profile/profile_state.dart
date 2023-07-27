import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileState with ChangeNotifier {
  final ImagePicker _imagePicker = ImagePicker();

  String? chosenName;

  XFile? _chosenImage;
  XFile? get chosenImage => _chosenImage;
  set chosenImage(XFile? value) {
    _chosenImage = value;
    notifyListeners();
  }

  Future selectPicture() async {
    XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 20,
      maxHeight: 2048,
      maxWidth: 2048,
    );
    if (image != null) {
      chosenImage = image;
      debugPrint('Selected image: ' + chosenImage!.name);
    }
  }

  bool _saving = false;
  bool get saving => _saving;
  set saving(bool value) {
    _saving = value;
    notifyListeners();
  }

  final List<String> _batchUpdateLog = [];
  List<String> get batchUpdateLog => _batchUpdateLog;
  void addBatchUpdateLog(String value) {
    _batchUpdateLog.add(value);
    notifyListeners();
  }

  void clearBatchUpdateLog() {
    _batchUpdateLog.clear();
    notifyListeners();
  }

  bool _batchUpdating = false;
  bool get batchUpdating => _batchUpdating;
  set batchUpdating(bool value) {
    _batchUpdating = value;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:kaiteki/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kModeKey = "themeMode";
const kUseMaterial3Key = "m3";

class ThemePreferences extends ChangeNotifier {
  final SharedPreferences _preferences;

  ThemeMode get mode {
    final modeValue = _preferences.getString(kModeKey);
    if (modeValue == null) return ThemeMode.system;
    return ThemeMode.values.firstWhere((v) => v.name == modeValue);
  }

  set mode(ThemeMode value) {
    if (mode == value) return;

    _preferences.setString(kModeKey, value.name).then((_) => notifyListeners());
  }

  bool? get useMaterial3 => _preferences.getBool(kUseMaterial3Key);

  set useMaterial3(bool? value) {
    if (useMaterial3 == value) return;
    _preferences.setTristateBool(kUseMaterial3Key, value);
    notifyListeners();
  }

  final bool material3Default;

  ThemePreferences(this._preferences, this.material3Default);
}

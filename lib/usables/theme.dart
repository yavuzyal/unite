import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyTheme with ChangeNotifier{

  static bool _isDark = false;

  Future<ThemeMode> currentTheme() async{
    var prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDark') ?? false;

    return _isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void switchTheme() async{
    _isDark = !_isDark;
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDark', _isDark);
    notifyListeners();
  }

}

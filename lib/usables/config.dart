library config.globals;
import 'package:flutter/material.dart';
import 'package:unite/usables/theme.dart';

bool light = true;
int selectedIndex = 0;

ThemeData darkTheme = ThemeData(
  accentColor: Colors.red,
  brightness: Brightness.dark,
  primaryColor: Colors.amber,

);

ThemeData lightTheme = ThemeData(
    accentColor: Colors.pink,
    brightness: Brightness.light,
    primaryColor: Colors.blue
);


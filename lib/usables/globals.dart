

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

ThemeData _darkTheme = ThemeData(
  accentColor: Colors.red,
  brightness: Brightness.dark,
  primaryColor: Colors.amber,

);

ThemeData _lightTheme = ThemeData(
    accentColor: Colors.pink,
    brightness: Brightness.light,
    primaryColor: Colors.blue
);

FirebaseAnalytics analytics = FirebaseAnalytics.instance;
FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);
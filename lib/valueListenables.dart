import 'package:flutter/material.dart';
import 'usables/config.dart' as globals;

class valueListenables{

static ValueNotifier<bool> bookmarkedPost =ValueNotifier(false);
static ValueNotifier<bool> theme =ValueNotifier(globals.light);


}
import 'package:DarkSurviver/pages/app.dart';
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;

import 'package:flutter/material.dart';

void main() async {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(App());
}

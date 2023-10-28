import "dart:io";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "android_source/android.dart";
import "web_source/web.dart";


import 'util/student.dart';
void main() {
  if(kIsWeb) {
    runApp(const WebApp());
  } else if(Platform.isAndroid) {
    runApp(const AndroidApp());
  }
}


import 'package:afib/src/flutter/af.dart';
import 'package:flutter/material.dart';
import 'package:afib/src/flutter/af_app.dart';

/// [afMain] handles startup, execution, and shutdown sequence for an afApp
void afMain() {
  final AFApp app = AF.createApp();
  app.afBeforeRunApp();
  runApp(app);
  app.afAfterRunApp();

}

import 'package:flutter/material.dart';
import 'package:afib/src/flutter/af_app.dart';

/// [afMain] handles startup, execution, and shutdown sequence for an afApp
void afMain(AFApp app) {

  app.beforeRunApp();
  runApp(app);
  app.afterRunApp();

}

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/utils/af_flutter_params.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter/material.dart';
import 'package:afib/src/flutter/af_app.dart';

/// [afMain] handles startup, execution, and shutdown sequence for an afApp
void afMain(AFDartParams paramsD, AFFlutterParams paramsF) {
  AFibD.initialize(paramsD);
  AFibF.initialize(paramsF);
  
  final AFApp app = AFibF.createApp();
  app.afBeforeRunApp();
  runApp(app);
  app.afAfterRunApp();

}
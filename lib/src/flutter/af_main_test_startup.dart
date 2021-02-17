
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void afTestMainStartup() {
  TestWidgetsFlutterBinding.ensureInitialized();
}


Future<void> afTestWidgetStartup(AFDartParams params, WidgetTester tester, Function() onRun) async {
  final screenSize = Size(2688, 1242); // Size(2732, 2042); // Size(1170, 2532);
  await tester.binding.setSurfaceSize(screenSize);
  tester.binding.window.physicalSizeTestValue = screenSize;
  tester.binding.window.devicePixelRatioTestValue = 1.0;
  await onRun();
}
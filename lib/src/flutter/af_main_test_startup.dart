
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void afMainTestFirstStartup() {
  TestWidgetsFlutterBinding.ensureInitialized();
}


Future<void> afMainTestConfigureScreenSize(WidgetTester tester) async {
  final screenSize = Size(2688, 1242);
  await tester.binding.setSurfaceSize(screenSize);
  tester.binding.window.physicalSizeTestValue = screenSize;
  tester.binding.window.devicePixelRatioTestValue = 1.0;

}
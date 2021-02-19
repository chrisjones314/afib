
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:flutter_test/flutter_test.dart';

void afTestMainStartup() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AFibD.registerGlobals();
}


Future<void> afTestWidgetStartup(AFDartParams params, WidgetTester tester, Function() onRun) async {
  await onRun();
}
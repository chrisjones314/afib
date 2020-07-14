
import 'package:afib/afib_dart.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_state_test_main.dart';
import 'package:afib/src/flutter/test/af_unit_tests.dart';
import 'package:afib/src/flutter/utils/af_flutter_params.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter_test/flutter_test.dart';

/// The main function which executes the tests defined in your initUnitTests function.
void afUnitTestMain(AFDartParams paramsD, AFFlutterParams paramsF) {
  final paramsTest = paramsD.forceEnvironment(AFConfigEntryEnvironment.testStore);
  AFibD.initialize(paramsTest);
  AFibF.initialize(paramsF);

  final tests = AFibF.unitTests;
  final contexts = List<AFUnitTestContext>();

  tests.tests.forEach((test) {
    final context = AFUnitTestContext(test);
    test.execute(context);
    contexts.add(context);
  });

  final baseContexts = List<AFBaseTestExecute>.of(contexts);
  final output = AFCommandOutput();
  int totalErrors = printTestResults(output, "Unit", baseContexts);
  
  if(totalErrors > 0) {
    expect("$totalErrors errors (see details above)", AFibTestsFailedMatcher());
  }

}
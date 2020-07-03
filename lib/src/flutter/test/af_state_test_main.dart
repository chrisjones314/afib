

import 'package:afib/afib_dart.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_state_test.dart';
import 'package:afib/src/flutter/utils/af_flutter_params.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colorize/colorize.dart';

class AFibTestsFailedMatcher extends Matcher {
  AFibTestsFailedMatcher();

  @override
  Description describe(Description description) {
    return description.add("AFib state tests have no errors");
  }
  
  @override
  bool matches(desc, Map matchState) {
    return false;
  }

}

/// The main function which executes the store test defined in your initStateTests function.
void afStateTestMain(AFDartParams paramsD, AFFlutterParams paramsF) {
  final paramsTest = paramsD.forceEnvironment(AFConfigEntryEnvironment.testStore);
  AFibD.initialize(paramsTest);
  AFibF.initialize(paramsF);

  final tests = AFibF.stateTests;
  final contexts = List<AFStateTestContext>();

  tests.tests.forEach((test) {
    final context = AFStateTestContext(test, isTrueTestContext: true);
    
    context.store.dispatch(AFResetToInitialStateAction());
    test.execute(context);
    contexts.add(context);
  });

  final baseContexts = List<AFBaseTestExecute>.of(contexts);
  final output = AFCommandOutput();
  int totalErrors = printTestResults(output, "State", baseContexts);
  
  if(totalErrors > 0) {
    expect("$totalErrors errors (see details above)", AFibTestsFailedMatcher());
  }

}
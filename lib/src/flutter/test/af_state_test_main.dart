

import 'package:afib/src/flutter/af.dart';
import 'package:afib/src/flutter/test/af_state_test.dart';
import 'package:flutter_test/flutter_test.dart';

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
void afStateTestMain() {
  final tests = AF.stateTests;
  final errorContexts = List<AFStateTestContext>();

  tests.tests.forEach((test) {
    final context = AFStateTestContext(test, isTrueTestContext: true);
    test.execute(context);
    if(context.hasErrors) {
      errorContexts.add(context);
    }
  });

  if(errorContexts.isNotEmpty) {
    print("------------------------------\nAfib State Test Errors:\n");
    int totalErrors = 0;
    errorContexts.forEach((context) {
      final test = context.test;
      print("    ${test.id.code}: ${test.id.name}");
      context.errors.forEach((error) {
        print("        $error");
      });
      totalErrors += context.errors.length;
    });
    print("------------------------------");
    expect("$totalErrors errors (see details above)", AFibTestsFailedMatcher());
  }
}
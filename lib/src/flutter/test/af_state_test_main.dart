

import 'package:afib/afib_dart.dart';
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
  final contexts = List<AFStateTestContext>();

  tests.tests.forEach((test) {
    final context = AFStateTestContext(test, isTrueTestContext: true);
    
    context.store.dispatch(AFResetToInitialStateAction());
    test.execute(context);
    contexts.add(context);
  });

  print("------------------------------\nAfib State Tests:\n");
  for(var context in contexts) {
    final test = context.test;
    if(!context.hasErrors) {
      print("    ${test.id.code}: ${context.pass} passed");
    }
  }

  int totalErrors = 0;
  for(var context in contexts) {
    final test = context.test;
    if(context.hasErrors) {
      print("    ${test.id.code}:");
      context.errors.forEach((error) {
        print("        $error");
      });
      totalErrors += context.errors.length;
    }
  }
  print("------------------------------");
  if(totalErrors > 0) {
    expect("$totalErrors errors (see details above)", AFibTestsFailedMatcher());
  }

}
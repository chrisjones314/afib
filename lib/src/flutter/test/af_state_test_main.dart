

import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_state_test.dart';
import 'package:afib/src/flutter/test/af_test_stats.dart';
import 'package:afib/src/flutter/utils/af_flutter_params.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';

/// The main function which executes the store test defined in your initStateTests function.
void afStateTestMain(AFCommandOutput output, AFTestStats stats, AFDartParams paramsD, AFFlutterParams paramsF) {
  if(!AFConfigEntries.enabledTestList.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.stateTests)) {
    return;
  }

  final tests = AFibF.stateTests;
  final contexts = <AFStateTestContext>[];
  AFibF.testOnlyShouldSuppressNavigation = true;

  for(final test in tests.tests) {
    if(AFConfigEntries.enabledTestList.isTestEnabled(AFibD.config, test.id)) {
      final store = AFibF.testOnlyStore;
      final dispatcher = AFStoreDispatcher(store);
      final context = AFStateTestContext(test, store, dispatcher, isTrueTestContext: true);
      
      context.store.dispatch(AFResetToInitialStateAction());
      test.execute(context);
      contexts.add(context);
    }
  }

  AFibF.testOnlyShouldSuppressNavigation = false;
  final baseContexts = List<AFBaseTestExecute>.of(contexts);
  printTestResults(output, "State", baseContexts, stats);
  
}


import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_state_test.dart';
import 'package:afib/src/flutter/test/af_test_stats.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';

/// The main function which executes the store test defined in your initStateTests function.
void afStateTestMain<TState extends AFAppStateArea> (AFCommandOutput output, AFTestStats stats, AFDartParams paramsD) {
  if(!AFConfigEntries.enabledTestList.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.stateTests)) {
    return;
  }

  final tests = AFibF.g.stateTests;
  final contexts = <AFStateTestContext>[];
  final testKind = "State";
  final localStats = AFTestStats();

  final store = AFibF.g.storeInternalOnly;
  final dispatcher = AFStoreDispatcher(store);
  for(final test in tests.tests) {
    if(AFConfigEntries.enabledTestList.isTestEnabled(AFibD.config, test.id)) {
      final context = AFStateTestContext<TState>(test, store, dispatcher, isTrueTestContext: true);
      
      context.store.dispatch(AFResetToInitialStateAction());
      context.store.dispatch(AFResetToInitialRouteAction());
      test.execute(context);
      contexts.add(context);
      printTestResult(output, testKind, context, localStats);
    }
  }

  store.dispatch(AFNavigateExitTestAction());

  final baseContexts = List<AFBaseTestExecute>.of(contexts);
  printTestTotal(output, testKind, baseContexts, localStats);
  stats.mergeIn(localStats);

}
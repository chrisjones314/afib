import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/dart/redux/actions/af_app_state_actions.dart';
import 'package:afib/src/dart/redux/actions/af_query_actions.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_state_test.dart';
import 'package:afib/src/flutter/test/af_test_stats.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';

/// The main function which executes the store test defined in your initStateTests function.
void afStateTestMain<TState extends AFFlexibleState> (AFCommandOutput output, AFTestStats stats, AFDartParams paramsD) {
  if(!AFConfigEntries.testsEnabled.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.stateTests)) {
    return;
  }

  final tests = AFibF.g.stateTests;
  final contexts = <AFStateTestContext>[];
  final testKind = "State";
  final localStats = AFTestStats();

  final store = AFibF.g.internalOnlyActiveStore;

  for(final test in tests.tests) {
    if(AFConfigEntries.testsEnabled.isTestEnabled(AFibD.config, test.id)) {
      if(localStats.isEmpty) {
        printTestKind(output, testKind);
      }
      printPrototypeStart(output, test.id);
      final context = AFStateTestContextForState<TState>(test as AFStateTest<AFFlexibleState>,  AFConceptualStore.appStore, isTrueTestContext: true);
      
      context.store.dispatch(AFResetToInitialStateAction());
      context.store.dispatch(AFResetToInitialRouteAction());
      test.execute(context);
      contexts.add(context);

      output.indent();
      printTestResult(output, testKind, context, localStats);
      output.outdent();
      context.finishAndUpdateStats(localStats);

      AFibF.g.internalOnlyActiveStore.dispatch(AFShutdownOngoingQueriesAction());

    }
  }

  store.dispatch(AFNavigateExitTestAction());
  AFStateTestContext.currentTest = null;


  final baseContexts = List<AFBaseTestExecute>.of(contexts);
  printTestTotal(output, baseContexts, localStats);
  stats.mergeIn(localStats);

}
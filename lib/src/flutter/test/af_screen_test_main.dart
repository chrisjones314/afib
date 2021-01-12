

import 'package:afib/afib_dart.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/af_app.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_prototype_widget_screen.dart';
import 'package:afib/src/flutter/test/af_test_dispatchers.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/test/af_test_stats.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> afScreenTestMain<TState extends AFAppStateArea>(AFCommandOutput output, AFTestStats stats, AFDartParams paramsD1, WidgetTester tester) async {
  final isWidget = AFConfigEntries.enabledTestList.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.widgetTests);
  final isSingle = AFConfigEntries.enabledTestList.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.screenTests);
  final isMulti  = AFConfigEntries.enabledTestList.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.workflowTests);
  if(!isSingle && !isMulti && !isWidget) {
    return;
  }

  AFibD.config.setValue(AFConfigEntries.widgetTesterContext, AFConfigEntryBool.trueValue);
  final app = AFibF.g.createApp();
  await tester.pumpWidget(app);

  if(isWidget) {
    await _afWidgetTestMain<TState>(output, stats, tester, app);
  }

  if(isSingle) {
    await _afSingleScreenTestMain<TState>(output, stats, tester, app);
  }

  if(isMulti) {
    await _afWorkflowTestMain<TState>(output, stats, tester, app);
  }

  return null;
}

Future<void> _afStandardScreenTestMain<TState extends AFAppStateArea>(
  AFCommandOutput output, 
  AFTestStats stats, 
  WidgetTester tester, 
  AFApp app,  
  List<AFScreenPrototypeTest> allTests, 
  String sectionTitle,
  AFTestCreatePushActionDelegate createPush) async {
  final simpleContexts = <AFScreenTestContextWidgetTester>[];
  final testKind = sectionTitle;
  final localStats = AFTestStats();

  for(var test in allTests) {
    if(!test.hasBody) {
      continue;
    }
    if(AFConfigEntries.enabledTestList.isTestEnabled(AFibD.config, test.id)) {
      final startActions = createPush(test);
      for(final action in startActions) {
        AFibF.g.storeInternalOnly.dispatch(action);
      }
      AFibD.logTest?.d("Starting ${test.id}");
  
      final storeDispatcher = AFStoreDispatcher(AFibF.g.storeInternalOnly);
      final dispatcher = AFSingleScreenTestDispatcher(test.id, storeDispatcher, null);
      final context = AFScreenTestContextWidgetTester(tester, app, dispatcher, test.id);
      storeDispatcher.dispatch(AFResetToInitialStateAction());
      dispatcher.dispatch(AFStartPrototypeScreenTestContextAction(context, stateView: test.stateView, screen: test.screenId, param: test.routeParam));
      dispatcher.setContext(context);
      simpleContexts.add(context);

      // tell the store to go to the correct screen.
      await tester.pumpAndSettle(Duration(seconds: 1));

      AFibD.logTest?.d("Finished pumpWidget for ${test.id}");
      //debugDumpApp();
      await test.run(context);
      AFibD.logTest?.d("Finished ${test.id}");

      // pop this test screen off so that we are ready for the next one.
      AFibF.g.storeInternalOnly.dispatch(AFNavigateExitTestAction());
      
      dispatcher.setContext(context);
      await tester.pumpAndSettle(Duration(seconds: 1));
      printTestResult(output, testKind, context, localStats);

    }
  }

  final baseContexts = List<AFBaseTestExecute>.of(simpleContexts);
  printTestTotal(output, testKind, baseContexts, localStats);
  stats.mergeIn(localStats);
}

Future<void> _afWidgetTestMain<TState extends AFAppStateArea>(AFCommandOutput output, AFTestStats stats, WidgetTester tester, AFApp app) async {
  return _afStandardScreenTestMain<TState>(output, stats, tester, app, AFibF.g.widgetTests.all, "Widget", (test) {
    return [AFPrototypeWidgetScreen.navigatePush(test)];
  });
}

Future<void> _afSingleScreenTestMain<TState extends AFAppStateArea>(AFCommandOutput output, AFTestStats stats, WidgetTester tester, AFApp app) async {
  return _afStandardScreenTestMain<TState>(output, stats, tester, app, AFibF.g.screenTests.all, "Single-Screen", (test) {
    return [
      AFStartPrototypeScreenTestAction(test, param: test.routeParam, stateView: test.stateView, screen: test.screenId),
      AFNavigatePushAction(
        screen: test.screenId,
        param: test.routeParam
      )
    ];
  });
}

Future<void> _afWorkflowTestMain<TState extends AFAppStateArea>(AFCommandOutput output, AFTestStats stats, WidgetTester tester, AFApp app) async {
 final multiContexts = <AFScreenTestContextWidgetTester>[];
  final testKind = "Workflow";
  final localStats = AFTestStats();

  for(final test in AFibF.g.workflowTests.stateTests) {
    if(!test.hasBody) {
      continue;
    }
    if(AFConfigEntries.enabledTestList.isTestEnabled(AFibD.config, test.id)) {
      AFibD.logTest?.d("Starting test ${test.id}");

      final dispatcher = AFStoreDispatcher(AFibF.g.storeInternalOnly);
      final context = AFScreenTestContextWidgetTester(tester, app, dispatcher, test.id);
      multiContexts.add(context);

      AFWorkflowStatePrototypeTest.initializeMultiscreenPrototype<TState>(dispatcher, test);
      
      // tell the store to go to the correct screen.
      await tester.pumpAndSettle(Duration(seconds: 1));

      AFibD.logTest?.d("Finished pumpWidget for ${test.id}");
      await test.body.run(context);
      AFibD.logTest?.d("Finished ${test.id}");

      // pop this test screen off so that we are ready for the next one.
      AFibF.g.storeInternalOnly.dispatch(AFNavigateExitTestAction());
      
      //dispatcher.setContext(context);
      await tester.pumpAndSettle(Duration(seconds: 1));

      /// Clear out our cache of screen info for the next test.
      AFibF.g.resetTestScreens();
      printTestResult(output, testKind, context, localStats);
    }
  }

  final baseMultiContexts = List<AFBaseTestExecute>.of(multiContexts);
   printTestTotal(output, testKind, baseMultiContexts, localStats);
  stats.mergeIn(localStats);
  return null;
}
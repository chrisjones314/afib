

import 'package:afib/afib_dart.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/af_app.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_prototype_widget_screen.dart';
import 'package:afib/src/flutter/test/af_test_dispatchers.dart';
import 'package:afib/src/flutter/test/af_prototype_single_screen_screen.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/test/af_test_stats.dart';
import 'package:afib/src/flutter/utils/af_flutter_params.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> afScreenTestMain(AFCommandOutput output, AFTestStats stats, AFDartParams paramsD1, AFFlutterParams paramsF, WidgetTester tester) async {
  final isWidget = AFConfigEntries.enabledTestList.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.widgetTests);
  final isAll = AFConfigEntries.enabledTestList.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.screenTests);
  final isSingle = isAll || AFConfigEntries.enabledTestList.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.singleScreenTests);
  final isMulti  = isAll || AFConfigEntries.enabledTestList.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.workflowTests);
  if(!isSingle && !isMulti && !isWidget) {
    return;
  }

  AFibD.config.setValue(AFConfigEntries.widgetTesterContext, AFConfigEntryBool.trueValue);
  final app = AFibF.createApp();
  await tester.pumpWidget(app);

  if(isWidget) {
    await _afWidgetTestMain(output, stats, tester, app);
  }

  if(isSingle) {
    await _afSingleScreenTestMain(output, stats, tester, app);
  }

  if(isMulti) {
    await _afWorkflowTestMain(output, stats, tester, app);
  }

  return null;
}

Future<void> _afStandardScreenTestMain(
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
      AFibF.testOnlyStore.dispatch(createPush(test));
      AFibD.logTest?.d("Starting ${test.id}");

      final screenId = test.screenId;
      final dispatcher = AFSingleScreenTestDispatcher(screenId, AFStoreDispatcher(AFibF.testOnlyStore), null);
      final context = AFScreenTestContextWidgetTester(tester, app, dispatcher, test.id);
      dispatcher.dispatch(AFStartPrototypeScreenTestContextAction(context));
      dispatcher.setContext(context);
      simpleContexts.add(context);

      // tell the store to go to the correct screen.
      await tester.pumpAndSettle(Duration(seconds: 1));

      AFibD.logTest?.d("Finished pumpWidget for ${test.id}");
      //debugDumpApp();
      await test.run(context);
      AFibD.logTest?.d("Finished ${test.id}");

      // pop this test screen off so that we are ready for the next one.
      AFibF.testOnlyStore.dispatch(AFNavigateExitTestAction());
      
      dispatcher.setContext(context);
      await tester.pumpAndSettle(Duration(seconds: 1));
      printTestResult(output, testKind, context, localStats);

    }
  }

  final baseContexts = List<AFBaseTestExecute>.of(simpleContexts);
  printTestTotal(output, testKind, baseContexts, localStats);
  stats.mergeIn(localStats);
}

Future<void> _afWidgetTestMain(AFCommandOutput output, AFTestStats stats, WidgetTester tester, AFApp app) async {
  return _afStandardScreenTestMain(output, stats, tester, app, AFibF.widgetTests.all, "Widget", (test) {
    return AFPrototypeWidgetScreen.navigatePush(test);
  });
}

Future<void> _afSingleScreenTestMain(AFCommandOutput output, AFTestStats stats, WidgetTester tester, AFApp app) async {
  return _afStandardScreenTestMain(output, stats, tester, app, AFibF.screenTests.all, "Single-Screen", (test) {
    return AFPrototypeSingleScreenScreen.navigatePush(test);
  });
}

Future<void> _afWorkflowTestMain(AFCommandOutput output, AFTestStats stats, WidgetTester tester, AFApp app) async {
 final multiContexts = <AFScreenTestContextWidgetTester>[];
  final testKind = "Multi-Screen";
  final localStats = AFTestStats();

  for(final test in AFibF.multiScreenStateTests.stateTests) {
    if(!test.hasBody) {
      continue;
    }
    if(AFConfigEntries.enabledTestList.isTestEnabled(AFibD.config, test.id)) {
      AFibD.logTest?.d("Starting test ${test.id}");

      final dispatcher = AFStoreDispatcher(AFibF.testOnlyStore);
      final context = AFScreenTestContextWidgetTester(tester, app, dispatcher, test.id);
      multiContexts.add(context);

      AFWorkflowStatePrototypeTest.initializeMultiscreenPrototype(dispatcher, test);
      
      // tell the store to go to the correct screen.
      await tester.pumpAndSettle(Duration(seconds: 1));

      AFibD.logTest?.d("Finished pumpWidget for ${test.id}");
      //debugDumpApp();
      await test.body.run(context);
      AFibD.logTest?.d("Finished ${test.id}");

      // pop this test screen off so that we are ready for the next one.
      AFibF.testOnlyStore.dispatch(AFNavigateExitTestAction());
      
      //dispatcher.setContext(context);
      await tester.pumpAndSettle(Duration(seconds: 1));

      /// Clear out our cache of screen info for the next test.
      AFibF.resetTestScreens();
      printTestResult(output, testKind, context, localStats);
    }
  }

  final baseMultiContexts = List<AFBaseTestExecute>.of(multiContexts);
   printTestTotal(output, testKind, baseMultiContexts, localStats);
  stats.mergeIn(localStats);
  return null;
}
import 'package:afib/id.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/dart/redux/actions/af_app_state_actions.dart';
import 'package:afib/src/dart/redux/actions/af_query_actions.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/actions/af_theme_actions.dart';
import 'package:afib/src/dart/redux/queries/af_time_update_listener_query.dart';
import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/redux/state/models/af_time_state.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/af_app.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/test/af_test_dispatchers.dart';
import 'package:afib/src/flutter/test/af_test_stats.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_widget_screen.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> afScreenTestMain<TState extends AFFlexibleState>(AFCommandOutput output, AFTestStats stats, AFDartParams paramsD1, WidgetTester tester) async {
  final isWidget = AFConfigEntries.testsEnabled.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.widgetTests);
  final isSingle = AFConfigEntries.testsEnabled.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.screenTests);
  final isMulti  = AFConfigEntries.testsEnabled.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.workflowTests);
  if(!isSingle && !isMulti && !isWidget) {
    return;
  }

  AFibD.config.setValue(AFConfigEntries.widgetTesterContextKey, true);
  final app = AFibF.g.createApp!();
  await tester.pumpWidget(app);


  AFBaseTestExecute.writeSeparatorLine(output);
  final formFactor = AFibD.config.formFactorWithOrientation;
  output.writeLine("Running at size ${formFactor.summaryText()}"); 

  final locales = AFibF.g.testEnabledLocales(AFibD.config);
    
  for(final locale in locales) {
    AFBaseTestExecute.writeSeparatorLine(output);
    output.writeLine("Running in locale $locale");
    AFibF.g.storeDispatcherInternalOnly!.dispatch(AFOverrideThemeValueAction(
      id: AFUIThemeID.locale,
      value: locale,
    ));            

    if(isWidget) {
      await _afWidgetTestMain<TState>(output, stats, tester, app);
    }

    if(isSingle) {
      await _afSingleScreenTestMain<TState>(output, stats, tester, app);
    }

    if(isMulti) {
      await _afWorkflowTestMain<TState>(output, stats, tester, app);
    }
  }

  return null;
}



Future<void> _afStandardScreenTestMain<TState extends AFFlexibleState>(
  AFCommandOutput output, 
  AFTestStats stats, 
  WidgetTester tester, 
  AFApp app,  
  List<AFScreenPrototype> allPrototypes, 
  String sectionTitle,
  AFTestCreatePushActionDelegate createPush) async {
  final simpleContexts = <AFScreenTestContextWidgetTester>[];
  final testKind = sectionTitle;
  final localStats = AFTestStats();
  for(var prototype in allPrototypes) {
    if(!prototype.hasTests) {
      continue;
    }
    if(AFConfigEntries.testsEnabled.isTestEnabled(AFibD.config, prototype.id)) {
      if(localStats.isEmpty) {
        printTestKind(output, testKind);
      }

      printPrototypeStart(output, prototype.id);
      final startActions = createPush(prototype);
      for(final action in startActions) {
        AFibF.g.storeInternalOnly!.dispatch(action);
      }
      AFibD.logTestAF?.d("Starting ${prototype.id}");
  
      final storeDispatcher = AFStoreDispatcher(AFibF.g.storeInternalOnly!);
      final dispatcher = AFSingleScreenTestDispatcher(prototype.id, storeDispatcher, null);
      final context = AFScreenTestContextWidgetTester(tester, app, dispatcher, prototype.id, output, localStats);
      storeDispatcher.dispatch(AFResetToInitialStateAction());
      dispatcher.dispatch(AFStartPrototypeScreenTestContextAction(context, models: prototype.models, navigate: prototype.navigate, timeHandling: prototype.timeHandling));
      dispatcher.setContext(context);
      simpleContexts.add(context);
      if(prototype.timeHandling == AFTestTimeHandling.running) {
        final resolvedModels = AFibF.g.testData.resolveStateViewModels(prototype.models);
        final baseTime = resolvedModels["AFTimeState"] as AFTimeState?;
        if(baseTime == null) {
          throw AFException("If you set runTime to true in a screen or widget test, one of your models must be an AFTimeState");
        }
        AFibF.g.storeInternalOnly!.dispatch(AFTimeUpdateListenerQuery(baseTime: baseTime));
      }

      // tell the store to go to the correct screen.
      await tester.pumpAndSettle(Duration(seconds: 1));

      output.indent();
      AFibD.logTestAF?.d("Finished pumpWidget for ${prototype.id}");
      await prototype.run(context);
      AFibD.logTestAF?.d("Finished ${prototype.id}");
      output.outdent();
      // pop this test screen off so that we are ready for the next one.
      AFibF.g.storeInternalOnly!.dispatch(AFNavigateExitTestAction());
      if(prototype.timeHandling == AFTestTimeHandling.running) {
        AFibF.g.storeInternalOnly!.dispatch(AFShutdownOngoingQueriesAction());
      }
      
      dispatcher.setContext(context);
      await tester.pumpAndSettle(Duration(seconds: 1));
    }
  }

  AFibF.g.storeInternalOnly!.dispatch(AFResetTestState());
  final baseContexts = List<AFBaseTestExecute>.of(simpleContexts);
  printTestTotal(output, baseContexts, localStats);
  stats.mergeIn(localStats);
}

Future<void> _afWidgetTestMain<TState extends AFFlexibleState>(AFCommandOutput output, AFTestStats stats, WidgetTester tester, AFApp app) async {
  return _afStandardScreenTestMain<TState>(output, stats, tester, app, AFibF.g.widgetTests.all, "Widget", (test) {
    return [
      AFStartPrototypeScreenTestAction(test, navigate: test.navigate, models: test.models),
      AFUIPrototypeWidgetScreen.navigatePush(test as AFWidgetPrototype)
    ];
  });
}

Future<void> _afSingleScreenTestMain<TState extends AFFlexibleState>(AFCommandOutput output, AFTestStats stats, WidgetTester tester, AFApp app) async {
  return _afStandardScreenTestMain<TState>(output, stats, tester, app, AFibF.g.screenTests.all, "Single-Screen", (test) {
    final stateViews = AFibF.g.testData.resolveStateViewModels(test.models);
    return [
      AFStartPrototypeScreenTestAction(test, navigate: test.navigate, models: stateViews),
      AFNavigatePushAction(
        routeParam: test.navigate.param,
        children: test.navigate.children,
      )
    ];
  });
}

Future<void> _afWorkflowTestMain<TState extends AFFlexibleState>(AFCommandOutput output, AFTestStats stats, WidgetTester tester, AFApp app) async {
 final multiContexts = <AFScreenTestContextWidgetTester>[];
  final testKind = "Workflow";
  final localStats = AFTestStats();

  for(final test in AFibF.g.workflowTests.stateTests) {
    if(!test.hasTests) {
      continue;
    }
    if(AFConfigEntries.testsEnabled.isTestEnabled(AFibD.config, test.id)) {
      if(localStats.isEmpty) {
        printTestKind(output, testKind);
      }

      printPrototypeStart(output, test.id);
      output.indent();
      AFibD.logTestAF?.d("Starting test ${test.id}");
      final dispatcher = AFStoreDispatcher(AFibF.g.storeInternalOnly!);
      final context = AFScreenTestContextWidgetTester(tester, app, dispatcher, test.id, output, localStats);
      multiContexts.add(context);

      AFWorkflowStatePrototype.initializeMultiscreenPrototype<TState>(dispatcher, test);
      
      // tell the store to go to the correct screen.
      await tester.pumpAndSettle(Duration(seconds: 1));

      AFibD.logTestAF?.d("Finished pumpWidget for ${test.id}");
      await test.body.run(context);
      AFibD.logTestAF?.d("Finished ${test.id}");

      // pop this test screen off so that we are ready for the next one.
      AFibF.g.storeInternalOnly!.dispatch(AFNavigateExitTestAction());
      AFibF.g.storeInternalOnly!.dispatch(AFShutdownOngoingQueriesAction());
      
      //dispatcher.setContext(context);
      await tester.pumpAndSettle(Duration(seconds: 1));

      /// Clear out our cache of screen info for the next test.
      AFibF.g.resetTestScreens();

      output.outdent();
    }
  }

  final baseMultiContexts = List<AFBaseTestExecute>.of(multiContexts);
   printTestTotal(output, baseMultiContexts, localStats);
  stats.mergeIn(localStats);
  return null;
}
import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/dart/redux/actions/af_app_state_actions.dart';
import 'package:afib/src/dart/redux/actions/af_query_actions.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/actions/af_theme_actions.dart';
import 'package:afib/src/dart/redux/queries/af_time_update_listener_query.dart';
import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/redux/state/models/af_route_state.dart';
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
import 'package:afib/src/flutter/ui/screen/afui_prototype_bottomsheet_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_dialog_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_drawer_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_prototype_widget_screen.dart';
import 'package:afib/src/flutter/utils/af_api_mixins.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> afScreenTestMain(AFCommandOutput output, AFTestStats stats, AFDartParams paramsD1, WidgetTester tester) async {
  final isWidget = AFConfigEntries.testsEnabled.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.widgetTests);
  final isSingle = AFConfigEntries.testsEnabled.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.screenTests);
  final isMulti  = AFConfigEntries.testsEnabled.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.workflowTests);
  final isDialog = AFConfigEntries.testsEnabled.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.dialogTests);
  final isDrawer = AFConfigEntries.testsEnabled.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.drawerTests);
  final isBottomSheet = AFConfigEntries.testsEnabled.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.bottomSheetTests);
  if(!isSingle && !isMulti && !isWidget && !isDialog && !isBottomSheet && !isDrawer) {
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
    AFibF.g.internalOnlyActiveDispatcher.dispatch(AFOverrideThemeValueAction(
      id: AFUIThemeID.locale,
      value: locale,
    ));            

    if(isWidget) {
      await _afWidgetTestMain(output, stats, tester, app);
    }

    if(isDialog) {
      await _afDialogTestMain(output, stats, tester, app);
    }

    if(isBottomSheet) {
      await _afBottomSheetTestMain(output, stats, tester, app);
    }

    if(isDrawer) {
      await _afDrawerTestMain(output, stats, tester, app);
    }

    if(isSingle) {
      await _afSingleScreenTestMain(output, stats, tester, app);
    }

    if(isMulti) {
      await _afWorkflowTestMain(output, stats, tester, app);
    }
  }

  return null;
}



Future<void> _afStandardScreenTestMain(
  AFCommandOutput output, 
  AFTestStats stats, 
  WidgetTester tester, 
  AFApp app,  
  List<AFScreenPrototype> allPrototypes, 
  String sectionTitle, {
    required AFTestCreatePushActionDelegate createPush,
    Future<void> Function(AFDispatcher dispatcher, AFScreenPrototype prototype)? showItem
  }) async {
  final simpleContexts = <AFScreenTestContextWidgetTester>[];
  final testKind = sectionTitle;
  final localStats = AFTestStats();
  var printHeader = true;
  for(var prototype in allPrototypes) {
    if(!prototype.hasTests) {
      continue;
    }
    if(AFConfigEntries.testsEnabled.isTestEnabled(AFibD.config, prototype.id)) {
      if(printHeader) {
        printTestKind(output, testKind);
        printHeader = false;
      }

      printPrototypeStart(output, prototype.id);
      final startActions = createPush(prototype);
      for(final action in startActions) {
        AFibF.g.internalOnlyActiveStore.dispatch(action);
      }
      AFibD.logTestAF?.d("Starting ${prototype.id}");
  
      final storeDispatcher = AFStoreDispatcher(AFibF.g.internalOnlyActiveStore);
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
        AFibF.g.internalOnlyActiveStore.dispatch(AFTimeUpdateListenerQuery(baseTime: baseTime));
      }

      // tell the store to go to the correct screen.
      await tester.pumpAndSettle(Duration(seconds: 1));

      if(showItem != null) {
        await showItem(dispatcher, prototype);
        await tester.pumpAndSettle(Duration(seconds: 1));
      }

      output.indent();
      AFibD.logTestAF?.d("Finished pumpWidget for ${prototype.id}");
      await prototype.run(context);
      AFibD.logTestAF?.d("Finished ${prototype.id}");
      output.outdent();
      // pop this test screen off so that we are ready for the next one.
      AFibF.g.internalOnlyActiveStore.dispatch(AFNavigateExitTestAction());
      if(prototype.timeHandling == AFTestTimeHandling.running) {
        AFibF.g.internalOnlyActiveStore.dispatch(AFShutdownOngoingQueriesAction());
      }
      
      dispatcher.setContext(context);
      await tester.pumpAndSettle(Duration(seconds: 1));
    }
  }

  AFibF.g.internalOnlyActiveStore.dispatch(AFResetTestState());
  final baseContexts = List<AFBaseTestExecute>.of(simpleContexts);
  printTestTotal(output, baseContexts, localStats);
  stats.mergeIn(localStats);
}

Future<void> _afWidgetTestMain(AFCommandOutput output, AFTestStats stats, WidgetTester tester, AFApp app) async {
  return _afStandardScreenTestMain(output, stats, tester, app, AFibF.g.widgetTests.all, "Widget", createPush: (test) {
    return [
      AFUpdateActivePrototypeAction(prototypeId: test.id),
      AFStartPrototypeScreenTestAction(test, navigate: test.navigate, models: test.models),
      AFUIPrototypeWidgetScreen.navigatePush(test as AFWidgetPrototype)
    ];
  });
}

Future<void> _afDialogTestMain(AFCommandOutput output, AFTestStats stats, WidgetTester tester, AFApp app) async {
  return _afStandardScreenTestMain(output, stats, tester, app, AFibF.g.dialogTests.all, "Dialog", createPush: (test) {
    return [
      AFUpdateActivePrototypeAction(prototypeId: test.id),
      AFStartPrototypeScreenTestAction(test, navigate: test.navigate, models: test.models),
      AFUIPrototypeDialogScreen.navigatePush(test as AFDialogPrototype)
    ];
  }, showItem: (dispatcher, test) async {
    final buildContext = AFibF.g.testOnlyShowBuildContext(AFUIType.dialog);
    assert(buildContext != null);

    // show the dialog, but don't wait it, because it won't return until the dialog is closed.
    AFContextShowMixin.showDialogStatic(
        dispatch: dispatcher.dispatch,
        navigate: test.navigate,
        flutterContext: buildContext,
    );
  });
}

Future<void> _afBottomSheetTestMain(AFCommandOutput output, AFTestStats stats, WidgetTester tester, AFApp app) async {
  return _afStandardScreenTestMain(output, stats, tester, app, AFibF.g.bottomSheetTests.all, "BottomSheet", createPush: (test) {
    return [
      AFUpdateActivePrototypeAction(prototypeId: test.id),
      AFStartPrototypeScreenTestAction(test, navigate: test.navigate, models: test.models),
      AFUIPrototypeBottomSheetScreen.navigatePush(test as AFBottomSheetPrototype)
    ];
  }, showItem: (dispatcher, test) async {
    final buildContext = AFibF.g.testOnlyShowBuildContext(AFUIType.bottomSheet);
    assert(buildContext != null);

    // show the dialog, but don't wait it, because it won't return until the dialog is closed.
    AFContextShowMixin.showModalBottomSheetStatic(
        dispatch: dispatcher.dispatch,
        navigate: test.navigate,
        flutterContext: buildContext,
    );
  });
}

Future<void> _afDrawerTestMain(AFCommandOutput output, AFTestStats stats, WidgetTester tester, AFApp app) async {
  return _afStandardScreenTestMain(output, stats, tester, app, AFibF.g.drawerTests.all, "Drawer", createPush: (test) {
    return [
      AFUpdateActivePrototypeAction(prototypeId: test.id),
      AFStartPrototypeScreenTestAction(test, navigate: test.navigate, models: test.models),
      AFUIPrototypeDrawerScreen.navigatePush(test as AFDrawerPrototype)
    ];
  }, showItem: (dispatcher, test) async {
    final buildContext = AFibF.g.testOnlyShowBuildContext(AFUIType.drawer);
    assert(buildContext != null);

    // show the dialog, but don't wait it, because it won't return until the dialog is closed.
    AFContextShowMixin.showDrawerStatic(
        dispatch: dispatcher.dispatch,
        navigate: test.navigate,
        flutterContext: buildContext,
    );
  });
}

Future<void> _afSingleScreenTestMain(AFCommandOutput output, AFTestStats stats, WidgetTester tester, AFApp app) async {
  return _afStandardScreenTestMain(output, stats, tester, app, AFibF.g.screenTests.all, "Single-Screen", createPush: (test) {
    final stateViews = AFibF.g.testData.resolveStateViewModels(test.models);
    return [
      AFUpdateActivePrototypeAction(prototypeId: test.id),
      AFStartPrototypeScreenTestAction(test, navigate: test.navigate, models: stateViews),
      AFNavigatePushAction(
        param: test.navigate.param,
        children: test.navigate.children,
        createDefaultChildParam: test.navigate.createDefaultChildParam,
      )
    ];
  });
}

Future<void> _afWorkflowTestMain(AFCommandOutput output, AFTestStats stats, WidgetTester tester, AFApp app) async {
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
      final dispatcher = AFStoreDispatcher(AFibF.g.internalOnlyActiveStore);
      final context = AFScreenTestContextWidgetTester(tester, app, dispatcher, test.id, output, localStats);
      multiContexts.add(context);

      AFWorkflowStatePrototype.initializeMultiscreenPrototype(dispatcher, test);
      
      // tell the store to go to the correct screen.
      await tester.pumpAndSettle(Duration(seconds: 1));

      AFibD.logTestAF?.d("Finished pumpWidget for ${test.id}");
      await test.body.run(context);
      AFibD.logTestAF?.d("Finished ${test.id}");

      // pop this test screen off so that we are ready for the next one.
      AFibF.g.internalOnlyActiveStore.dispatch(AFNavigateExitTestAction());
      AFibF.g.internalOnlyActiveStore.dispatch(AFShutdownOngoingQueriesAction());
      
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
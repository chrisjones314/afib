

import 'package:afib/afib_dart.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_test_dispatchers.dart';
import 'package:afib/src/flutter/test/af_simple_prototype_screen.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_actions.dart';
import 'package:afib/src/flutter/test/af_test_stats.dart';
import 'package:afib/src/flutter/utils/af_flutter_params.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> afScreenTestMain(AFCommandOutput output, AFTestStats stats, AFDartParams paramsD1, AFFlutterParams paramsF, WidgetTester tester) async {
  if(!AFConfigEntries.enabledTestList.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.screenTests)) {
    return;
  }

  AFibD.config.setValue(AFConfigEntries.widgetTesterContext, AFConfigEntryBool.trueValue);
  final app = AFibF.createApp();
  await tester.pumpWidget(app);

  final contexts = List<AFScreenTestContextWidgetTester>();


  for(var group in AFibF.screenTests.groups) {
    for(var test in group.simpleTests) {
      if(!test.hasBody) {
        continue;
      }
      if(AFConfigEntries.enabledTestList.isTestEnabled(AFibD.config, test.id)) {
        AFibF.testOnlyStore.dispatch(AFScreenPrototypeScreen.navigatePush(test));
        AFibD.logInternal?.fine("Starting ${test.id}");

        final screenId = test.screenId;
        final dispatcher = AFSimpleScreenTestDispatcher(screenId, AFStoreDispatcher(AFibF.testOnlyStore), null);
        final context = AFScreenTestContextWidgetTester(tester, app, dispatcher, test);
        dispatcher.dispatch(AFStartPrototypeScreenTestContextAction(context));
        dispatcher.setContext(context);
        contexts.add(context);

        // tell the store to go to the correct screen.
        await tester.pumpAndSettle(Duration(seconds: 1));
  
        AFibD.logInternal?.fine("Finished pumpWidget for ${test.id}");
        //debugDumpApp();
        await test.body.run(context, null);
        AFibD.logInternal?.fine("Finished ${test.id}");

        // pop this test screen off so that we are ready for the next one.
        AFibF.testOnlyStore.dispatch(AFNavigatePopAction());
        
        dispatcher.setContext(context);
        await tester.pumpAndSettle(Duration(seconds: 1));
      }
    }
  }

  final baseContexts = List<AFBaseTestExecute>.of(contexts);
  printTestResults(output, "Screen", baseContexts, stats);
}
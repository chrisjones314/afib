

import 'package:afib/src/dart/redux/actions/af_app_state_actions.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/af.dart';
import 'package:afib/src/flutter/test/af_scenario_instance_screen.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:flutter_test/flutter_test.dart';

void afScreenTestMain(WidgetTester tester) {
  AF.screenTests.screens.forEach((AFScreenTest test){
    test.tests.forEach((AFScreenTestData instance) async {
      final context = AFScreenTestContextWidgetTester(tester, test, instance);

      // tell the store to go to the correct screen.
      AF.testOnlyStore.dispatch(AFResetToInitialStateAction());
      AF.testOnlyStore.dispatch(AFScenarioInstanceScreen.navigatePush(instance));
      AF.testOnlySetForcedStartupScreen(AFUIID.screenPrototypeInstance);

      final app = AF.createApp();
      await tester.pumpWidget(app);
      instance.body(context);
    });
  });
}



import 'package:afib/src/dart/redux/actions/af_app_state_actions.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/af.dart';
import 'package:afib/src/flutter/test/af_screen_test_screen.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> afScreenTestMain(WidgetTester tester) async {
  for(var group in AF.screenTests.groups) {
    for(var test in group.tests) {
      final context = AFScreenTestContextWidgetTester(tester, test);
      if(!test.hasBody) {
        continue;
      }

      // tell the store to go to the correct screen.
      AF.testOnlyStore.dispatch(AFResetToInitialStateAction());
      AF.testOnlyStore.dispatch(AFScreenTestInstanceScreen.navigatePush(test));
      AF.testOnlySetForcedStartupScreen(AFUIID.screenPrototypeInstance);

      final app = AF.createApp();
      await tester.pumpWidget(app);
      test.body.run(context);
    }
  }
}
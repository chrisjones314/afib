

import 'package:afib/afib_dart.dart';
import 'package:afib/src/flutter/af.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_prototype_dispatcher.dart';
import 'package:afib/src/flutter/test/af_simple_prototype_screen.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> afScreenTestMain(WidgetTester tester) async {
  AF.config.setBool(AFConfigConstants.widgetTesterContext, true);
  final app = AF.createApp();
  await tester.pumpWidget(app);

  for(var group in AF.screenTests.groups) {
    for(var test in group.tests) {
      //AF.testOnlyStore.dispatch(AFResetToInitialStateAction());
      AF.testOnlyStore.dispatch(AFScreenPrototypeScreen.navigatePush(test));
      AF.internal?.fine("Starting ${test.id}");

      final screenId = test.widget.screen;
      final dispatcher = AFPrototypeDispatcher(screenId, AFStoreDispatcher(AF.testOnlyStore), null);
      final context = AFScreenTestContextWidgetTester(tester, app, test, dispatcher);
      if(!test.hasBody) {
        continue;
      }

      // tell the store to go to the correct screen.
      await tester.pumpAndSettle();
 
      AF.internal?.fine("Finished pumpWidget for ${test.id}");
      final params = AFTestSectionParams();
      //debugDumpApp();
      await test.body.run(context, params);
      AF.internal?.fine("Finished ${test.id}");

      // pop this test screen off so that we are ready for the next one.
      AF.testOnlyStore.dispatch(AFNavigatePopAction());
      await tester.pumpAndSettle();

    }
  }
}
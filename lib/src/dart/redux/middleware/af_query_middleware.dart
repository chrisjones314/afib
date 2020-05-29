

import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_state_test.dart';
import 'package:redux/redux.dart';

class AFQueryMiddleware implements MiddlewareClass<AFState>
{
  @override
  dynamic call(Store<AFState> store, dynamic query, NextDispatcher next) {
    if (query is AFAsyncQuery) {

      AFStateTestContext testContext = AFStateTestContext.currentTest;
      if(testContext != null) {
        testContext.processQuery(query);
      } else {
        query.startAsyncAF(
          AFStoreDispatcher(store),
          store.state
        );
      }
    }
    next(query);
  }
}

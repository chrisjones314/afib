

import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/actions/af_deferred_query.dart';
import 'package:afib/src/dart/redux/actions/af_wait_query.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_state_test.dart';
import 'package:redux/redux.dart';

class AFQueryMiddleware implements MiddlewareClass<AFState>
{
  @override
  dynamic call(Store<AFState> store, dynamic query, NextDispatcher next) {
    if (query is AFAsyncQueryCustomError) {

      // keep track of listener queries so we can shut them down at the end.
      if(query is AFAsyncQueryListenerCustomError) {
        AFibF.registerListenerQuery(query);
      }

      if(query is AFDeferredQueryCustomError) {
        AFibF.registerDeferredQuery(query);
      }

      if(query is AFWaitQuery) {
        AFibF.registerWaitQuery(query);
      }

      AFStateTestContext testContext = AFStateTestContext.currentTest;
      if(testContext != null) {
        testContext.processQuery(query);
      } else {
        query.startAsyncAF(
          AFStoreDispatcher(store),
          store
        );
      }
    }
    next(query);
  }
}

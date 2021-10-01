import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/actions/af_deferred_query.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/flutter/test/af_state_test.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:redux/redux.dart';

class AFQueryMiddleware implements MiddlewareClass<AFState>
{
  @override
  dynamic call(Store<AFState> store, dynamic query, NextDispatcher next) {
    if (query is AFAsyncQuery) {

      // keep track of listener queries so we can shut them down at the end.
      if(query is AFAsyncQueryListener) {
        AFibF.g.registerListenerQuery(query);
      }

      if(query is AFDeferredQuery) {
        AFibF.g.registerDeferredQuery(query);
      }

      final testContext = AFStateTestContext.currentTest;
      if(testContext != null) {
        testContext.processQuery(query);
      } else {
        query.startAsyncAF(
          AFStoreDispatcher(store as AFStore),
          store
        );
      }
    }
    next(query);
  }
}

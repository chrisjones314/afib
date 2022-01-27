import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/actions/af_deferred_query.dart';
import 'package:afib/src/dart/redux/actions/af_query_actions.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/flutter/test/af_state_test.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:redux/redux.dart';

class AFQueryMiddleware implements MiddlewareClass<AFState>
{
  @override
  dynamic call(Store<AFState> store, dynamic query, NextDispatcher next) {
    if (query is AFAsyncQuery) {
      // keep track of listener queries so we can shut them down at the end.
      if(query is AFAsyncListenerQuery) {
        next(AFRegisterListenerQueryAction(query));
      }

      if(query is AFDeferredQuery) {
        next(AFRegisterDeferredQueryAction(query));
      }

      final testContext = AFStateTestContext.currentTest;
      if(testContext != null) {
        testContext.processQuery(query);
        return;
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

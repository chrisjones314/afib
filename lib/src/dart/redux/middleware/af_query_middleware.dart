import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/actions/af_deferred_query.dart';
import 'package:afib/src/dart/redux/actions/af_query_actions.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/flutter/test/af_state_test.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:redux/redux.dart';

class AFQueryMiddleware implements MiddlewareClass<AFState>
{
  @override
  dynamic call(Store<AFState> store, dynamic query, NextDispatcher next) {
    if (query is AFAsyncQuery) {
      // keep track of listener queries so we can shut them down at the end.
      _registerQuery(query, next);

      if(query is AFConsolidatedQuery) {
        for(final subQuery in query.allQueries) {
          _registerQuery(subQuery, next);
        }
      }
      final entry = AFibF.g.internalOnlyStoreEntry(query.conceptualStore);

      final testContext = AFStateTestContext.currentTest ?? AFibF.g.demoModeTest;
      if(testContext != null) {
        testContext.processQuery(query, entry.store!, entry.dispatcher!);
        return;
      } else {

        query.startAsyncAF(
          entry.dispatcher!,
          entry.store!
        );
      }
    }
    next(query);
  }

  void _registerQuery(AFAsyncQuery query, NextDispatcher next) {
    if(query is AFAsyncListenerQuery) {
      next(AFRegisterListenerQueryAction(query));
    }

    if(query is AFDeferredQuery) {
      next(AFRegisterDeferredQueryAction(query));
    }
  }
}

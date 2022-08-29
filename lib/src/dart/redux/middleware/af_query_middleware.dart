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
      final entry = AFibF.g.internalOnlyStoreEntry(query.conceptualStore);

      // keep track of listener queries so we can shut them down at the end.
      if(!_registerQuery(entry, query, next)) {
        return;
      }

      if(query is AFCompositeQuery) {
        for(final subQuery in query.allQueries) {
          _registerQuery(entry, subQuery, next);
        }
      }


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

  bool _registerQuery(AFibStoreStackEntry entry, AFAsyncQuery query, NextDispatcher next) {
    if(query is! AFTrackedQuery) {
      return true;
    }

    final merged = _mergeTracked(entry.store!.state.public, query);
    if(merged == null) {
      return false;
    }

    if(query is AFAsyncListenerQuery) {
      next(AFRegisterListenerQueryAction(merged as AFAsyncListenerQuery));
    }

    if(query is AFDeferredQuery) {
      next(AFRegisterDeferredQueryAction(merged as AFDeferredQuery));
    }

    if(query is AFPeriodicQuery) {
      next(AFRegisterPeriodicQueryAction(merged as AFPeriodicQuery));
    }

    return true;
  }

  AFTrackedQuery? _mergeTracked(AFPublicState public, AFAsyncQuery query) {
    if(query is! AFTrackedQuery) {
      assert(false);
      return null;
    }

    final newTracked = query as AFTrackedQuery;

    final existing = public.queries.findTrackedByQueryId(query.key);
    if(existing == null) {
      return query as AFTrackedQuery;
    }

    final merged = newTracked.mergeOnWrite(existing);
    if(merged == existing) {
      return null;
    }

    return merged;
  }
}

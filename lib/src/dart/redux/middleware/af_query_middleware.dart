

import 'package:afib/src/dart/redux/actions/af_async_query_action.dart';
import 'package:afib/src/dart/redux/middleware/af_async_queries.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/flutter/af.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:redux/redux.dart';

class AFQueryMiddleware<Action extends AFAsyncQueryAction> implements MiddlewareClass<AFState>
{
  @override
  dynamic call(Store<AFState> store, dynamic action, NextDispatcher next) {
    if (action is AFAsyncQueryAction) {
      AFAsyncQueries queries = AF.asyncQueries;
      queries.queries.forEach((query) {
        if(action is Action) {
          query.startAsyncAF(
            AFStoreDispatcher(store),
            store.state,
            next
          );
        }
      });
    } else {
      return next(action);
    }
  }
}


import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_query_error.dart';
import 'package:afib/src/dart/utils/af_unused.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';

/// A query that waits on the completion of one or more other queries before executing.
abstract class AFWaitQuery<TState> extends AFAsyncQueryCustomError<TState, AFUnused, AFQueryError>  {
  final needed = Map<String, bool>();

  /// Construct a query with the specified id which will wait on queries specified by [requireCompletionOf].
  /// 
  /// You should always construct and dispatch a wait query prior to dispatching the queries it is waiting on.
  /// 
  /// If a wait query is dispatched with [id], and another wait query is dispatched with the same id prior
  /// to the completion of the first, the original query will be retained, and will wait on all its original
  /// required queries, plus all those of the second required query.  For this reason, you should always specify an ID for wait queries.
  AFWaitQuery(AFID id): super(id: id);

  /// Called when all the queries you are waiting on have completed.
  void finishAsyncExecute(AFDispatcher dispatcher, TState state);

  /// Indicate that this query should not execute until the specified query completes.
  void requireCompletionOf(AFAsyncQueryCustomError query) {
    needed[query.key] = true;
    AFibD.logInternal?.fine("Wait query $key now needs ${query.key}");
  }

  void dispatchAll(AFDispatcher dispatcher) {
    dispatcher.dispatch(this);
    // TODO: Dispatch all the queries we are waiting for.
  }


  /// Used by the framework when one wait query with a given id is already active.
  void mergeIn(AFWaitQuery other) {
    other.needed.forEach((queryKey, need) {
      needed[queryKey] = need;
      if(need) {
        AFibD.logInternal?.fine("Wait query $key now needs ${queryKey}");
      }
    });
  }


  bool doesComplete(AFAsyncQueryCustomError query) {
    final queryKey = query.key;
    if(needed.containsKey(queryKey)) {
      needed[queryKey] = false;
    }
    bool finished = allFinished;
    if(AFibD.logInternal != null) {
      if(finished) {
        AFibD.logInternal.fine("wait query $key is completed by ${query.key}");
      } else {
        needed.forEach((waitKey, need) { 
          if(need) {
            AFibD.logInternal.fine("wait query $key still needs $waitKey");
          }
        });
      }
    }
    return finished;
  }

  bool get allFinished {
    for(bool need in needed.values) {
      if(need) {
        return false;
      }
    }
    return true;
  }

  @override
  void finishAsyncWithError(AFDispatcher dispatcher, TState state, AFQueryError error) {
  }
  
  @override
  void finishAsyncWithResponse(AFDispatcher dispatcher, TState state, AFUnused response) {
    throw UnimplementedError();
  }

  @override
  void startAsync(Function(AFUnused) onResponse, Function(AFQueryError) onError) {
    //onR = onResponse;
    //onE = onE;
  }

}
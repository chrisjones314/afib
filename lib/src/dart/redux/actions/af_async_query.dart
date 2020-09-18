


import 'dart:async';

import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_query_error.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_state_test.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';


typedef void AFOnResponseDelegate<TState, TResponse>(TState state, TResponse response);
typedef void AFOnErrorDelegate<TState, TError>(TState state, TError error);

/// Superclass for a kind of action that queries some data asynchronously, then knows
/// how to process the result.
abstract class AFAsyncQueryCustomError<TState, TResponse, TError> extends AFActionWithKey {
  final List<dynamic> successActions;
  final AFOnResponseDelegate<TState, TResponse> onSuccessDelegate;
  final AFOnErrorDelegate<TState, TError> onErrorDelegate;

  AFAsyncQueryCustomError({AFID id, this.onSuccessDelegate, this.onErrorDelegate, this.successActions}): super(id: id);

  /// Called internally when redux middleware begins processing a query.
  void startAsyncAF(AFDispatcher dispatcher, AFStore store, { Function(dynamic) onResponseExtra, Function(dynamic) onErrorExtra }) {
    AFibD.logQuery?.d("Starting query: $this");
    startAsync( (TResponse result) { 
      // note: there could be multiple queries outstanding at once, meaning the state
      // might be changed by some other query while we are waiting for a responser.  
      // Consequently, it is important not to make a copy of the state above this point,
      // as it might go out of date.
      finishAsyncWithResponseAF(dispatcher, store.state.app, result);
      if(onResponseExtra != null) {
        onResponseExtra(result);
      }
    }, (TError error) {
      finishAsyncWithErrorAF(dispatcher, store.state.app, error);
      if(onErrorExtra != null) {
        onErrorExtra(error);
      }
    });
  }

  /// Called internally by the framework to do pre and post processing before [finishAsyncWithResponse]
  void finishAsyncWithResponseAF(AFDispatcher dispatcher, TState state, TResponse response) {
    finishAsyncWithResponse(dispatcher, state, response);
    AFibF.handleFinishWithResponse(this, dispatcher, state);
    if(onSuccessDelegate != null) {
      onSuccessDelegate(state, response);
    }
    if(successActions != null) {
      for(final act in successActions) {
        dispatcher.dispatch(act);
      }
    }
  }

  void finishAsyncWithErrorAF(AFDispatcher dispatcher, TState state, TError error) {
    finishAsyncWithError(dispatcher, state, error);
    AFibF.handleFinishWithError(this, dispatcher, state);
    if(onErrorDelegate != null) {
      onErrorDelegate(state, error);
    }
  }

  /// Called at the start of an asynchronous process, starts the query using data from the
  /// command. 
  /// 
  /// The implementation should call either [onResponse] or [onError], which will in turn
  /// call [finishAsyncWithResult] or [finishAsyncWithError].
  void startAsync(Function(TResponse) onResponse, Function(TError) onError);

  /// Called when the asynchronous process completes with a response  It should merge the results 
  /// into the state (preserving immutability by making copies of the relevant portions of the state using copyWith), 
  /// and then use the dispatcher to call set actions for any modified 
  /// state elements.
  void finishAsyncWithResponse(AFDispatcher dispatcher, TState state, TResponse response);

  
  void finishAsyncWithError(AFDispatcher dispatcher, TState state, TError error);

  /// Called during testing to simulate results from an asynchronous call.
  void testFinishAsyncWithResponse(AFStateTestContext context, TResponse response) {
    finishAsyncWithResponseAF(context.dispatcher, context.state, response);
  }

  /// Called during testing to simulate results from an asynchronous call.
  void testFinishAsyncWithError(AFStateTestContext context, TError error) {
    finishAsyncWithErrorAF(context.dispatcher, context.state, error);
  }

}

/// A default version of [AFAsyncQueryCustomError] with the standard [AFQueryError] type, which is sufficient
/// in most cases.
abstract class AFAsyncQuery<TState, TResponse> extends AFAsyncQueryCustomError<TState, TResponse, AFQueryError> {
  AFAsyncQuery({AFID id, List<dynamic> successActions, AFOnResponseDelegate<TState, TResponse> onSuccessDelegate, AFOnErrorDelegate<TState, AFQueryError> onErrorDelegate}): 
    super(id: id, successActions: successActions, onSuccessDelegate: onSuccessDelegate, onErrorDelegate: onErrorDelegate);
}

class AFConsolidatedQueryEntry {
  static const int statusNone    = 0;
  static const int statusError   = 1;
  static const int statusSuccess = 2;

  final AFAsyncQuery query;
  int status;
  dynamic result;

  AFConsolidatedQueryEntry(this.query, this.status);

  factory AFConsolidatedQueryEntry.createFrom(AFAsyncQuery query) {
    return AFConsolidatedQueryEntry(query, statusNone);
  }

  bool get isIncomplete { 
    return status == statusNone;
  }

  bool get isError { 
    return status == statusError;
  }

  void completeResponse(dynamic response) {
    status = statusSuccess;
    result = response;
  }

  void completeError(dynamic err) {
    status = statusError;
    result = err;
  }
}

class AFConsolidatedQueryResponse {
  final List<AFConsolidatedQueryEntry> responses;

  AFConsolidatedQueryResponse(this.responses);

  factory AFConsolidatedQueryResponse.createFrom(List<AFAsyncQuery> queries) {
    final list = queries.map( (query) => AFConsolidatedQueryEntry.createFrom(query));
    return AFConsolidatedQueryResponse(List<AFConsolidatedQueryEntry>.of(list));
  }

  bool get isComplete {
    final foundIncomplete = responses.firstWhere( (response) => response.isIncomplete, orElse: () => null);
    return foundIncomplete == null;
  }

  bool get hasError {
    final foundError = responses.firstWhere( (response) => response.isError, orElse: () => null);
    return foundError != null;
  }
}

class AFConsolidatedQuery<TState> extends AFAsyncQuery<TState, AFConsolidatedQueryResponse> {
  static const queryFailedCode = 792;
  static const queryFailedMessage = "At least one query in a consolidated query failed.";

  final AFConsolidatedQueryResponse queryResponses;

  AFConsolidatedQuery(this.queryResponses, {AFID id, AFOnResponseDelegate<TState, AFConsolidatedQueryResponse> onSuccessDelegate, AFOnErrorDelegate<TState, AFQueryError> onErrorDelegate, List<dynamic> successActions}):
    super(id: id, onSuccessDelegate: onSuccessDelegate, onErrorDelegate: onErrorDelegate, successActions: successActions);

  factory AFConsolidatedQuery.createFrom({
    List<AFAsyncQuery> queries,
    List<dynamic> successActions,
    AFOnResponseDelegate<TState, AFConsolidatedQueryResponse> onSuccessDelegate,
    AFOnErrorDelegate<TState, AFQueryError> onErrorDelegate
  }) {
    final response = AFConsolidatedQueryResponse.createFrom(queries);
    return AFConsolidatedQuery(response,
      onSuccessDelegate: onSuccessDelegate,
      onErrorDelegate: onErrorDelegate,
      successActions: successActions);
  }

  void startAsyncAF(AFDispatcher dispatcher, AFStore store, { Function(dynamic) onResponseExtra, Function(dynamic) onErrorExtra }) {
      final completer = Completer<bool>();

      // start all the queries asynchronously.
      for(final queryResponse in queryResponses.responses) {
        final query = queryResponse.query;
        query.startAsyncAF(dispatcher, store, 
          onResponseExtra: (dynamic localResponse) {
            queryResponse.completeResponse(localResponse);
            if(queryResponses.isComplete) {
              completer.complete(true);
            }

          },
          onErrorExtra: (dynamic error) {
            queryResponse.completeError(error);
            if(queryResponses.isComplete) {
              completer.complete(true);
            }
          }
        );
      }

      // when they have all completed, then process our response.
      completer.future.then((_) {
        if(queryResponses.hasError) {
          finishAsyncWithErrorAF(dispatcher, store.state.app, AFQueryError(code: queryFailedCode, message: queryFailedMessage));
        } else {
          finishAsyncWithResponseAF(dispatcher, store.state.app, queryResponses);
        }
      });
  }

  /// This function will not be called in this variant, so overriding it is useless.
  void startAsync(Function(AFConsolidatedQueryResponse) onResponse, Function(AFQueryError) onError) {
    throw UnimplementedError();
  }

  /// By default, does nothing.
  /// 
  /// You can override this in your own subclass if you want, but many uses cases 
  /// are adequately covered by passing onSuccessDelegate or successActions to the constructor.
  void finishAsyncWithResponse(AFDispatcher dispatcher, TState state, AFConsolidatedQueryResponse response) {

  }

  
  /// By default, does nothing.
  /// 
  /// You can override this in your own subclass if you want, but many uses cases 
  /// are adequately covered by passing onSuccessDelegate or successActions to the constructor.
  void finishAsyncWithError(AFDispatcher dispatcher, TState state, AFQueryError error) {

  }



}

/// A version of [AFAsyncQueryCustomError] for queries that have some kind of ongoing
/// connection or state that needs to be shutdown.  
/// 
/// Afib will automatically track these queries when you dispatch them.  You can dispatch the
/// [AFShutdownQueryListeners] action to call the shutdown method on some or all outstanding
/// listeners.  
abstract class AFAsyncQueryListenerCustomError<TState, TResponse, TError> extends AFAsyncQueryCustomError<TState, TResponse, TError> {
  AFAsyncQueryListenerCustomError({AFID id, List<dynamic> successActions, AFOnResponseDelegate<TState, TResponse> onSuccessDelegate, AFOnErrorDelegate<TState, AFQueryError> onErrorDelegate}): super(id: id, successActions: successActions, onSuccessDelegate: onSuccessDelegate);

  void afShutdown() {
    AFibD.logQuery?.d("Shutting down listener query $this");
    shutdown();
  }

  void shutdown();
}

/// A version of [AFAsyncQueryListenerCustomError] which users [AFQueryError] for errors.
abstract class AFAsyncQueryListener<TState, TResponse> extends AFAsyncQueryListenerCustomError<TState, TResponse, AFQueryError> {
    AFAsyncQueryListener({AFID id, List<dynamic> successActions, AFOnResponseDelegate<TState, TResponse> onSuccessDelegate, AFOnErrorDelegate<TState, AFQueryError> onErrorDelegate}): super(id: id, successActions: successActions, onSuccessDelegate: onSuccessDelegate, onErrorDelegate: onErrorDelegate);
}

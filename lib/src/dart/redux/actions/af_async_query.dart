


import 'dart:async';

import 'package:afib/afib_dart.dart';
import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_query_error.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_state_test.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:logger/logger.dart';

class AFStartQueryContext<TResponse, TError> {
  final Function(TResponse) onSuccess;
  final Function(TError) onError;

  AFStartQueryContext({this.onSuccess, this.onError});

  Logger get log {
    return AFibD.logAppQuery;
  }

}

class AFFinishQueryContext<TState extends AFAppStateArea> {
  final AFDispatcher dispatcher;
  final AFState state;

  AFFinishQueryContext({this.dispatcher, this.state});

  void dispatch(dynamic action) {
    dispatcher.dispatch(action);
  }

  AFDispatcher get d {
    return dispatcher;
  }

  TState get s {
    return state.public.areaStateFor(TState);
  }

  AFRouteParam findParam(AFScreenID screen) {
    return state.public.route.findParamFor(screen);
  }

  Logger get log {
    return AFibD.logAppQuery;
  }

  /// Dispatches an action that updates the route parameter for the specified screen.
  void updateScreenParam(AFScreenID screen, AFRouteParam param) {
    dispatch(AFNavigateSetParamAction(screen: screen, param: param));
  }

  /// Dispatches an action that updates a single value in the app state area associated
  /// with the [TState] type parameter.
  void updateAppState1(Object toIntegrate) {
    dispatch(AFUpdateAppStateAction(area: TState, toIntegrate: [toIntegrate]));
  }

  /// Dispatches an action that updates several blaues in the app state area associated
  /// with the [TState] type parameter.
  void updateAppStateN(List<Object> toIntegrate) {
    dispatch(AFUpdateAppStateAction(area: TState, toIntegrate: toIntegrate));
  }
}


class AFFinishQuerySuccessContext<TState extends AFAppStateArea, TResponse> extends AFFinishQueryContext<TState> {
  final TResponse response;
  AFFinishQuerySuccessContext({
    AFDispatcher dispatcher, 
    AFState state, 
    this.response
  }): super(dispatcher: dispatcher, state: state);


  TResponse get r {
    return response;
  }
}

class AFFinishQueryErrorContext<TState extends AFAppStateArea, TError> extends AFFinishQueryContext<TState> {
  final TError error;
  AFFinishQueryErrorContext({
    AFDispatcher dispatcher, 
    AFState state, 
    this.error
  }): super(dispatcher: dispatcher, state: state);

  TError get e {
    return error;
  }
}

/// Superclass for a kind of action that queries some data asynchronously, then knows
/// how to process the result.
abstract class AFAsyncQuery<TState extends AFAppStateArea, TResponse> extends AFActionWithKey {
  final List<dynamic> successActions;
  final AFOnResponseDelegate<TState, TResponse> onSuccessDelegate;
  final AFOnErrorDelegate<TState, AFQueryError> onErrorDelegate;

  AFAsyncQuery({AFID id, this.onSuccessDelegate, this.onErrorDelegate, this.successActions}): super(id: id);

  /// Called internally when redux middleware begins processing a query.
  void startAsyncAF(AFDispatcher dispatcher, AFStore store, { Function(dynamic) onResponseExtra, Function(dynamic) onErrorExtra }) {
    final startContext = AFStartQueryContext<TResponse, AFQueryError>(
      onSuccess: (response) { 
        // note: there could be multiple queries outstanding at once, meaning the state
        // might be changed by some other query while we are waiting for a responser.  
        // Consequently, it is important not to make a copy of the state above this point,
        // as it might go out of date.
        final successContext = AFFinishQuerySuccessContext<TState, TResponse>(dispatcher: dispatcher, state: store.state, response: response);
        finishAsyncWithResponseAF(successContext);
        if(onResponseExtra != null) {
          onResponseExtra(successContext);
        }
        AFibF.g.onQuerySuccess(this, successContext);
      }, 
      onError: (error) {
        final errorContext = AFFinishQueryErrorContext<TState, AFQueryError>(dispatcher: dispatcher, state: store.state, error: error);
        finishAsyncWithErrorAF(errorContext);
        if(onErrorExtra != null) {
          onErrorExtra(errorContext);
        }
      })
    ;
    AFibD.logQuery?.d("Starting query: $this");
    startAsync(startContext);
  }

  /// Called internally by the framework to do pre and post processing before [finishAsyncWithResponse]
  void finishAsyncWithResponseAF(AFFinishQuerySuccessContext<TState, TResponse> context) {
    finishAsyncWithResponse(context);
    if(onSuccessDelegate != null) {
      onSuccessDelegate(context);
    }
    if(successActions != null) {
      for(final act in successActions) {
        context.dispatch(act);
      }
    }
  }

  void finishAsyncWithErrorAF(AFFinishQueryErrorContext<TState, AFQueryError> context) {
    finishAsyncWithError(context);
    if(onErrorDelegate != null) {
      onErrorDelegate(context);
    }
  }

  /// Called at the start of an asynchronous process, starts the query using data from the
  /// command. 
  /// 
  /// The implementation should call either [AFStartQueryContext.onResponse] or [AFStartQueryContext.onError], which will in turn
  /// call [finishAsyncWithResult] or [finishAsyncWithError].
  void startAsync(AFStartQueryContext<TResponse, AFQueryError> context);

  /// Called when the asynchronous process completes with a response  It should merge the results 
  /// into the state (preserving immutability by making copies of the relevant portions of the state using copyWith), 
  /// and then use the dispatcher to call set actions for any modified 
  /// state elements.
  void finishAsyncWithResponse(AFFinishQuerySuccessContext<TState, TResponse> context);

  
  void finishAsyncWithError(AFFinishQueryErrorContext<TState, AFQueryError> context);

  /// Called during testing to simulate results from an asynchronous call.
  void testFinishAsyncWithResponse(AFStateTestContext context, TResponse response) {
    final successContext = AFFinishQuerySuccessContext<TState, TResponse>(
      dispatcher: context.dispatcher, 
      state: context.afState, 
      response: response
    );
    finishAsyncWithResponseAF(successContext);
  }

  /// Called during testing to simulate results from an asynchronous call.
  void testFinishAsyncWithError(AFStateTestContext context, AFQueryError error) {
    final errorContext = AFFinishQueryErrorContext<TState, AFQueryError>(
      dispatcher: context.dispatcher,
      state: context.afState,
      error: error
    );
    finishAsyncWithErrorAF(errorContext);
  }

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

class AFConsolidatedQuery<TState extends AFAppStateArea> extends AFAsyncQuery<TState, AFConsolidatedQueryResponse> {
  static const queryFailedCode = 792;
  static const queryFailedMessage = "At least one query in a consolidated query failed.";

  final AFConsolidatedQueryResponse queryResponses;

  AFConsolidatedQuery(this.queryResponses, {AFID id, AFOnResponseDelegate<TState, AFConsolidatedQueryResponse> onSuccessDelegate, AFOnErrorDelegate<TState, AFQueryError> onErrorDelegate, List<dynamic> successActions}):
    super(id: id, onSuccessDelegate: onSuccessDelegate, onErrorDelegate: onErrorDelegate, successActions: successActions);

  static List<AFAsyncQuery> createList() {
    return <AFAsyncQuery>[];
  }

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

  List<AFAsyncQuery> get allQueries {
    final result = <AFAsyncQuery>[];
    for(final qr in queryResponses.responses) {
      result.add(qr.query);
    }
    return result;
  }

  TQuery findQueryWhere<TQuery extends AFAsyncQuery>(Function(TQuery) testQuery) {
    for(final qr in queryResponses.responses) {
      final query = qr.query;
      if(query is TQuery) {
        if(testQuery(query)) {
          return query;
        }
      }
    }
    return null;
  }

  TQuery findQueryWithType<TQuery extends AFAsyncQuery>() {
    return findQueryWhere<TQuery>( (q) => true);
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
          final errorContext = AFFinishQueryErrorContext<TState, AFQueryError>(
            dispatcher: dispatcher,
            state: store.state,
            error: AFQueryError(code: queryFailedCode, message: queryFailedMessage)
          );
          finishAsyncWithErrorAF(errorContext);
        } else {
          final successContext = AFFinishQuerySuccessContext<TState, AFConsolidatedQueryResponse>(
            dispatcher: dispatcher,
            state: store.state,
            response: queryResponses
          );
          finishAsyncWithResponseAF(successContext);
        }
      });
  }

  /// This function will not be called in this variant, so overriding it is useless.
  void startAsync(AFStartQueryContext<AFConsolidatedQueryResponse, AFQueryError> context) {
    throw UnimplementedError();
  }

  /// By default, does nothing.
  /// 
  /// You can override this in your own subclass if you want, but many uses cases 
  /// are adequately covered by passing onSuccessDelegate or successActions to the constructor.
  void finishAsyncWithResponse(AFFinishQuerySuccessContext<TState, AFConsolidatedQueryResponse> response) {

  }

  
  /// By default, does nothing.
  /// 
  /// You can override this in your own subclass if you want, but many uses cases 
  /// are adequately covered by passing onSuccessDelegate or successActions to the constructor.
  void finishAsyncWithError(AFFinishQueryErrorContext<TState, AFQueryError> error) {

  }
}

/// A version of [AFAsyncQuery] for queries that have some kind of ongoing
/// connection or state that needs to be shutdown.  
/// 
/// Afib will automatically track these queries when you dispatch them.  You can dispatch the
/// [AFShutdownQueryListeners] action to call the shutdown method on some or all outstanding
/// listeners.  
abstract class AFAsyncQueryListener<TState extends AFAppStateArea, TResponse> extends AFAsyncQuery<TState, TResponse> {
  AFAsyncQueryListener({AFID id, List<dynamic> successActions, AFOnResponseDelegate<TState, TResponse> onSuccessDelegate, AFOnErrorDelegate<TState, AFQueryError> onErrorDelegate}): super(id: id, successActions: successActions, onSuccessDelegate: onSuccessDelegate);

  void afShutdown() {
    AFibD.logQuery?.d("Shutting down listener query $this");
    shutdown();
  }

  void shutdown();
}

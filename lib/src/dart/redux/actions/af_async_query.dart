import 'dart:async';

import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/redux/actions/af_deferred_query.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_query_error.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/test/af_state_test.dart';
import 'package:afib/src/flutter/utils/af_api_mixins.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart' as material;
import 'package:logger/logger.dart';


class AFQueryContext with AFContextShowMixin, AFStandardAPIContextMixin, AFNonUIAPIContextMixin {
  AFConceptualStore conceptualStore;


  AFQueryContext({
    required this.conceptualStore,
  });

  AFConceptualStore get targetStore {
    return conceptualStore;
  }

  AFDispatcher get dispatcher {
    return AFibF.g.internalOnlyStoreEntry(conceptualStore).dispatcher!;
  }

  void retargetStore(AFConceptualStore target) {
    conceptualStore = target;
  }

  void dispatch(dynamic action) {
    dispatcher.dispatch(action);
  }

  Logger? get log {
    return AFibD.log(AFConfigEntryLogArea.query);
  }

  material.BuildContext? get flutterContext {
    final route = AFibF.g.internalOnlyActiveStore.state.public.route;
    final currentScreenId = route.activeScreenId;
    final activeScreen = AFibF.g.internalOnlyFindScreen(currentScreenId);
    return activeScreen?.element;
  }
}

class AFStartQueryContext<TResponse> extends AFQueryContext {
  final void Function(TResponse) onSuccess;
  final void Function(AFQueryError) onError;

  AFStartQueryContext({
    required AFConceptualStore conceptualStore,
    required this.onSuccess, 
    required this.onError
  }): super(
    conceptualStore: conceptualStore,
  );
}


class AFFinishQueryContext<TState extends AFFlexibleState> extends AFQueryContext with AFAccessStateSynchronouslyMixin {

  AFFinishQueryContext({
    required AFConceptualStore conceptualStore,
  }): super(
    conceptualStore: conceptualStore,
  );

  AFState get state {
    return AFibF.g.internalOnlyStoreEntry(conceptualStore).store!.state;
  }

  AFPublicState get accessPublicState {
    return state.public;
  }

  TState get s {
    var result = state.public.componentStateOrNull<TState>();
    if(result == null) throw AFException("Missing $TState");
    return result;
  }


  Logger? get log {
    return AFibD.log(AFConfigEntryLogArea.query);
  }


}


class AFFinishQuerySuccessContext<TState extends AFFlexibleState, TResponse> extends AFFinishQueryContext<TState>  {
  final TResponse response;
  AFFinishQuerySuccessContext({
    required AFConceptualStore conceptualStore,
    required this.response
  }): super(conceptualStore: conceptualStore);


  TResponse get r {
    return response;
  }
}

class AFFinishQueryErrorContext<TState extends AFFlexibleState> extends AFFinishQueryContext<TState> {
  final AFQueryError error;
  AFFinishQueryErrorContext({
    required AFConceptualStore conceptualStore,
    required this.error
  }): super(conceptualStore: conceptualStore);

  AFQueryError get e {
    return error;
  }
}

/// Superclass for a kind of action that queries some data asynchronously, then knows
/// how to process the result.
abstract class AFAsyncQuery<TState extends AFFlexibleState, TResponse> extends AFActionWithKey {
  AFConceptualStore conceptualStore = AFConceptualStore.appStore;
  final AFOnResponseDelegate<TState, TResponse>? onSuccessDelegate;
  final AFOnErrorDelegate<TState>? onErrorDelegate;
  final AFPreExecuteResponseDelegate<TResponse>? onPreExecuteResponseDelegate;

  AFAsyncQuery({
    AFID? id, 
    this.onSuccessDelegate, 
    this.onErrorDelegate, 
    this.onPreExecuteResponseDelegate
  }): super(id: id) {
    conceptualStore = AFibF.g.activeConceptualStore;
  }

  void retargetStore(AFConceptualStore target) {
    conceptualStore = target;
  }

  /// Called internally when redux middleware begins processing a query.
  void startAsyncAF(AFDispatcher dispatcher, AFStore store, { void Function(dynamic)? onResponseExtra, void Function(dynamic)? onErrorExtra }) {
    final startContext = AFStartQueryContext<TResponse>(
      conceptualStore: conceptualStore,
      onSuccess: (response) { 
        // note: there could be multiple queries outstanding at once, meaning the state
        // might be changed by some other query while we are waiting for a responser.  
        // Consequently, it is important not to make a copy of the state above this point,
        // as it might go out of date.
        final successContext = AFFinishQuerySuccessContext<TState, TResponse>(
          conceptualStore: conceptualStore, 
          response: response
        );
        finishAsyncWithResponseAF(successContext);
        if(onResponseExtra != null) {
          onResponseExtra(successContext);
        }
      }, 
      onError: (error) {
        final errorContext = AFFinishQueryErrorContext<TState>(
          conceptualStore: conceptualStore, 
          error: error
        );
        finishAsyncWithErrorAF(errorContext);
        if(onErrorExtra != null) {
          onErrorExtra(errorContext);
        }
      })
    ;
    final pre = onPreExecuteResponseDelegate;
    if(pre != null) {
      final preResponse = pre();
      final successContext = AFFinishQuerySuccessContext<TState, TResponse>(
        conceptualStore: conceptualStore,
        response: preResponse);
      finishAsyncWithResponseAF(successContext);

    }
    AFibD.logQueryAF?.d("Starting query: $this");
    startAsync(startContext);
  }

  /// Called internally by the framework to do pre and post processing before [finishAsyncWithResponse]
  void finishAsyncWithResponseAF(AFFinishQuerySuccessContext<TState, TResponse> context) {
    finishAsyncWithResponse(context);
    final onSuccessD = onSuccessDelegate;

    // finishAsyncWithResponse might have updated the state.
    if(onSuccessD != null) {
      onSuccessD(context);
    }
    AFibF.g.onQuerySuccess(this, context);
  }

  void finishAsyncWithErrorAF(AFFinishQueryErrorContext<TState> context) {
    finishAsyncWithError(context);
    final onErrorD = onErrorDelegate;
    if(onErrorD != null) {
      onErrorD(context);
    }
  }

  /// The default implementation calls the error handler passed in to 
  /// [initializeLibraryFundamentals] in extend_app.dart
  void finishAsyncWithError(AFFinishQueryErrorContext<TState> context) {
    AFibF.g.finishAsyncWithError<TState>(context);
  }

  /// Called at the start of an asynchronous process, starts the query using data from the
  /// command. 
  /// 
  /// The implementation should call either [AFStartQueryContext.onResponse] or [AFStartQueryContext.onError], which will in turn
  /// call [finishAsyncWithResult] or [finishAsyncWithError].
  void startAsync(AFStartQueryContext<TResponse> context);

  /// Called when the asynchronous process completes with a response  It should merge the results 
  /// into the state (preserving immutability by making copies of the relevant portions of the state using copyWith), 
  /// and then use the dispatcher to call set actions for any modified 
  /// state elements.
  void finishAsyncWithResponse(AFFinishQuerySuccessContext<TState, TResponse> context);

  /// Called during testing to simulate results from an asynchronous call.
  void testFinishAsyncWithResponse(AFStateTestContext context, TResponse response) {
    final successContext = AFFinishQuerySuccessContext<TState, TResponse>(
      conceptualStore: conceptualStore,
      response: response
    );
    finishAsyncWithResponseAF(successContext);
  }

  /// Called during testing to simulate results from an asynchronous call.
  void testFinishAsyncWithError(AFStateTestContext context, AFQueryError error) {
    final errorContext = AFFinishQueryErrorContext<TState>(
      conceptualStore: conceptualStore,
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
    final foundIncomplete = responses.firstWhereOrNull( (response) => response.isIncomplete);
    return foundIncomplete == null;
  }

  bool get hasError {
    final foundError = responses.firstWhereOrNull( (response) => response.isError);
    return foundError != null;
  }

  List<TResult> resultsOfType<TResult>() {
    final results = <TResult>[];
    for(final r in responses) {
      if(r.result is TResult) {
        results.add(r.result);
      }
    }
    return results;
  }
}

class AFConsolidatedQuery<TState extends AFFlexibleState> extends AFAsyncQuery<TState, AFConsolidatedQueryResponse> {
  static const queryFailedCode = 792;
  static const queryFailedMessage = "At least one query in a consolidated query failed.";

  final AFConsolidatedQueryResponse queryResponses;

  AFConsolidatedQuery(this.queryResponses, {
    AFID? id, 
    AFOnResponseDelegate<TState, AFConsolidatedQueryResponse>? onSuccessDelegate, 
    AFOnErrorDelegate<TState>? onErrorDelegate,     
  }): super(id: id, onSuccessDelegate: onSuccessDelegate, onErrorDelegate: onErrorDelegate);

  static List<AFAsyncQuery> createList() {
    return <AFAsyncQuery>[];
  }

  factory AFConsolidatedQuery.createFrom({
    required List<AFAsyncQuery> queries,
    AFOnResponseDelegate<TState, AFConsolidatedQueryResponse>? onSuccessDelegate,
    AFOnErrorDelegate<TState>? onErrorDelegate
  }) {
    final response = AFConsolidatedQueryResponse.createFrom(queries);
    return AFConsolidatedQuery(response,
      onSuccessDelegate: onSuccessDelegate,
      onErrorDelegate: onErrorDelegate
    );
  }

  List<AFAsyncQuery> get allQueries {
    final result = <AFAsyncQuery>[];
    for(final qr in queryResponses.responses) {
      result.add(qr.query);
    }
    return result;
  }

  TQuery? findQueryWhere<TQuery extends AFAsyncQuery>(Function(TQuery) testQuery) {
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

  TQuery? findQueryWithType<TQuery extends AFAsyncQuery>() {
    return findQueryWhere<TQuery>( (q) => true);
  }

  void startAsyncAF(AFDispatcher dispatcher, AFStore store, { Function(dynamic)? onResponseExtra, Function(dynamic)? onErrorExtra }) {
      final completer = Completer<bool>();

      // start all the queries asynchronously.
      for(final queryResponse in queryResponses.responses) {
        final query = queryResponse.query;
        query.startAsyncAF(dispatcher, store, 
          onResponseExtra: (dynamic localResponse) {
            queryResponse.completeResponse(localResponse);
            if(queryResponses.isComplete) {
              if(!completer.isCompleted) {
                completer.complete(true);
              }
            }
          },
          onErrorExtra: (dynamic error) {
            queryResponse.completeError(error);
            if(queryResponses.isComplete) {
              if(!completer.isCompleted) {
                completer.complete(true);
              }
            }
          }
        );
      }

      // when they have all completed, then process our response.
      completer.future.then((_) {
        if(queryResponses.hasError) {
          final errorContext = AFFinishQueryErrorContext<TState>(
            conceptualStore: conceptualStore,
            error: AFQueryError(code: queryFailedCode, message: queryFailedMessage)
          );
          finishAsyncWithErrorAF(errorContext);
        } else {
          final successContext = AFFinishQuerySuccessContext<TState, AFConsolidatedQueryResponse>(
            conceptualStore: conceptualStore,
            response: queryResponses
          );
          finishAsyncWithResponseAF(successContext);
        }
      });
  }

  /// This function will not be called in this variant, so overriding it is useless.
  void startAsync(AFStartQueryContext<AFConsolidatedQueryResponse> context) {
    throw UnimplementedError();
  }

  /// By default, does nothing.
  /// 
  /// You can override this in your own subclass if you want, but many uses cases 
  /// are adequately covered by passing onSuccessDelegate.
  void finishAsyncWithResponse(AFFinishQuerySuccessContext<TState, AFConsolidatedQueryResponse> response) {

  }
}

/// A version of [AFAsyncQuery] for queries that have some kind of ongoing
/// connection or state that needs to be shutdown.  
/// 
/// Afib will automatically track these queries when you dispatch them.  You can dispatch the
/// [AFShutdownQueryListeners] action to call the shutdown method on some or all outstanding
/// listeners.  
abstract class AFAsyncListenerQuery<TState extends AFFlexibleState, TResponse> extends AFAsyncQuery<TState, TResponse> implements AFTrackedQuery {
  AFAsyncListenerQuery({
    AFID? id, 
    AFPreExecuteResponseDelegate<TResponse>? onPreExecuteResponseDelegate,
    AFOnResponseDelegate<TState, TResponse>? onSuccessDelegate, 
    AFOnErrorDelegate<TState>? onErrorDelegate
  }): super(id: id, onSuccessDelegate: onSuccessDelegate, onPreExecuteResponseDelegate: onPreExecuteResponseDelegate);

  void afShutdown() {
    AFibD.logQueryAF?.d("Shutting down listener query $this");
    shutdown();
  }

  /// Returns the new query, causing any existing query to be shutdown and replaced with the new one
  AFTrackedQuery? mergeWith(AFTrackedQuery newQuery) {
    return newQuery;
  }


  void shutdown();
}

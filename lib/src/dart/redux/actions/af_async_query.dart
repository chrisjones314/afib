import 'dart:async';

import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/redux/actions/af_deferred_query.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_query_error.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/test/af_state_test.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/utils/af_api_mixins.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart' as material;
import 'package:logger/logger.dart';


class AFQueryContext with AFContextShowMixin, AFStandardAPIContextMixin, AFStandardNavigateMixin, AFNonUIAPIContextMixin, AFAccessStateSynchronouslyMixin implements AFStandardAPIContextInterface {
  AFConceptualStore conceptualStore;


  AFQueryContext({
    required this.conceptualStore,
  });

  @override
  AFConceptualStore get targetStore {
    return conceptualStore;
  }

  @override
  AFDispatcher get dispatcher {
    return AFibF.g.internalOnlyStoreEntry(conceptualStore).dispatcher!;
  }

  AFPublicState? get debugOnlyPublicState {
    return AFibF.g.internalOnlyStore(conceptualStore).state.public;
  }


  void retargetStore(AFConceptualStore target) {
    conceptualStore = target;
  }

  @override
  void dispatch(dynamic action) {
    dispatcher.dispatch(action);
  }

  Logger? get log {
    return AFibD.log(AFConfigEntryLogArea.query);
  }

  @override
  material.BuildContext? get flutterContext {
    return AFibF.g.currentFlutterContext;
  }
}

class AFStartQueryContext<TResponse> extends AFQueryContext {
  final void Function(TResponse) onSuccess;
  final void Function(AFQueryError) onError;

  AFStartQueryContext({
    required AFConceptualStore conceptualStore,
    required this.onSuccess, 
    required this.onError,
  }): super(
    conceptualStore: conceptualStore,
  );

  Future<AFFinishQuerySuccessContext<TRespLocal>> executeQueryWithAwait<TRespLocal>(AFAsyncQuery query) async {
    final completer = Completer<AFFinishQuerySuccessContext<TRespLocal>>();
    this.dispatch(AFAsyncQueryFuture<TRespLocal>(
      query: query, 
      completer: completer
    ));
    return completer.future;
  }

}


class AFFinishQueryContext extends AFQueryContext {
  AFFinishQueryContext({
    required AFConceptualStore conceptualStore,
  }): super(
    conceptualStore: conceptualStore,
  );

  AFState get state {
    return AFibF.g.internalOnlyStoreEntry(conceptualStore).store!.state;
  }

  @override
  AFPublicState get accessPublicState {
    return state.public;
  }

  @override
  Logger? get log {
    return AFibD.log(AFConfigEntryLogArea.query);
  }

  /// Provided for consistency with [AFBuildContext.accessOnEventContext], so that
  /// you can pass an [AFOnEventContext] to any shared function that requires one.
  AFOnEventContext accessOnEventContext() {
    return AFPublicStateOnEventContext(
      dispatcher: dispatcher,
      public: accessPublicState,
    );
  }
}


class AFFinishQuerySuccessContext<TResponse> extends AFFinishQueryContext  {
  final TResponse response;
  final bool isPreExecute;
  AFFinishQuerySuccessContext({
    required AFConceptualStore conceptualStore,
    required this.response,
    required this.isPreExecute,
  }): super(conceptualStore: conceptualStore);


  TResponse get r {
    return response;
  }
}

class AFFinishQueryErrorContext extends AFFinishQueryContext {
  final AFQueryError error;
  AFFinishQueryErrorContext({
    required AFConceptualStore conceptualStore,
    required this.error
  }): super(conceptualStore: conceptualStore);

  AFQueryError get e {
    return error;
  }

  int get code {
    return error.code;
  }

  String? get message { 
    return error.message;
  }
}

class AFAsyncQueryFuture<TResponse> extends AFActionWithKey {
  final AFAsyncQuery query;
  final Completer<AFFinishQuerySuccessContext<TResponse>> completer;

  AFAsyncQueryFuture({
    required this.query,
    required this.completer,
  });
}

/// Superclass for a kind of action that queries some data asynchronously, then knows
/// how to process the result.
abstract class AFAsyncQuery<TResponse> extends AFActionWithKey {
  AFConceptualStore conceptualStore = AFConceptualStore.appStore;
  final AFOnResponseDelegate<TResponse>? onSuccess;
  final AFOnErrorDelegate? onError;
  final AFPreExecuteResponseDelegate<TResponse>? onPreExecuteResponse;
  int? lastStart;
  final int? simulatedLatencyFactor;

  AFAsyncQuery({
    AFID? id, 
    this.onSuccess, 
    this.onError, 
    this.onPreExecuteResponse,
    this.simulatedLatencyFactor,
  }): super(id: id) {
    conceptualStore = AFibF.g.activeConceptualStore;
  }

  void retargetStore(AFConceptualStore target) {
    conceptualStore = target;
  }

  int currentMillis() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  Never throwUnimplemented() {
    throw AFException("You must implement the startAsync method of the query $runtimeType");
  }

  AFFinishQuerySuccessContext<TResponse> createSuccessContextForResponse({
    required AFDispatcher dispatcher, 
    required AFState state, 
    required TResponse response,
    required bool isPreExecute,
  }) {
    return AFFinishQuerySuccessContext<TResponse>(    
      conceptualStore: conceptualStore,
      response: response,
      isPreExecute: isPreExecute,
    );
  }

  /// Called internally when redux middleware begins processing a query.
  void startAsyncAF(AFDispatcher dispatcher, AFStore store, { 
    required Completer<AFFinishQuerySuccessContext>? completer,
    void Function(dynamic)? onResponseExtra, 
    void Function(dynamic)? onErrorExtra  
  }) {
    lastStart = currentMillis();
    final startContext = AFStartQueryContext<TResponse>(
      conceptualStore: conceptualStore,
      onSuccess: (response) { 
        // note: there could be multiple queries outstanding at once, meaning the state
        // might be changed by some other query while we are waiting for a responser.  
        // Consequently, it is important not to make a copy of the state above this point,
        // as it might go out of date.
        final successContext = AFFinishQuerySuccessContext<TResponse>(
          conceptualStore: conceptualStore, 
          response: response,
          isPreExecute: false,
        );
        finishAsyncWithResponseAF(successContext);
        if(onResponseExtra != null) {
          onResponseExtra(successContext);
        }
        if(completer != null) {
          completer.complete(successContext);
        }
      }, 
      onError: (error) {
        final errorContext = AFFinishQueryErrorContext(
          conceptualStore: conceptualStore, 
          error: error
        );
        finishAsyncWithErrorAF(errorContext);
        if(onErrorExtra != null) {
          onErrorExtra(errorContext);
        }
        if(completer != null) {
          completer.completeError(errorContext);
        }
      })
    ;
    final pre = onPreExecuteResponse;
    if(pre != null) {
      final preResponse = pre();
      final successContext = AFFinishQuerySuccessContext<TResponse>(
        conceptualStore: conceptualStore,
        response: preResponse,
        isPreExecute: true,
      );
      finishAsyncWithResponseAF(successContext);

    }
    AFibD.logQueryAF?.d("Starting query: $this");
    try {
      startAsync(startContext);
    } on AFFinishQueryErrorContext catch(errCtx) {
      finishAsyncWithErrorAF(errCtx);
    }
  }

  /// Called internally by the framework to do pre and post processing before [finishAsyncWithResponse]
  void finishAsyncWithResponseAF(AFFinishQuerySuccessContext<TResponse> context) {
    finishAsyncWithResponse(context);
    final onSuccessD = onSuccess;
    final lastS = lastStart;
    if(lastS != null) {
      final elapsed = currentMillis() - lastS;
      AFibD.logQueryAF?.d("Query $this completed in ${elapsed}ms");
    }


    // finishAsyncWithResponse might have updated the state.
    if(onSuccessD != null) {
      onSuccessD(context);
    }
    AFibF.g.onQuerySuccess(this, context);
  }

  void finishAsyncWithErrorAF(AFFinishQueryErrorContext context) {
    finishAsyncWithError(context);
    final onErrorD = onError;
    if(onErrorD != null) {
      onErrorD(context);
    }
  }

  /// The default implementation calls the error handler specified
  /// in your xxx_define_core.dart file.
  void finishAsyncWithError(AFFinishQueryErrorContext context) {
    if(onError == null) {
      AFibF.g.finishAsyncWithError(context);
    }
  }

  /// Called at the start of an asynchronous process, starts the query using data from the
  /// command. 
  /// 
  /// The implementation should call either [AFStartQueryContext.onSuccess] or [AFStartQueryContext.onError], which will in turn
  /// call [finishAsyncWithResponse] or [finishAsyncWithError].
  void startAsync(AFStartQueryContext<TResponse> context);

  /// Called when the asynchronous process completes with a response  It should merge the results 
  /// into the state (preserving immutability by making copies of the relevant portions of the state using copyWith), 
  /// and then use the dispatcher to call set actions for any modified 
  /// state elements.
  void finishAsyncWithResponse(AFFinishQuerySuccessContext<TResponse> context);

  /// Called during testing to simulate results from an asynchronous call.
  void testFinishAsyncWithResponse(AFStateTestContext context, TResponse response) {
    final successContext = AFFinishQuerySuccessContext<TResponse>(
      conceptualStore: conceptualStore,
      response: response,
      isPreExecute: false,
    );
    finishAsyncWithResponseAF(successContext);
  }

  /// Called during testing to simulate results from an asynchronous call.
  void testFinishAsyncWithError(AFStateTestContext context, AFQueryError error) {
    final errorContext = AFFinishQueryErrorContext(
      conceptualStore: conceptualStore,
      error: error
    );
    finishAsyncWithErrorAF(errorContext);
  }

}

class AFCompositeQueryEntry {
  static const int statusNone    = 0;
  static const int statusError   = 1;
  static const int statusSuccess = 2;

  final AFAsyncQuery query;
  int status;
  dynamic result;

  AFCompositeQueryEntry(this.query, this.status);

  factory AFCompositeQueryEntry.createFrom(AFAsyncQuery query) {
    return AFCompositeQueryEntry(query, statusNone);
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

class AFCompositeQueryResponse {
  final List<AFCompositeQueryEntry> responses;

  AFCompositeQueryResponse(this.responses);

  factory AFCompositeQueryResponse.createFrom(List<AFAsyncQuery> queries) {
    final list = queries.map( (query) => AFCompositeQueryEntry.createFrom(query));
    return AFCompositeQueryResponse(List<AFCompositeQueryEntry>.of(list));
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

  List<dynamic> allResults() {
    final results = <dynamic>[];
    for(final r in responses) {
      results.add(r.result);
    }
    return results;
  }
}

class AFCompositeQuery extends AFAsyncQuery<AFCompositeQueryResponse> {
  static const queryFailedCode = 792;
  static const queryFailedMessage = "At least one query in a consolidated query failed.";

  final AFCompositeQueryResponse queryResponses;

  AFCompositeQuery(this.queryResponses, {
    AFID? id, 
    AFOnResponseDelegate<AFCompositeQueryResponse>? onSuccess, 
    AFOnErrorDelegate? onError,     
    int? simulatedLatencyFactor,
  }): super(id: id, onSuccess: onSuccess, onError: onError, simulatedLatencyFactor: simulatedLatencyFactor);

  static List<AFAsyncQuery> createList() {
    return <AFAsyncQuery>[];
  }

  factory AFCompositeQuery.createFrom({
    required List<AFAsyncQuery> queries,
    AFOnResponseDelegate<AFCompositeQueryResponse>? onSuccess,
    AFOnErrorDelegate? onError
  }) {
    final response = AFCompositeQueryResponse.createFrom(queries);
    return AFCompositeQuery(response,
      onSuccess: onSuccess,
      onError: onError
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

  @override
  void startAsyncAF(AFDispatcher dispatcher, AFStore store, { 
    required Completer<AFFinishQuerySuccessContext>? completer,
    Function(dynamic)? onResponseExtra, 
    Function(dynamic)? onErrorExtra 
  }) {
      final completerBool = Completer<bool>();
      lastStart = currentMillis();
      // start all the queries asynchronously.
      for(final queryResponse in queryResponses.responses) {
        final query = queryResponse.query;
        query.startAsyncAF(dispatcher, store, 
          completer: null,
          onResponseExtra: (dynamic localResponse) {
            queryResponse.completeResponse(localResponse);
            final isComp = queryResponses.isComplete;
            if(isComp) {
              if(!completerBool.isCompleted) {
                completerBool.complete(true);
              }
            }
          },
          onErrorExtra: (dynamic error) {
            queryResponse.completeError(error);
            if(queryResponses.isComplete) {
              if(!completerBool.isCompleted) {
                completerBool.complete(true);
              }
            }
          }
        );
      }

      bool calledComplete = false;

      // when they have all completed, then process our response.
      completerBool.future.then((_) {
        if(queryResponses.hasError) {
          final errorContext = AFFinishQueryErrorContext(
            conceptualStore: conceptualStore,
            error: AFQueryError(code: queryFailedCode, message: queryFailedMessage)
          );
          if(!calledComplete) {
            calledComplete = true;
            finishAsyncWithErrorAF(errorContext);
            if(completer != null) {
              completer.completeError(errorContext);
            }
          }
        } else {
          final successContext = AFFinishQuerySuccessContext<AFCompositeQueryResponse>(
            conceptualStore: conceptualStore,
            response: queryResponses,
            isPreExecute: false,
          );
          
          if(!calledComplete) {
            calledComplete = true;
            finishAsyncWithResponseAF(successContext);
            if(completer != null) {
              completer.complete(successContext);
            }
          }
        }
      });
  }

  /// This function will not be called in this variant, so overriding it is useless.
  @override
  void startAsync(AFStartQueryContext<AFCompositeQueryResponse> context) {
    throw UnimplementedError();
  }

  /// By default, does nothing.
  /// 
  /// You can override this in your own subclass if you want, but many uses cases 
  /// are adequately covered by passing onSuccess.
  @override
  void finishAsyncWithResponse(AFFinishQuerySuccessContext<AFCompositeQueryResponse> response) {

  }

  /// A utility for throwing unimplemented in your startAsync method before you have implemented it.
  /// 
  /// Provides a nice error message
  @override
  Never throwUnimplemented() {
    throw AFException("The query $runtimeType is not implemented in debug/production, fill in startAsync");
  }
}

/// A version of [AFAsyncQuery] for queries that have some kind of ongoing
/// connection or state that needs to be shutdown.  
/// 
/// Afib will automatically track these queries when you dispatch them.  You can use 
/// [AFStandardAPIContextMixin.executeShutdownAllActiveQueries] or [AFStandardAPIContextMixin.executeShutdownListenerQuery]
/// to shut them down.
abstract class AFAsyncListenerQuery<TResponse> extends AFAsyncQuery<TResponse> implements AFTrackedQuery {
  AFAsyncListenerQuery({
    AFID? id, 
    AFPreExecuteResponseDelegate<TResponse>? onPreExecuteResponse,
    AFOnResponseDelegate<TResponse>? onSuccess, 
    AFOnErrorDelegate? onError
  }): super(id: id, onSuccess: onSuccess, onPreExecuteResponse: onPreExecuteResponse);

  void afShutdown() {
    AFibD.logQueryAF?.d("Shutting down listener query $this");
    shutdown();
  }

  /// Provides an opportunity to merge this new query with an old query when you 
  /// start a query and a previous version of it already exists in the state.
  /// 
  /// By default, just returns this, meaning that writes are just straight replacements.
  @override
  AFTrackedQuery? mergeOnWrite(AFTrackedQuery oldQuery) {
    return this;
  }

  @override
  void shutdown();
}

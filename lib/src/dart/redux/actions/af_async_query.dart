


import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_query_error.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/test/af_state_test.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';


/// Superclass for a kind of action that queries some data asynchronously, then knows
/// how to process the result.
abstract class AFAsyncQueryCustomError<TState, TResponse, TError> extends AFActionWithKey {

  AFAsyncQueryCustomError({AFID id}): super(id: id);

  /// Called internally when redux middleware begins processing a query.
  void startAsyncAF(AFDispatcher dispatcher, AFStore store) {
    AFibD.logQuery?.d("Starting query: $this");
    startAsync( (TResponse result) { 
      // note: there could be multiple queries outstanding at once, meaning the state
      // might be changed by some other query while we are waiting for a responser.  
      // Consequently, it is important not to make a copy of the state above this point,
      // as it might go out of date.
      finishAsyncWithResponseAF(dispatcher, store.state.app, result);
    }, (TError error) {
      finishAsyncWithErrorAF(dispatcher, store.state.app, error);
    });
  }

  /// Called internally by the framework to do pre and post processing before [finishAsyncWithResponse]
  void finishAsyncWithResponseAF(AFDispatcher dispatcher, TState state, TResponse response) {
    finishAsyncWithResponse(dispatcher, state, response);
    AFibF.handleFinishWithResponse(this, dispatcher, state);
  }

  void finishAsyncWithErrorAF(AFDispatcher dispatcher, TState state, TError error) {
    finishAsyncWithError(dispatcher, state, error);
    AFibF.handleFinishWithError(this, dispatcher, state);
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
  AFAsyncQuery({AFID id}): super(id: id);
}


/// A version of [AFAsyncQueryCustomError] for queries that have some kind of ongoing
/// connection or state that needs to be shutdown.  
/// 
/// Afib will automatically track these queries when you dispatch them.  You can dispatch the
/// [AFShutdownQueryListeners] action to call the shutdown method on some or all outstanding
/// listeners.  
abstract class AFAsyncQueryListenerCustomError<TState, TResponse, TError> extends AFAsyncQueryCustomError<TState, TResponse, TError> {
  AFAsyncQueryListenerCustomError({AFID id}): super(id: id);

  void afShutdown() {
    AFibD.logQuery?.d("Shutting down listener query $this");
    shutdown();
  }

  void shutdown();
}

/// A version of [AFAsyncQueryListenerCustomError] which users [AFQueryError] for errors.
abstract class AFAsyncQueryListener<TState, TResponse> extends AFAsyncQueryListenerCustomError<TState, TResponse, AFQueryError> {
    AFAsyncQueryListener({AFID id}): super(id: id);
}

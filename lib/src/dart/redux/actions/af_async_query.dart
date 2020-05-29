


import 'package:afib/afib_dart.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/flutter/af.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';


/// Superclass for a kind of action that queries some data asynchronously, then knows
/// how to process the result.
abstract class AFAsyncQueryCustomError<TState, TResponse, TError> {

  /// Returns a key used to identify the query.
  String get key {
    return runtimeType.toString();
  }

  /// Called internally when redux middleware begins processing a query.
  void startAsyncAF(AFDispatcher dispatcher, AFState state) {
    AF.logger.fine("Starting query: ${toString()}");
    startAsync( (TResponse result, TError error) {
      finishAsync(dispatcher, state.app, result, error);
    });
  }

  /// Called at the start of an asynchronous process, starts the query using data from the
  /// command. 
  /// 
  /// The implementation should call either [onResponse] or [onError], which will in turn
  /// call finishAsync.
  void startAsync( Function(TResponse response, TError error) onResponse);  

  /// Called when the asynchronous process completes with a response  It should merge the results 
  /// into the state (preserving immutability by making copies of the relevant portions of the state using copyWith), 
  /// and then use the dispatcher to call set actions for any modified 
  /// state elements.
  void finishAsync(AFDispatcher dispatcher, TState state, TResponse response, TError error);

  /// Called during testing to simulate results from an asynchronous call.
  void testFinishAsync(AFStateTestContext context, TResponse response, TError error) {
    finishAsync(context.dispatcher, context.state, response, error);
  }
}

/// A default version of [AFAsyncQueryCustomError] with the standard [AFQueryError] type, which is sufficient
/// in most cases.
abstract class AFAsyncQuery<TState, TResponse> extends AFAsyncQueryCustomError<TState, TResponse, AFQueryError> {

}
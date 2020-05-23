


import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:redux/redux.dart';

/// Superclass for a kind of action that queries some data asynchronously, then knows
/// how to process the result.
abstract class AFAsyncQueryAction<TState, TResponse> {

  void startAsyncAF(AFDispatcher dispatcher, AFState state, NextDispatcher next) {
    startAsync( (TResponse result) {
      finishAsync(dispatcher, state, result);
    });
    next(this);
  }


  /// Called at the start of an asynchronous process, starts the query using data from the
  /// command. 
  /// 
  /// The implementation should call either [onResponse] or [onError], which will in turn
  /// call finishAsync.
  void startAsync( Function(TResponse response) onResponse);  

  /// Called when the asynchronous process completes with a response  It should merge the results 
  /// into the state (preserving immutability by making copies of the relevant portions of the state using copyWith), 
  /// and then use the dispatcher to call set actions for any modified 
  /// state elements.
  void finishAsync(AFDispatcher dispatcher, AFState state, TResponse response);
}



import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/flutter/af.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';


/// Superclass for a kind of action that queries some data asynchronously, then knows
/// how to process the result.
abstract class AFAsyncQuery<TState, TResponse, TError> {

  void startAsyncAF(AFDispatcher dispatcher, AFState state) {
    AF.logger.fine("Starting query: ${toString()}");
    startAsync( (TResponse result, TError error) {
      finishAsync(dispatcher, state.app, result);
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
  void finishAsync(AFDispatcher dispatcher, TState state, TResponse response);
}

import 'dart:async';

import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_query_error.dart';
import 'package:afib/src/dart/utils/af_unused.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';

/// A version of [AFAsyncQueryCustomError] for queries that should be run in the background
/// after a delay.  
///   
abstract class AFDeferredQueryCustomError<TState, TError> extends AFAsyncQueryCustomError<TState, AFUnused, TError> {
  Duration nextDelay;
  Timer timer;

  AFDeferredQueryCustomError(this.nextDelay, {AFID id}): super(id: id);

  /// Delays for [nextDelay] and then calls [finishAsyncWithResponse] with null as the value.
  /// 
  /// There is no way to execute code during the startAsync function by design,
  /// the whole point of a deferred query is to execute some code after a delay.
  /// In addition, any calculations done at the beginning might be based on an
  /// obsolete state by the time onResponse gets called.   Instead, you want to
  /// do your calculations on the state you are handed on [finishAsyncExecute]
  void startAsync(Function(AFUnused) onResponse, Function(TError) onError) {
    _delayThenExecute(onResponse);
  }

  void _delayThenExecute(Function(AFUnused) onResponse) {
    timer = Timer(nextDelay, () {
      AFibD.logQuery?.d("Executing finishAsyncExecute for deferred query $this");
      onResponse(null);
      if(nextDelay == null) {
        afShutdown();
      } else {
        AFibD.logQuery?.d("Waiting $nextDelay to execute $key again");
        _delayThenExecute(onResponse);
      }
    });
  }

  /// Calls the more appropriate [finishAsyncExecute] when the [initialDelay] associated with this
  /// query has expired.
  void finishAsyncWithResponse(AFDispatcher dispatcher, TState state, AFUnused response) {
    nextDelay = finishAsyncExecute(dispatcher, state);
  }

  /// Override this method to perform deferred calculations. 
  /// 
  /// Return null if you are done executing, or return a duration if you'd like to try executing
  /// again after another delay.
  Duration finishAsyncExecute(AFDispatcher dispatcher, TState state);

  void afShutdown() {
    if(timer != null) {
      AFibD.logQuery?.d("Shutting down deferred query $this");
      timer?.cancel();
      timer = null;
      shutdown();
    }
  }

  void shutdown();
}

/// A version of [AFDeferredQueryCustomError] which users [AFQueryError] for errors.
abstract class AFDeferredQuery<TState> extends AFDeferredQueryCustomError<TState, AFQueryError> {
    AFDeferredQuery(Duration initialDelay, {AFID id}): super(initialDelay, id: id);
}

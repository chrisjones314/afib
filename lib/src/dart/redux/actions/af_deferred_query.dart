
import 'dart:async';

import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_query_error.dart';
import 'package:afib/src/dart/utils/af_unused.dart';
import 'package:afib/src/flutter/af.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';

/// A version of [AFAsyncQueryCustomError] for queries that should be run in the background
/// after a delay.  
///   
abstract class AFDeferredQueryCustomError<TState, TError> extends AFAsyncQueryCustomError<TState, AFUnused, TError> {
  final Duration initialDelay;
  Timer timer;

  AFDeferredQueryCustomError(this.initialDelay, {AFID id}): super(id: id);

  /// Delays for [initialDelay] and then calls [finishAsyncWithResponse] with null as the value.
  /// 
  /// There is no way to execute code during the startAsync function by design,
  /// the whole point of a deferred query is to execute some code after a delay.
  /// In addition, any calculations done at the beginning might be based on an
  /// obsolete state by the time onResponse gets called.   Instead, you want to
  /// do your calculations on the state you are handed on [finishAsyncWithResponse]
  void startAsync(Function(AFUnused) onResponse, Function(TError) onError) {
    timer = Timer(initialDelay, () {
      AF.logInternal?.fine("Executing finishAsyncExecute for deferred query $key");
      onResponse(null);
      afShutdown();
    });
  }

  /// Calls the more appropriate [finishAsyncExecute] when the [initialDelay] associated with this
  /// query has expired.
  void finishAsyncWithResponse(AFDispatcher dispatcher, TState state, AFUnused response) {
    finishAsyncExecute(dispatcher, state);
  }

  /// Override this method to perform calculations
  void finishAsyncExecute(AFDispatcher dispatcher, TState state);

  void afShutdown() {
    if(timer != null) {
      AF.logInternal?.fine("Shutting down deferred query $key");
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

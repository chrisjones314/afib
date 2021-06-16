// @dart=2.9
import 'dart:async';

import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_unused.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';

/// A version of [AFAsyncQuery] for queries that should be run in the background
/// after a delay.  
abstract class AFDeferredQuery<TState extends AFAppStateArea> extends AFAsyncQuery<TState, AFUnused> {
  Duration nextDelay;
  Timer timer;

  AFDeferredQuery(this.nextDelay, {AFID id, AFOnResponseDelegate<TState, AFUnused> onSuccessDelegate}): super(id: id, onSuccessDelegate: onSuccessDelegate);

  /// Delays for [nextDelay] and then calls [finishAsyncWithResponse] with null as the value.
  /// 
  /// There is no way to execute code during the startAsync function by design,
  /// the whole point of a deferred query is to execute some code after a delay.
  /// In addition, any calculations done at the beginning might be based on an
  /// obsolete state by the time onResponse gets called.   Instead, you want to
  /// do your calculations on the state you are handed on [finishAsyncExecute]
  void startAsync(AFStartQueryContext<AFUnused> context) {
    _delayThenExecute(context);
  }

  void _delayThenExecute(AFStartQueryContext<AFUnused> context) {
    timer = Timer.periodic(nextDelay, (_) {
      AFibD.logQueryAF?.d("Executing finishAsyncExecute for deferred query $this");
      context.onSuccess(null);
      if(nextDelay == null) {
        afShutdown();
      } else {
        AFibD.logQueryAF?.d("Waiting $nextDelay to execute $key again");
      }
    });
  }

  /// Calls the more appropriate [finishAsyncExecute] when the [initialDelay] associated with this
  /// query has expired.
  void finishAsyncWithResponse(AFFinishQuerySuccessContext<TState, AFUnused> context) {
    nextDelay = finishAsyncExecute(context);
  }

  /// Override this method to perform deferred calculations. 
  /// 
  /// Return null if you are done executing, or return a duration if you'd like to try executing
  /// again after another delay.
  Duration finishAsyncExecute(AFFinishQuerySuccessContext<TState, AFUnused> context);

  void afShutdown() {
    if(timer != null) {
      AFibD.logQueryAF?.d("Shutting down deferred query $this");
      timer?.cancel();
      timer = null;
      shutdown();
    }
  }

  void shutdown();

  AFFinishQuerySuccessContext createSuccessContext({
    AFDispatcher dispatcher, 
    AFState state, 
  }) {
    return AFFinishQuerySuccessContext<TState, AFUnused>(    
      dispatcher: dispatcher,
      state: state,
      response: null,
    );
  }
}

/// A deferred query which waits a specified duration, then calls its onSuccessDelegate,
/// but does not otherwise do anything.
class AFDeferredSuccessQuery<TState extends AFAppStateArea> extends AFDeferredQuery<TState> {

  AFDeferredSuccessQuery(Duration delayOnce, {AFID id, AFOnResponseDelegate<TState, AFUnused> onSuccessDelegate}): super(delayOnce, id: id, onSuccessDelegate: onSuccessDelegate);
  Duration finishAsyncExecute(AFFinishQuerySuccessContext<TState, AFUnused> context) {
    if(this.onSuccessDelegate != null) {
      onSuccessDelegate(context);
    }
    return null;
  }

  void shutdown() {

  }

}

/// Shuts down outstanding deferred and listener queries.
class AFShutdownOngoingQueriesAction extends AFActionWithKey {


}



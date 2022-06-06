import 'dart:async';

import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/actions/af_query_actions.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_unused.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';

/// Superclass enforcing consistency for queries that live for a while
/// and are tracked within the public state.
abstract class AFTrackedQuery {

  /// When you execute a new query of a given type, while an existing
  /// instance already exists, this method is called on the existing instance to
  /// merge the two queries.
  /// 
  /// This method can return just the new query, just the original query, or some
  /// merged version of the combined queries.
  AFTrackedQuery? mergeWith(AFTrackedQuery newQuery);
  
  /// Called when this query terminates.
  void shutdown();
}

/// A version of [AFAsyncQuery] for queries that should be run in the background
/// after a delay.  
abstract class AFDeferredQuery<TState extends AFFlexibleState> extends AFAsyncQuery<TState, AFUnused> implements AFTrackedQuery {
  final Duration delay;

  AFDeferredQuery(this.delay, {
    AFID? id, 
    AFOnResponseDelegate<TState, AFUnused>? onSuccessDelegate
  }): super(id: id, onSuccessDelegate: onSuccessDelegate);

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
    if(delay.inMicroseconds == 0) {
      context.onSuccess(AFUnused.unused);
      afShutdown(context);
      return;
    }
    Future.delayed(delay, () async {
      AFibD.logQueryAF?.d("Executing finishAsyncExecute for deferred query $this");
      context.onSuccess(AFUnused.unused);
      afShutdown(context);
    });
  }

  /// Calls the more appropriate [finishAsyncExecute] when the [initialDelay] associated with this
  /// query has expired.
  void finishAsyncWithResponse(AFFinishQuerySuccessContext<TState, AFUnused> context) {
    finishAsyncExecute(context);
    context.dispatch(AFShutdownDeferredQueryAction(this.key));
  }

  /// Returns the new query, causing any existing query to be shutdown and replaced with the new one
  AFTrackedQuery? mergeWith(AFTrackedQuery newQuery) {
    return newQuery;
  }


  /// Override this method to perform deferred calculations. 
  /// 
  /// Return null if you are done executing, or return a duration if you'd like to try executing
  /// again after another delay.
  void finishAsyncExecute(AFFinishQuerySuccessContext<TState, AFUnused> context);

  void afShutdown(AFStartQueryContext<AFUnused>? context) {
    shutdown();
  }

  void shutdown();

  AFFinishQuerySuccessContext<TState, AFUnused> createSuccessContext({
    required AFDispatcher dispatcher, 
    required AFState state, 
  }) {
    return AFFinishQuerySuccessContext<TState, AFUnused>(    
      conceptualStore: conceptualStore,
      response: AFUnused(),
    );
  }

}

/// A version of [AFAsyncQuery] for queries that should be run periodically in the background.  
abstract class AFPeriodicQuery<TState extends AFFlexibleState> extends AFAsyncQuery<TState, AFUnused> implements AFTrackedQuery {
  final Duration delay;
  Timer? timer;
  bool keepGoing;

  AFPeriodicQuery(this.delay, {
    AFID? id, 
    AFOnResponseDelegate<TState, AFUnused>? onSuccessDelegate,
    this.keepGoing = true,
  }): super(id: id, onSuccessDelegate: onSuccessDelegate);

  /// Delays for [delay] and then calls [finishAsyncWithResponse] with null as the value.
  /// 
  /// There is no way to execute code during the startAsync function by design,
  /// the whole point of a deferred query is to execute some code after a delay.
  /// In addition, any calculations done at the beginning might be based on an
  /// obsolete state by the time onResponse gets called.   Instead, you want to
  /// do your calculations on the state you are handed on [finishAsyncExecute]
  void startAsync(AFStartQueryContext<AFUnused> context) {
    print("Starting period with delay $delay");
    timer = Timer.periodic(delay, (_) {
      AFibD.logQueryAF?.d("Executing finishAsyncExecute for deferred query $this");
      context.onSuccess(AFUnused.unused);
    });
  }

  /// Calls the more appropriate [finishAsyncExecute] when the [initialDelay] associated with this
  /// query has expired.
  void finishAsyncWithResponse(AFFinishQuerySuccessContext<TState, AFUnused> context) {
    keepGoing = finishAsyncExecute(context);
    if(!keepGoing) {
      context.dispatch(AFShutdownPeriodicQueryAction(this.key));
    }      
  }

  bool finishAsyncExecute(AFFinishQuerySuccessContext<TState, AFUnused> context);

  void afShutdown() {
    if(timer != null) {
      AFibD.logQueryAF?.d("Shutting down deferred query $this");
      timer?.cancel();
      timer = null;
      shutdown();
    }
  }

  /// Returns the new query, causing any existing query to be shutdown and replaced with the new one
  AFTrackedQuery? mergeWith(AFTrackedQuery newQuery) {
    return newQuery;
  }

  void shutdown();

  AFFinishQuerySuccessContext<TState, AFUnused> createSuccessContext({
    required AFDispatcher dispatcher, 
    required AFState state, 
  }) {
    return AFFinishQuerySuccessContext<TState, AFUnused>(    
      conceptualStore: conceptualStore,
      response: AFUnused(),
    );
  }

}

/// A deferred query which waits a specified duration, then calls its onSuccessDelegate,
/// but does not otherwise do anything.
class AFDeferredSuccessQuery<TState extends AFFlexibleState> extends AFDeferredQuery<TState> {

  AFDeferredSuccessQuery(AFID id, Duration delayOnce, AFOnResponseDelegate<TState, AFUnused> onSuccessDelegate): super(delayOnce, id: id, onSuccessDelegate: onSuccessDelegate);
  Duration? finishAsyncExecute(AFFinishQuerySuccessContext<TState, AFUnused> context) {
    final onSuccessD = this.onSuccessDelegate;
    if(onSuccessD != null) {
      onSuccessD(context);
    }
    return null;
  }

  /// Returns the existing query, dropping the new query.
  AFTrackedQuery mergeWith(AFTrackedQuery newQuery) {
    return this;
  }

  void shutdown() {

  }

}




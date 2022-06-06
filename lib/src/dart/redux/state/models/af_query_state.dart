

import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/actions/af_deferred_query.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

class AFQueryState {
  final Map<String, AFAsyncListenerQuery?> listenerQueries;
  final Map<String, AFDeferredQuery> deferredQueries;
  final Map<String, AFPeriodicQuery> periodicQueries;

  AFQueryState({
    required this.listenerQueries,
    required this.deferredQueries,
    required this.periodicQueries,
  });


  factory AFQueryState.initialState() {
    return AFQueryState(
      listenerQueries: <String, AFAsyncListenerQuery>{},
      deferredQueries: <String, AFDeferredQuery>{},
      periodicQueries: <String, AFPeriodicQuery>{},
    );
  }

  AFQueryState copyWith({
    Map<String, AFAsyncListenerQuery?>? listenerQueries,
    Map<String, AFDeferredQuery>? deferredQueries,
    Map<String, AFPeriodicQuery>? periodicQueries,
  }) {
    return AFQueryState(
      listenerQueries: listenerQueries ?? this.listenerQueries,
      deferredQueries: deferredQueries ?? this.deferredQueries,
      periodicQueries: periodicQueries ?? this.periodicQueries,
    );
  }

  /// Register an ongoing listener query which must eventually be shut down.  
  /// 
  /// This is used internally by AFib anytime you dispatch a listener query,
  /// you should not call it directly.
  AFQueryState reviseAddListener(AFAsyncListenerQuery query) {
    final revised = Map<String, AFAsyncListenerQuery>.from(listenerQueries);
    final key = query.key;
    AFibD.logQueryAF?.d("Registering listener query $key");
    final current = listenerQueries[key];
    if(current != null) {
      AFibD.logQueryAF?.d("Shutting down previous listener with key $key");
      current.afShutdown();
    }
    revised[key] = query;
    return copyWith(listenerQueries: revised);
  }

  AFTrackedQuery? findTrackedByQueryId(String id) {
    dynamic result = listenerQueries[id];
    if(result == null) {
      result = deferredQueries[id];
      if(result == null) {
        result = periodicQueries[id];
      }
    }
    return result as AFTrackedQuery?;
  }

  /// Register a query which executes asynchronously later.
  /// 
  /// This is used internally by AFib anytime you dispatch a deferred query,
  /// you should not call it directly.
  AFQueryState reviseAddDeferred(AFDeferredQuery query) {
    final key = query.key;
    AFibD.logQueryAF?.d("Registering deferred query $key");
    final current = deferredQueries[key];
    if(current != null) {
      AFibD.logQueryAF?.d("Shutting down existing deferred query $key");
      current.afShutdown(null);
    }
    final revised = Map<String, AFDeferredQuery>.from(deferredQueries);
    revised[key] = query; 
    return copyWith(deferredQueries: revised);
  }

  /// Register a query which executes asynchronously later.
  /// 
  /// This is used internally by AFib anytime you dispatch a deferred query,
  /// you should not call it directly.
  AFQueryState reviseAddPeriodic(AFPeriodicQuery query) {
    final key = query.key;
    AFibD.logQueryAF?.d("Registering periodic query $key");
    final current = periodicQueries[key];
    if(current != null) {
      AFibD.logQueryAF?.d("Shutting down existing deferred query $key");
      current.afShutdown();
    }
    final revised = Map<String, AFPeriodicQuery>.from(periodicQueries);
    revised[key] = query; 
    return copyWith(periodicQueries: revised);
  }


  AFQueryState reviseShutdownDeferred(String key) {
    final query = deferredQueries[key];
    if(query != null) {
      AFibD.logQueryAF?.d("Shutting down existing deferred query $key");
      query.afShutdown(null);
    }

    final revised = Map<String, AFDeferredQuery>.from(deferredQueries);
    revised.remove(key);
    return copyWith(deferredQueries: revised);
  }

  AFQueryState reviseShutdownListener(String key) {
    final query = listenerQueries[key];
    if(query != null) {
      AFibD.logQueryAF?.d("Shutting down existing deferred listener $key");
      query.afShutdown();
    }

    final revised = Map<String, AFAsyncListenerQuery>.from(listenerQueries);
    revised.remove(key);
    return copyWith(listenerQueries: revised);
  }

  AFQueryState reviseShutdownPeriodic(String key) {
    final query = periodicQueries[key];
    if(query != null) {
      AFibD.logQueryAF?.d("Shutting down existing deferred listener $key");
      query.afShutdown();
    }

    final revised = Map<String, AFPeriodicQuery>.from(periodicQueries);
    revised.remove(key);
    return copyWith(periodicQueries: revised);
  }


  /// Shutdown all outstanding listener queries using [AFAsyncListenerQuery.shutdown]
  /// 
  /// You might use this to shut down outstanding listener queries when a user logs out.
  AFQueryState shutdownOutstandingQueries() {
    for(var query in listenerQueries.values) { 
      query?.afShutdown();
    }

    for(var query in deferredQueries.values) {
      query.afShutdown(null);
    }
    return AFQueryState.initialState();
  }

  /// Shutdown a single outstanding listener query using [AFAsyncListenerQuery.shutdown]
  void shutdownListenerQuery(String key) {
    final query = listenerQueries[key];
    if(query != null) {
      query.shutdown();
      listenerQueries[key] = null;
    }
  }

  AFAsyncListenerQuery? findListenerQueryById(String key) {
    return listenerQueries[key];
  }

}

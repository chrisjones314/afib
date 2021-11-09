import 'package:afib/src/dart/redux/actions/af_always_fail_query.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/actions/af_deferred_query.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_route_state.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/redux/state/af_theme_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_query_error.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';

abstract class AFStateTestExecute extends AFBaseTestExecute {

  AFStateTestExecute();
  
}

class AFStateTestDifference {
  final AFState afStateBefore;
  final AFState afStateAfter;
  AFStateTestDifference({
    required this.afStateBefore,
    required this.afStateAfter,
  });

  TAppState stateBefore<TAppState extends AFAppStateArea>() {
    return _findAppState(afStateBefore)!;
  }

  TAppState stateAfter<TAppState extends AFAppStateArea>() {
    return _findAppState(afStateAfter)!;
  }

  TAppTheme? themeBefore<TAppTheme extends AFFunctionalTheme>(AFThemeID themeId) {
    return _findAppTheme(afStateBefore, themeId);
  }

  TAppTheme? themeAfter<TAppTheme extends AFFunctionalTheme>(AFThemeID themeId) {
    return _findAppTheme(afStateAfter, themeId);
  }

  AFRouteState get routeBefore {
    return _routeFor(afStateBefore);
  }

  AFRouteState get routeAfter {
    return _routeFor(afStateAfter);
  }

  TAppState? _findAppState<TAppState extends AFAppStateArea>(AFState state) {
    final areas = state.public.areas;
    return areas.stateFor(TAppState) as TAppState;
  }

  TAppTheme? _findAppTheme<TAppTheme extends AFFunctionalTheme>(AFState state, AFThemeID themeId) {
    final themes = state.public.themes;
    return themes.findById(themeId) as TAppTheme;
  }

  AFRouteState _routeFor(AFState state) {
    return state.public.route.cleanTestRoute();
  }
}

class AFStateTestContext<TState extends AFAppStateArea> extends AFStateTestExecute {
  AFStateTest test;
  final AFStore store;
  AFDispatcher dispatcher;
  static AFStateTestContext? currentTest;
  final bool isTrueTestContext;
  
  AFStateTestContext(this.test, this.store, this.dispatcher, { required this.isTrueTestContext} );

  AFStateTestID get testID { return this.test.id; }
  AFState get afState { return store.state; }
  TState? get state { return store.state.public.areaStateFor(TState) as TState; }
  AFRouteState get route { return store.state.public.route; }

  void processQuery(AFAsyncQuery q) {
    AFibD.logQueryAF?.d("Processing ${q.runtimeType} for test $testID");
    test.processQuery(this, q);
  }
}

class AFStateTests<TState extends AFAppStateArea> {
  final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
  final List<AFStateTest<dynamic>> tests = <AFStateTest<dynamic>>[];
  AFStateTestContext<dynamic>? context;

  void addTest(AFStateTestID id, AFProcessTestDelegate handler) {
    final test = AFStateTest<TState>(id, this);
    tests.add(test);
    handler(test);
  }

  AFStateTest? findById(AFStateTestID id) {
    for(var test in tests) {
      if(test.id == id) {
        return test as AFStateTest;
      }
    }
    return null;
  }
}

class _AFStateResultEntry {
  final dynamic querySpecifier;
  final AFProcessQueryDelegate? handler;
  final Map<String, AFProcessQueryDelegate?>? crossHandlers;
  _AFStateResultEntry(
    this.querySpecifier,
    this.handler,
    this.crossHandlers,
  );

  _AFStateResultEntry reviseAddCross(String specifier, AFProcessQueryDelegate? handler) {
    final orig = crossHandlers;
    final cross = (orig == null) ? <String, AFProcessQueryDelegate?>{} : Map<String, AFProcessQueryDelegate?>.from(orig);
    cross[specifier] = handler;
    return copyWith(crossHandlers: cross);
  }

  _AFStateResultEntry copyWith({
    AFProcessQueryDelegate? handler,
    Map<String, AFProcessQueryDelegate?>? crossHandlers
  }) {
    return _AFStateResultEntry(
      querySpecifier,
      handler ?? this.handler,
      crossHandlers ?? this.crossHandlers,
    );
  }

}

class _AFStateQueryBody {
  final AFAsyncQuery query;
  final AFProcessVerifyDifferenceDelegate? verify;
  _AFStateQueryBody(this.query, this.verify);
}

class AFStateTest<TState extends AFAppStateArea> {
  final AFStateTests<TState> tests;
  final AFStateTestID id;
  AFStateTestID? idPredecessor;
  final Map<String, _AFStateResultEntry> results = <String, _AFStateResultEntry>{};
  final List<_AFStateQueryBody> queryBodies = <_AFStateQueryBody>[];

  AFStateTest(this.id, this.tests) {
    registerResult(AFAlwaysFailQuery, (context, query) {
      query.testFinishAsyncWithError(context, AFQueryError(message: "Always fail in state test"));
    });
    if(TState.runtimeType == AFAppStateArea) {
      throw AFException("You must explicitly specify your app state on AFStateTest instances");
    }
  }

  void extendsTest(AFStateTestID idTest) {
    idPredecessor = idTest;
    final test = tests.findById(idTest);
    if(test != null) {
      this.results.addAll(test.results);
    }
  }

  void initializeVerifyFrom(AFStateTestID idTest) {
    final test = tests.findById(idTest);
    if(test != null) {
      queryBodies.addAll(test.queryBodies);
    }
  }
    
  void registerResult(dynamic querySpecifier, AFProcessQueryDelegate? handler) {
    _registerHandler(querySpecifier, handler);
  }

  void registerCrossResult(dynamic querySpecifier, dynamic listenerSpecifier, AFProcessQueryDelegate? handler) {
    final key = _specifierToId(querySpecifier);
    var result = results[key];
    if(result == null) {
      result = _AFStateResultEntry(querySpecifier, null, null);
      results[key] = result;
    }
    final listenerId = _specifierToId(listenerSpecifier);
    results[key] = result.reviseAddCross(listenerId, handler);
  }

  void _registerHandler(dynamic querySpecifier, AFProcessQueryDelegate? handler) {
    final key = _specifierToId(querySpecifier);
    var result = results[key];
    if(result == null) {
      result = _AFStateResultEntry(querySpecifier, handler, null);
      results[key] = result;
    } 
    results[key] = result.copyWith(handler: handler);
  }

  String _specifierToId(dynamic querySpecifier) {
    if(querySpecifier is AFID) {
      return querySpecifier.code;
    } else if(querySpecifier is Type) {
      return querySpecifier.toString();
    } else if(querySpecifier is AFAsyncQuery) {
      final qsId = querySpecifier.id;
      if(qsId != null) {
        return qsId.code;
      }
      return querySpecifier.runtimeType.toString();
    }
    throw AFException("Unknown query specifier type ${querySpecifier.runtimeType}");
  }

  /// 
  void specifyResponse(dynamic querySpecifier, AFStateTestDefinitionContext definitions, dynamic idData) {
    registerResult(querySpecifier, (context, query) {
      final data = definitions.td(idData);
      query.testFinishAsyncWithResponse(context, data);
      return data;
    });
  }

  void specifyNoResponse(dynamic querySpecifier, AFStateTestDefinitionContext definitions) {
    _registerHandler(querySpecifier, null);
  }

  void createResponse(dynamic querySpecifier, AFCreateQueryResultDelegate delegate) {
    registerResult(querySpecifier, (context, query) {
      final result = delegate(context, query);
      query.testFinishAsyncWithResponse(context, result);
      return result;
    });
  }

  void createCrossQueryResponse(dynamic querySpecifier, dynamic listenerSpecifier, List<AFCreateQueryResultDelegate> delegates) {
    registerResult(querySpecifier, (context, query) {
      final listenerId = _specifierToId(listenerSpecifier);
      final listenerQuery = AFibF.g.findListenerQueryById(listenerId);

      if(listenerQuery == null) {
        return;
      }

      var result;
      for(final delegate in delegates) {
        result = delegate(context, query);
        // in this case, we don't send the result to the original query, but rather a
        // listener query they specified
        listenerQuery.testFinishAsyncWithResponse(context, result);
      }
      return result;
    });
  }

  void specifySecondaryError(dynamic querySpecifier, dynamic error) {
    registerResult(querySpecifier, (context, query) {
      query.testFinishAsyncWithError(context, error);
      return null;
    });
  }

  void executeQuery(AFAsyncQuery query, {
    AFProcessVerifyDifferenceDelegate? verifyState
  }) {
    queryBodies.add(_AFStateQueryBody(query, verifyState));
  }

  /// Execute the test by kicking of its queries, then 
  void execute(AFStateTestContext context, { bool shouldVerify = true }) {    
    AFStateTestContext.currentTest = context;
  
    // first, execute an predecessor tests.
    final idPred = idPredecessor;
    if(idPred != null) {
      final test = tests.findById(idPred);
      test?.execute(context, shouldVerify: false);
    }

    // basically, we need to go through an execute each query that they specified.
    for(final q in queryBodies) {
      final stateBefore = context.afState;
      processQuery(context, q.query);

      // lookup the result for that query
      AFStateTestExecute e = context;
      if(shouldVerify) {
        final diff = AFStateTestDifference(
          afStateBefore: stateBefore,
          afStateAfter: context.afState,
        );
        q.verify?.call(e, diff);
      }
    }
  }

  /// Process a query by looking up the results we have for that query,
  /// and then feeding them to its testAsyncResponse method.
  void processQuery(AFStateTestContext context, AFAsyncQuery query) {
    final key = _specifierToId(query);
    var h = results[key];
    if(h == null) {
      /// Ummm, this might be a good place to admit that sometimes the type system
      /// in Dart vexes me.
      if(key.toString().startsWith("AFAlwaysFailQuery")) {
        h = results["AFAlwaysFailQuery<AFAppStateAreaUnused>"];
      }
    }
    if(h == null) {
      /// deferred queries don't have any results.
      if(query is AFDeferredQuery) {
        final successContext = query.createSuccessContext(
          dispatcher: context.dispatcher,
          state: context.afState
        );

        query.finishAsyncExecute(successContext);
        return;
      }

      if(query is AFConsolidatedQuery) {
        final successContext = AFFinishQuerySuccessContext<TState, AFConsolidatedQueryResponse>(
          dispatcher: context.dispatcher,
          state: context.store.state,
          response: query.queryResponses
        );
        for(final consolidatedQueries in query.queryResponses.responses) {
          final consolidatedQuery = consolidatedQueries.query;
          final consolidatedKey = _specifierToId(consolidatedQuery);
          final consolidatedHandler = results[consolidatedKey];
          if(consolidatedHandler != null) {
            consolidatedQueries.result = consolidatedHandler.handler?.call(context, consolidatedQuery);
          }

        }
        query.finishAsyncWithResponseAF(successContext);
        return;
      }
    
      throw AFException("No results specified for query ${_specifierToId(query)}");
    }

    final handler = h.handler;
    if(handler != null) {
      handler(context, query);
    }
  }
}
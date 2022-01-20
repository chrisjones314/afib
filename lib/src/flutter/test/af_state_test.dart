import 'package:afib/src/dart/redux/actions/af_always_fail_query.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/actions/af_deferred_query.dart';
import 'package:afib/src/dart/redux/queries/af_time_update_listener_query.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/redux/state/models/af_route_state.dart';
import 'package:afib/src/dart/redux/state/models/af_theme_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_query_error.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
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

  TAppState stateBefore<TAppState extends AFFlexibleState>() {
    return _findComponentState(afStateBefore)!;
  }

  TAppState stateAfter<TAppState extends AFFlexibleState>() {
    return _findComponentState(afStateAfter)!;
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

  TComponentState? _findComponentState<TComponentState extends AFFlexibleState>(AFState state) {
    final areas = state.public.components;
    return areas.stateFor(TComponentState) as TComponentState;
  }

  TAppTheme? _findAppTheme<TAppTheme extends AFFunctionalTheme>(AFState state, AFThemeID themeId) {
    final themes = state.public.themes;
    return themes.findById(themeId) as TAppTheme;
  }

  AFRouteState _routeFor(AFState state) {
    return state.public.route.cleanTestRoute();
  }
}

class AFStateTestContext<TState extends AFFlexibleState> extends AFStateTestExecute {
  AFStateTest test;
  final AFStore store;
  AFDispatcher dispatcher;
  static AFStateTestContext? currentTest;
  final bool isTrueTestContext;
  
  AFStateTestContext(this.test, this.store, this.dispatcher, { required this.isTrueTestContext} );

  AFStateTestID get testID { return this.test.id; }
  AFState get afState { return store.state; }
  TState? get state { return store.state.public.componentStateOrNull<TState>(); }
  AFRouteState get route { return store.state.public.route; }
  AFPublicState get public { return store.state.public; }

  void processQuery(AFAsyncQuery q) {
    AFibD.logQueryAF?.d("Processing ${q.runtimeType} for test $testID");
    AFStateTest.processQuery(this, q);
  }
}

class AFStateTests<TState extends AFFlexibleState> {
  final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
  final List<AFStateTest<dynamic>> tests = <AFStateTest<dynamic>>[];
  AFStateTestContext<dynamic>? context;

  void addTest(AFStateTestID id, AFStateTestDefinitionsContext definitions, AFStateTestDefinitionDelegate handler) {
    final test = AFStateTest<TState>(id, this);
    tests.add(test);
    final defContext = AFStateTestDefinitionContext(definitions, test);
    handler(defContext);
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

abstract class _AFStateExecutionBody {
  final AFProcessVerifyDifferenceDelegate? verify;
  _AFStateExecutionBody(this.verify);

  void execute(AFStateTestContext context);

}

class _AFStateScreenBody<TSPI extends AFStateProgrammingInterface> extends _AFStateExecutionBody {
  final AFScreenID screenId;
  final AFStateTestScreenHandlerDelegate<TSPI> screenHandler;

  _AFStateScreenBody(
    this.screenId,
    this.screenHandler,
    AFProcessVerifyDifferenceDelegate? verify
  ): super(verify);  

  void execute(AFStateTestContext context) {
    final screen = AFibF.g.screenMap.createInstance(screenId, null);
    final context = AFStateTestScreenContext<TSPI>(screen: screen);
    screenHandler(context);
  }
}

class _AFStateQueryBody extends _AFStateExecutionBody {
  final List<AFAsyncQuery> queries;
  _AFStateQueryBody(this.queries, AFProcessVerifyDifferenceDelegate? verify): super(verify);

  factory _AFStateQueryBody.fromOne(
    AFAsyncQuery query,
    { AFProcessVerifyDifferenceDelegate? verify }
  ) {
    final queries = [query];
    return _AFStateQueryBody(queries, verify);
  }

  void execute(AFStateTestContext context) {
    for(final query in queries) {
      AFStateTest.processQuery(context, query);
    }
  }
}

class AFStateTestScreenContext<TSPI extends AFStateProgrammingInterface> {
  final AFConnectedUIBase screen;
  AFStateTestScreenContext({
    required this.screen,
  });

  void executeBuild(AFStateTestScreenBuildContextDelegate<TSPI> delegate) {
    final context = screen.createNonBuildContext(AFibF.g.storeInternalOnly!);
    if(context == null) {
      assert(false);
      return;
    }
    final spi = screen.createSPI(context) as TSPI;
    delegate(spi);
  }
}

class AFStateTestDefinitionContext<TState extends AFFlexibleState> {
  final AFStateTestDefinitionsContext definitions;
  final AFStateTest<TState> test;
  AFStateTestDefinitionContext(this.definitions, this.test);


  /// Specify a response for a particular query.
  /// 
  /// When the query 'executes', its [AFAsyncQuery.startAsync] method will be skipped
  /// and its [AFAsyncQuery.finishAsyncWithResponse] method will be called with the 
  /// test data with the specified [idData] in the test data registry.
  void defineQueryResponseFixed(dynamic querySpecifier, dynamic idData) {
    test.specifyResponse(querySpecifier, definitions, idData);
  }

  void defineExtendTest(AFStateTestID testId) {
    test.extendsTest(testId);
  }

  void defineExtendTestVerification(AFStateTestID idTest) {
    test.initializeVerifyFrom(idTest);
  }


  void defineQueryResponseNone(dynamic querySpecifier) {
    test.specifyNoResponse(querySpecifier, definitions);
  }

  void executeStartup({
    AFProcessVerifyDifferenceDelegate? verify
  }) {
    test.executeStartup(verifyState: verify);
  }


  /// Create a response dynamically for a particular query.
  /// 
  /// This method is useful when you have query methods which 'write' data, where often
  /// the data doesn't change at all when it is writen, or the changes are simple (like 
  /// a new identifier is returned, or the update-timestamp for the data is created by the server).
  /// Using this method, in many cases you can cause 'workflow' prototypes to behave very much
  /// like they have a back end server, despite the fact that they do not.
  /// 
  /// When the query 'executes', its [AFAsyncQuery.startAsync] method will be skipped
  /// and its [AFAsyncQuery.finishAsyncWithResponse] method will be called with the 
  /// test data that is created by [delegate].
  void defineQueryResponseDynamic(dynamic querySpecifier, AFCreateQueryResultDelegate delegate) {
    test.createResponse(querySpecifier, delegate);
  }

  void specifyDynamicCrossQueryResponse(dynamic querySpecifier, dynamic listenerSpecifier, List<AFCreateQueryResultDelegate> delegates) {
    test.createCrossQueryResponse(querySpecifier, listenerSpecifier, delegates);
  }

  /// Use this method to execute a query and validate the state change which it causes.
  void executeQuery(AFAsyncQuery query, {
    AFProcessVerifyDifferenceDelegate? verify
  }) {
    test.executeQuery(query, verifyState: verify);
  }

  void executeScreen<TSPI extends AFStateProgrammingInterface>(AFScreenID screenId, AFStateTestScreenHandlerDelegate<TSPI> screenHandler, {
    AFProcessVerifyDifferenceDelegate? verify
  }) {
    test.executeScreen<TSPI>(screenId, screenHandler, verifyState: verify);
  }


}

class AFStateTest<TState extends AFFlexibleState> {
  final AFStateTests<TState> tests;
  final AFStateTestID id;
  AFStateTestID? idPredecessor;
  final Map<String, _AFStateResultEntry> results = <String, _AFStateResultEntry>{};
  final List<_AFStateExecutionBody> executionBodies = <_AFStateExecutionBody>[];

  AFStateTest(this.id, this.tests) {
    registerResult(AFAlwaysFailQuery, (context, query) {
      query.testFinishAsyncWithError(context, AFQueryError(message: "Always fail in state test"));
    });
    if(TState.runtimeType == AFFlexibleState) {
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
      executionBodies.addAll(test.executionBodies);
    }
  }
    
  void registerResult(dynamic querySpecifier, AFProcessQueryDelegate? handler) {
    _registerHandler(querySpecifier, handler);
  }

  void registerCrossResult(dynamic querySpecifier, dynamic listenerSpecifier, AFProcessQueryDelegate? handler) {
    final key = specifierToId(querySpecifier);
    var result = results[key];
    if(result == null) {
      result = _AFStateResultEntry(querySpecifier, null, null);
      results[key] = result;
    }
    final listenerId = specifierToId(listenerSpecifier);
    results[key] = result.reviseAddCross(listenerId, handler);
  }

  void _registerHandler(dynamic querySpecifier, AFProcessQueryDelegate? handler) {
    final key = specifierToId(querySpecifier);
    var result = results[key];
    if(result == null) {
      result = _AFStateResultEntry(querySpecifier, handler, null);
      results[key] = result;
    } 
    results[key] = result.copyWith(handler: handler);
  }

  static String specifierToId(dynamic querySpecifier) {
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
  
  /// Process a query by looking up the results we have for that query,
  /// and then feeding them to its testAsyncResponse method.
  static void processQuery<TState extends AFFlexibleState>(AFStateTestContext context, AFAsyncQuery query) {
    final key = AFStateTest.specifierToId(query);
    final results = context.test.results;

    var h = results[key];
    if(h == null) {
      /// Ummm, this might be a good place to admit that sometimes the type system
      /// in Dart vexes me.
      if(key.toString().startsWith("AFAlwaysFailQuery")) {
        h = results["AFAlwaysFailQuery<AFAppStateAreaUnused>"];
      }
    }

    if(h == null) {
      if(query is AFTimeUpdateListenerQuery) {
        query.startAsyncAF(context.dispatcher, context.store);
        return;
      }
    
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
          final consolidatedKey = AFStateTest.specifierToId(consolidatedQuery);
          final consolidatedHandler = results[consolidatedKey];
          if(consolidatedHandler != null) {
            consolidatedQueries.result = consolidatedHandler.handler?.call(context, consolidatedQuery);
          }

        }
        query.finishAsyncWithResponseAF(successContext);
        return;
      }
    
      throw AFException("No results specified for query ${AFStateTest.specifierToId(query)}");
    }

    final handler = h.handler;
    if(handler != null) {
      handler(context, query);
    }
  }  

  /// 
  void specifyResponse(dynamic querySpecifier, AFStateTestDefinitionsContext definitions, dynamic idData) {
    registerResult(querySpecifier, (context, query) {
      final data = definitions.td(idData);
      query.testFinishAsyncWithResponse(context, data);
      return data;
    });
  }

  void specifyNoResponse(dynamic querySpecifier, AFStateTestDefinitionsContext definitions) {
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
      final listenerId = specifierToId(listenerSpecifier);
      final listenerQuery = AFibF.g.storeInternalOnly?.state.public.queries.findListenerQueryById(listenerId);

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

  void executeStartup({
    AFProcessVerifyDifferenceDelegate? verifyState
  }) {
    final queries = AFibF.g.createStartupQueries().toList();
    executionBodies.add(_AFStateQueryBody(queries, verifyState));
  }

  void executeQuery(AFAsyncQuery query, {
    AFProcessVerifyDifferenceDelegate? verifyState
  }) {
    executionBodies.add(_AFStateQueryBody.fromOne(query, verify: verifyState));
  }

  void executeScreen<TSPI extends AFStateProgrammingInterface>(AFScreenID screenId, AFStateTestScreenHandlerDelegate<TSPI> screenHandler, {
    AFProcessVerifyDifferenceDelegate? verifyState
  }) {
    executionBodies.add(_AFStateScreenBody<TSPI>(screenId, screenHandler, verifyState));
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
    for(final eb in executionBodies) {
      final stateBefore = context.afState;
      eb.execute(context);

      // lookup the result for that query
      AFStateTestExecute e = context;
      if(shouldVerify) {
        final diff = AFStateTestDifference(
          afStateBefore: stateBefore,
          afStateAfter: context.afState,
        );
        eb.verify?.call(e, diff);
      }
    }
  }


}
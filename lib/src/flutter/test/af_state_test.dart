import 'package:afib/afib_dart.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_theme_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/state/af_route_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/utils/af_id.dart';

abstract class AFStateTestExecute extends AFBaseTestExecute {

  AFStateTestExecute();
  
}

class AFStateTestDifference {
  final AFState afStateBefore;
  final AFState afStateAfter;
  AFStateTestDifference({
    @required this.afStateBefore,
    @required this.afStateAfter,
  });

  TAppState stateBefore<TAppState extends AFAppStateArea>() {
    return _findAppState(afStateBefore);
  }

  TAppState stateAfter<TAppState extends AFAppStateArea>() {
    return _findAppState(afStateAfter);
  }

  TAppTheme themeBefore<TAppTheme extends AFConceptualTheme>() {
    return _findAppTheme(afStateBefore);
  }

  TAppTheme themeAfter<TAppTheme extends AFConceptualTheme>() {
    return _findAppTheme(afStateAfter);
  }

  AFRouteState get routeBefore {
    return _routeFor(afStateBefore);
  }

  AFRouteState get routeAfter {
    return _routeFor(afStateAfter);
  }

  TAppState _findAppState<TAppState extends AFAppStateArea>(AFState state) {
    final areas = state.public.areas;
    return areas.stateFor(TAppState);
  }

  TAppTheme _findAppTheme<TAppTheme extends AFConceptualTheme>(AFState state) {
    final themes = state.public.themes;
    return themes.findByType(TAppTheme);
  }

  AFRouteState _routeFor(AFState state) {
    return state.public.route.cleanTestRoute();
  }
}

class AFStateTestContext<TState extends AFAppStateArea> extends AFStateTestExecute {
  AFStateTest test;
  final AFStore store;
  final AFDispatcher dispatcher;
  static AFStateTestContext currentTest;
  final bool isTrueTestContext;
  
  AFStateTestContext(this.test, this.store, this.dispatcher, { @required this.isTrueTestContext} );

  AFStateTestID get testID { return this.test.id; }
  AFState get afState { return store.state; }
  TState get state { return store.state.public.areaStateFor(TState); }
  AFRouteState get route { return store.state.public.route; }

  void processQuery(AFAsyncQuery q) {
    test.processQuery(this, q);
  }
}

class AFStateTests<TState extends AFAppStateArea> {
  final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
  final List<AFStateTest<dynamic>> tests = <AFStateTest<dynamic>>[];
  AFStateTestContext<dynamic> context;

  void addTest(AFStateTestID id, AFProcessTestDelegate handler) {
    final test = AFStateTest<TState>(id, this);
    tests.add(test);
    handler(test);
  }

  AFStateTest findById(AFStateTestID id) {
    for(var test in tests) {
      if(test.id == id) {
        return test;
      }
    }
    return null;
  }
}

class _AFStateResultEntry {
  final dynamic querySpecifier;
  final AFProcessQueryDelegate handler;
  _AFStateResultEntry(this.querySpecifier, this.handler);
}

class _AFStateQueryBody {
  final AFAsyncQuery query;
  final AFProcessVerifyDifferenceDelegate verify;
  _AFStateQueryBody(this.query, this.verify);
}

class AFStateTest<TState extends AFAppStateArea> {
  final AFStateTests<TState> tests;
  final AFStateTestID id;
  AFStateTestID idPredecessor;
  final Map<String, _AFStateResultEntry> results = <String, _AFStateResultEntry>{};
  final List<_AFStateQueryBody> queryBodies = <_AFStateQueryBody>[];

  AFStateTest(this.id, this.tests) {
    if(TState.runtimeType == AFAppStateArea) {
      throw AFException("You must explicitly specify your app state on AFStateTest instances");
    }
  }

  void extendsTest(AFStateTestID idTest) {
    idPredecessor = idTest;
    final test = tests.findById(idTest);
    this.results.addAll(test.results);
  }

  void initializeVerifyFrom(AFStateTestID idTest) {
    final test = tests.findById(idTest);
    queryBodies.addAll(test.queryBodies);
  }
    
  void registerResult(dynamic querySpecifier, AFProcessQueryDelegate handler) {
    final key = _specifierToId(querySpecifier);
    results[key] = _AFStateResultEntry(querySpecifier, handler);
  }

  String _specifierToId(dynamic querySpecifier) {
    if(querySpecifier is AFID) {
      return querySpecifier.code;
    } else if(querySpecifier is Type) {
      return querySpecifier.toString();
    } else if(querySpecifier is AFAsyncQuery) {
      if(querySpecifier.id != null) {
        return querySpecifier.id.code;
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
    });
  }

  void createResponse(dynamic querySpecifier, AFCreateQueryResultDelegate delegate) {
    registerResult(querySpecifier, (context, query) {
      final result = delegate(context, query);
      query.testFinishAsyncWithResponse(context, result);
    });
  }

  void specifySecondaryError(dynamic querySpecifier, dynamic error) {
    registerResult(querySpecifier, (context, query) {
      query.testFinishAsyncWithError(context, error);
    });
  }

  void executeQuery(AFAsyncQuery query, {
    AFProcessVerifyDifferenceDelegate verifyState
  }) {
    queryBodies.add(_AFStateQueryBody(query, verifyState));
  }

  /// Execute the test by kicking of its queries, then 
  void execute(AFStateTestContext context, { bool shouldVerify = true }) {    
    AFStateTestContext.currentTest = context;
  
    // first, execute an predecessor tests.
    if(idPredecessor != null) {
      final test = tests.findById(idPredecessor);
      test.execute(context, shouldVerify: false);
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
        q?.verify(e, diff);
      }
    }
  }

  /// Process a query by looking up the results we have for that query,
  /// and then feeding them to its testAsyncResponse method.
  void processQuery(AFStateTestContext context, AFAsyncQuery query) {
    final key = _specifierToId(query);
    final h = results[key];
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

      throw AFException("No results specified for query ${_specifierToId(query)}");
    }

    h.handler(context, query);
  }
}
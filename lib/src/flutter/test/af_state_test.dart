import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/actions/af_always_fail_query.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/actions/af_deferred_query.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/redux/actions/af_time_actions.dart';
import 'package:afib/src/dart/redux/queries/af_time_update_listener_query.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/redux/state/models/af_route_state.dart';
import 'package:afib/src/dart/redux/state/models/af_theme_state.dart';
import 'package:afib/src/dart/redux/state/models/af_time_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_query_error.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_stats.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/utils/af_dispatcher.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart' as ft;

abstract class AFStateTestExecute extends AFBaseTestExecute {

  AFStateTestExecute();
  
}

class AFStateTestStateVerificationContext {
  final AFState afState;
  AFStateTestStateVerificationContext({
    required this.afState,
  });

  TAppState stateApp<TAppState extends AFFlexibleState>() {
    return _findComponentState<TAppState>(afState);
  }

  TAppTheme? theme<TAppTheme extends AFFunctionalTheme>(AFThemeID themeId) {
    return _findAppTheme(afState, themeId);
  }

  AFRouteState get route {
    return _routeFor(afState);
  }

  AFPublicState get public {
    return afState.public;
  }

  TComponentState _findComponentState<TComponentState extends AFFlexibleState>(AFState state) {
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
  
  AFStateTestContext(this.test, this.store, this.dispatcher, { required this.isTrueTestContext } );

  AFStateTestID get testID { return this.test.id; }
  AFState get afState { return store.state; }
  TState? get state { return store.state.public.componentStateOrNull<TState>(); }
  AFRouteState get route { return store.state.public.route; }
  AFPublicState get public { return store.state.public; }

  void processQuery(AFAsyncQuery q) {
    AFibD.logQueryAF?.d("Processing ${q.runtimeType} for test $testID");
    AFStateTest.processQuery(this, q);
  }

  void finishAndUpdateStats(AFTestStats stats) {
    stats.addPasses(errors.pass);
    stats.addErrors(errors.errorCount);
  }
}

class AFStateTests<TState extends AFFlexibleState> {
  final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
  final List<AFStateTest<dynamic>> tests = <AFStateTest<dynamic>>[];
  AFStateTestContext<dynamic>? context;

  void addTest(AFStateTestID id, AFStateTestID? extendTest, AFStateTestDefinitionsContext definitions, AFStateTestDefinitionDelegate handler) {
    final test = AFStateTest<TState>(id, this);
    if(extendTest != null) {
      test.extendsTest(extendTest);
    }
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

abstract class _AFStateTestExecutionStatement {
  _AFStateTestExecutionStatement();

  void execute(AFStateTestContext context, { required bool verify });
}

abstract class _AFStateTestDefinitionStatement {
  _AFStateTestDefinitionStatement();

  void execute(AFStateTestContext context);
}


class _AFStateTestScreenStatement<TSPI extends AFStateProgrammingInterface> extends _AFStateTestExecutionStatement {
  final AFScreenID screenId;
  final AFStateTestScreenHandlerDelegate<TSPI> screenHandler;

  _AFStateTestScreenStatement(
    this.screenId,
    this.screenHandler,
  );

  void execute(AFStateTestContext context, { required bool verify }) {
    final screen = AFibF.g.screenMap.createInstance(screenId, null);
    final ctx = AFStateTestScreenContext<TSPI>(screen: screen);
    screenHandler(context, ctx);
  }
}

class _AFStateTestQueryStatement extends _AFStateTestExecutionStatement {
  final List<AFAsyncQuery> queries;
  _AFStateTestQueryStatement(this.queries);

  factory _AFStateTestQueryStatement.fromOne(
    AFAsyncQuery query
  ) {
    final queries = [query];
    return _AFStateTestQueryStatement(queries);
  }
  void execute(AFStateTestContext context, { required bool verify }) {
    for(final query in queries) {
      AFStateTest.processQuery(context, query);
    }
  }
}

class _AFStateTestStartupStatement extends _AFStateTestQueryStatement {
  _AFStateTestStartupStatement(List<AFAsyncQuery> queries): super(queries);  
}

class _AFStateTestVerifyStatement extends _AFStateTestExecutionStatement {
  final AFStateTestVerifyStateDelegate verifyDelegate;
  _AFStateTestVerifyStatement(this.verifyDelegate);
  void execute(AFStateTestContext context, { required bool verify }) {
    if(!verify) {
      return;
    }
    final verifyContext = AFStateTestStateVerificationContext(afState: AFibF.g.storeInternalOnly!.state);
    verifyDelegate(context, verifyContext);
  }
}

class _AFStateTestAdvanceTimeStatement extends _AFStateTestExecutionStatement {
 final Duration duration;
  _AFStateTestAdvanceTimeStatement(this.duration);
  void execute(AFStateTestContext context, { required bool verify }) {
    if(!verify) {
      return;
    }
    final state = AFibF.g.storeInternalOnly!.state;
    final currentTime = state.public.time;
    final revised = currentTime.reviseAdjustOffset(duration);
    context.dispatcher.dispatch(AFUpdateTimeStateAction(revised));
  }


}

class _AFStateTestSetAbsoluteTimeStatement extends _AFStateTestExecutionStatement {
 final DateTime time;
  _AFStateTestSetAbsoluteTimeStatement(this.time);
  void execute(AFStateTestContext context, { required bool verify }) {
    if(!verify) {
      return;
    }
    final state = AFibF.g.storeInternalOnly!.state;
    final currentTime = state.public.time;
    final revised = currentTime.reviseToAbsoluteTime(this.time);
    context.dispatcher.dispatch(AFUpdateTimeStateAction(revised));
  }


}


class _AFStateRegisterFixedResultStatement extends _AFStateTestDefinitionStatement {
  final Object querySpecifier;
  final AFStateTestDefinitionsContext definitions;
  final Object idData;

  _AFStateRegisterFixedResultStatement(this.querySpecifier, this.definitions, this.idData);

  void execute(AFStateTestContext context) {
    final test = context.test;
    test.registerResult(querySpecifier, (context, query) {
      final data = definitions.td(idData);
      query.testFinishAsyncWithResponse(context, data);
      return data;
    });

  }
}

class _AFStateRegisterDynamicResultStatement extends _AFStateTestDefinitionStatement {
  final Object querySpecifier;
  final AFCreateQueryResultDelegate delegate;
  _AFStateRegisterDynamicResultStatement(this.querySpecifier, this.delegate);

  void execute(AFStateTestContext context) {
    final test = context.test;
    test.registerResult(querySpecifier, (context, query) {
      final result = delegate(context, query);
      query.testFinishAsyncWithResponse(context, result);
      return result;
    });
  }
}

class _AFStateRegisterDynamicCrossQueryResultStatement extends _AFStateTestDefinitionStatement {
  final dynamic querySpecifier; 
  final dynamic listenerSpecifier; 
  final List<AFCreateQueryResultDelegate> delegates;
   _AFStateRegisterDynamicCrossQueryResultStatement(this.querySpecifier, this.listenerSpecifier, this.delegates);

  void execute(AFStateTestContext context) {
    final test = context.test;
    test.registerResult(querySpecifier, (context, query) {
      final listenerId = AFStateTest.specifierToId(listenerSpecifier);
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
}




class _AFStateRegisterNoResultStatement extends _AFStateTestDefinitionStatement {
  final Object querySpecifier;

  _AFStateRegisterNoResultStatement(this.querySpecifier);

  void execute(AFStateTestContext context) {
    final test = context.test;
    test.registerResult(querySpecifier, null);
  }
}

mixin AFExecuteWidgetMixin {
  AFConnectedUIBase get screen;

  void executeWidget<TSPIWidget extends AFStateProgrammingInterface>(AFWidgetID wid, AFCreateConnectedWidgetDelegate create, AFStateTestWidgetHandlerDelegate<TSPIWidget> delegate) {
    final widget = create(screen, wid, useParentParam: false);
    final widgetContext = AFStateTestWidgetContext<TSPIWidget>(widget: widget, screen: screen);
    return delegate(widgetContext);
  }

  void executeWidgetWithExecute<TSPIWidget extends AFStateProgrammingInterface>(AFWidgetID wid, AFCreateConnectedWidgetDelegate create, AFStateTestExecute e, AFStateTestWidgetWithExecuteHandlerDelegate<TSPIWidget> delegate) {
    final widget = create(screen, wid, useParentParam: false);
    final widgetContext = AFStateTestWidgetContext<TSPIWidget>(widget: widget, screen: screen);
    return delegate(e, widgetContext);
  }

  void executeWidgetWithLaunchParam<TSPIWidget extends AFStateProgrammingInterface>(AFRouteParam launchParam, AFCreateConnectedWidgetWithLaunchParamDelegate create, AFStateTestWidgetHandlerDelegate<TSPIWidget> delegate) {
    final widget = create(screen, launchParam);    
    // in this scenario, we need to install the paramter in the state, so that it can be referenced in the future.
    final store = AFibF.g.storeInternalOnly!;
    store.dispatch(AFNavigateSetChildParamAction(screen: screen.parentScreenId, route: screen.parentRoute, param: launchParam, useParentParam: false));
    final widgetContext = AFStateTestWidgetContext<TSPIWidget>(widget: widget, screen: screen);
    return delegate(widgetContext);
  }

  void executeWidgetWithParentParam<TSPIWidget extends AFStateProgrammingInterface>(AFWidgetID wid, AFCreateConnectedWidgetDelegate create, AFStateTestWidgetHandlerDelegate<TSPIWidget> delegate) {
    final widget = create(screen, wid, useParentParam: true);    
    final widgetContext = AFStateTestWidgetContext<TSPIWidget>(widget: widget, screen: screen);
    return delegate(widgetContext);
  }

  void executeWidgetWithParentParamAndExecute<TSPIWidget extends AFStateProgrammingInterface>(AFWidgetID wid, AFCreateConnectedWidgetDelegate create, AFStateTestExecute e, AFStateTestWidgetWithExecuteHandlerDelegate<TSPIWidget> delegate) {
    final widget = create(screen, wid, useParentParam: true);    
    final widgetContext = AFStateTestWidgetContext<TSPIWidget>(widget: widget, screen: screen);
    return delegate(e, widgetContext);
  }

}

class AFStateTestWidgetContext<TSPI extends AFStateProgrammingInterface> with AFExecuteWidgetMixin {
  final AFConnectedUIBase widget;
  final AFConnectedUIBase screen;
  AFStateTestWidgetContext({
    required this.widget,
    required this.screen,
  });

  void executeBuild(AFStateTestScreenBuildContextDelegate<TSPI> delegate) {
    final spi = AFStateTestScreenContext.createSPI<TSPI>(widget);
    return delegate(spi);
  }

  void executeBuildWithExecute(AFStateTestExecute e, AFStateTestScreenBuildWithExecuteContextDelegate<TSPI> delegate) {
    final spi = AFStateTestScreenContext.createSPI<TSPI>(widget);
    delegate(e, spi);
  }


}

class AFStateTestScreenContext<TSPI extends AFStateProgrammingInterface>  with AFExecuteWidgetMixin  {
  final AFConnectedUIBase screen;
  AFStateTestScreenContext({
    required this.screen,
  });


  void executeBuild(AFStateTestScreenBuildContextDelegate<TSPI> delegate) {
    final spi = createSPI<TSPI>(screen);
    delegate(spi);
  }

  void executeBuildWithExecute(AFStateTestExecute e, AFStateTestScreenBuildWithExecuteContextDelegate<TSPI> delegate) {
    final spi = createSPI<TSPI>(screen);
    delegate(e, spi);
  }

  static TSPI createSPI<TSPI extends AFStateProgrammingInterface>(AFConnectedUIBase widget) {
    final context = widget.createNonBuildContext(AFibF.g.storeInternalOnly!);
    if(context == null) {
      throw AFException("Failed to create context");
    }
    return widget.createSPI(context) as TSPI;
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
    test.defineQueryResponse(querySpecifier, definitions, idData);
  }

  void defineQueryResponseNone(dynamic querySpecifier) {
    test.defineQueryResponseNone(querySpecifier, definitions);
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
    test.defineQueryResponseDynamic(querySpecifier, delegate);
  }

  void defineDynamicCrossQueryResponse(Object querySpecifier, Object listenerSpecifier, List<AFCreateQueryResultDelegate> delegates) {
    test.defineDynamicCrossQueryResponse(querySpecifier, listenerSpecifier, delegates);
  }

  void defineInitialTime(Object timeOrId) {
    final time = definitions.td(timeOrId);
    test.defineQueryResponseDynamic(AFUIQueryID.time,  (e, q) {
      if(time is AFTimeState) {
        return time;
      }
      assert(time is DateTime);
      return AFTimeState(
        actualNow: time,
        timeZone: AFTimeZone.local,
        pauseTime: null,
        simulatedOffset: Duration(milliseconds: 0),
        updateFrequency: Duration(minutes: 1000),
        updateSpecificity: AFTimeStateUpdateSpecificity.minute
      );
    });    
  }

  void executeVerifyActiveScreenId(AFScreenID screenId) {
    executeVerifyState((e, verify) {
      final route = verify.route;
      e.expect(route.activeScreenId, ft.equals(screenId));
    });

  }

  void executeStartup() {
    test.executeStartup();
  }

  void executeVerifyState(AFStateTestVerifyStateDelegate verify) {
    test.executeVerifyState(verify);
  }

  void executeAdvanceTime(Duration duration) {
    test.executeAdvanceTime(duration);
  }

  void executeSetAbsoluteTime(DateTime dateTime) {
    test.executeSetAbsoluteTime(dateTime);
  }

  /// Use this method to execute a query and validate the state change which it causes.
  void executeQuery(AFAsyncQuery query) {
    test.executeQuery(query);
  }

  void executeScreen<TSPI extends AFStateProgrammingInterface>(AFScreenID screenId, AFStateTestScreenHandlerDelegate<TSPI> screenHandler) {
    test.executeScreen<TSPI>(screenId, screenHandler);
  }

  void executeScreenWidgetBuild<TSPIWidget extends AFStateProgrammingInterface>(
    AFScreenID screenId, 
    AFWidgetID wid,
    AFCreateConnectedWidgetDelegate createWidget,
    AFStateTestScreenBuildWithExecuteContextDelegate<TSPIWidget> widgetHandler) {
    test.executeScreen<AFStateProgrammingInterface>(screenId, (e, screenContext) {
      screenContext.executeWidget<TSPIWidget>(wid, createWidget, (widgetContext) {
        widgetContext.executeBuildWithExecute(e, widgetHandler);
      });
    });
  }


  void executeScreenWidget<TSPIWidget extends AFStateProgrammingInterface>(
    AFScreenID screenId, 
    AFWidgetID wid,
    AFCreateConnectedWidgetDelegate createWidget,
    AFStateTestWidgetWithExecuteHandlerDelegate<TSPIWidget> widgetHandler) {
    
    test.executeScreen<AFStateProgrammingInterface>(screenId, (e, screenContext) {
      screenContext.executeWidgetWithExecute<TSPIWidget>(wid, createWidget, e, widgetHandler);
    });
  }

  void executeScreenWidgetWithParentParam<TSPIWidget extends AFStateProgrammingInterface>(
    AFScreenID screenId, 
    AFWidgetID wid,
    AFCreateConnectedWidgetDelegate createWidget,
    AFStateTestWidgetWithExecuteHandlerDelegate<TSPIWidget> widgetHandler) {
    
    test.executeScreen<AFStateProgrammingInterface>(screenId, (e, screenContext) {
      screenContext.executeWidgetWithParentParamAndExecute<TSPIWidget>(wid, createWidget, e, widgetHandler);
    });
  }


  void executeScreenBuild<TSPI extends AFStateProgrammingInterface>(AFScreenID screenId, AFStateTestScreenBuildWithExecuteContextDelegate<TSPI> buildHandler) {
    test.executeScreen<TSPI>(screenId, (e, screenContext) {
      screenContext.executeBuildWithExecute(e, buildHandler);
    });
  }

  void executeDrawerBuild<TSPI extends AFStateProgrammingInterface>(AFScreenID screenId, AFStateTestScreenBuildWithExecuteContextDelegate<TSPI> buildHandler) {
    executeScreenBuild<TSPI>(screenId, buildHandler);
  }

  void executeDrawer<TSPI extends AFStateProgrammingInterface>(AFScreenID screenId, AFStateTestScreenHandlerDelegate<TSPI> screenHandler) {
    test.executeScreen<TSPI>(screenId, screenHandler);
  }

  void executeDialog<TSPI extends AFStateProgrammingInterface>(AFScreenID screenId, AFStateTestScreenHandlerDelegate<TSPI> buildHandler) {
    executeScreen<TSPI>(screenId, buildHandler);
  }

  void executeBottomSheet<TSPI extends AFStateProgrammingInterface>(AFScreenID screenId, AFStateTestScreenHandlerDelegate<TSPI> buildHandler) {
    executeScreen<TSPI>(screenId, buildHandler);
  }

}

class _AFStateExecutionConfiguration {
  final List<_AFStateTestDefinitionStatement> definitionStatements = <_AFStateTestDefinitionStatement>[];
  final List<_AFStateTestExecutionStatement> executionStatements = <_AFStateTestExecutionStatement>[];

  void addAll(_AFStateExecutionConfiguration other) {
    definitionStatements.addAll(other.definitionStatements);
    executionStatements.addAll(other.executionStatements);
  }

  bool get hasExecutionStatements {
    return executionStatements.isNotEmpty;
  }

  void addExecutionStatement(_AFStateTestExecutionStatement statement, { required bool hasPreviousStatements }) {
    if(!hasPreviousStatements && executionStatements.isEmpty && statement is! _AFStateTestStartupStatement) {
      throw AFException("The first execution statement in a state test must be executeStartup (unless this test extends from another test that callsed executeStartup).");
    }
    executionStatements.add(statement);
  }

  void addDefinitionStatement(_AFStateTestDefinitionStatement statement, { required bool hasExecutionStatements }) {
    if(hasExecutionStatements) {
      throw AFException("In a state test body, first do all definition statements, then do execution statements.  Note that because you can override definitions when you extend a test, all definitions are done first, then all executions are done after that, so it doesn't make sense to interleave them.");
    }
    definitionStatements.add(statement);
  }
}

class AFStateTest<TState extends AFFlexibleState> {
  final AFStateTests<TState> tests;
  final AFStateTestID id;
  AFStateTestID? idPredecessor;
  final Map<String, _AFStateResultEntry> results = <String, _AFStateResultEntry>{};
  final _AFStateExecutionConfiguration extendedStatements = _AFStateExecutionConfiguration();
  final _AFStateExecutionConfiguration currentStatements = _AFStateExecutionConfiguration();

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
      this.extendedStatements.addAll(test.extendedStatements);
      this.extendedStatements.addAll(test.currentStatements);
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

    if(query is AFTimeUpdateListenerQuery) {
      if(AFibF.g.testOnlyIsInWorkflowTest) {
        query.startAsyncAF(context.dispatcher, context.store);
        return;
      }
    }

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
          final consolidatedKey = AFStateTest.specifierToId(consolidatedQuery);
          final consolidatedHandler = results[consolidatedKey];
          if(consolidatedHandler != null) {
            consolidatedQueries.result = consolidatedHandler.handler?.call(context, consolidatedQuery);
          }

        }
        query.finishAsyncWithResponseAF(successContext);
        return;
      }

      if(key == AFUIQueryID.time.code) {
        throw AFException("Please call defineInitialTime in your state tests if you use AFTimeUpdateListenerQuery to listen to the time");
      }
    
      throw AFException("No results specified for query ${AFStateTest.specifierToId(query)}");
    }

    final handler = h.handler;
    if(handler != null) {
      handler(context, query);
    }
  }  

  /// 
  void defineQueryResponse(dynamic querySpecifier, AFStateTestDefinitionsContext definitions, dynamic idData) {
    currentStatements.addDefinitionStatement(_AFStateRegisterFixedResultStatement(querySpecifier, definitions, idData), hasExecutionStatements: currentStatements.hasExecutionStatements);
  }

  void defineQueryResponseNone(dynamic querySpecifier, AFStateTestDefinitionsContext definitions) {
    currentStatements.addDefinitionStatement(_AFStateRegisterNoResultStatement(querySpecifier), hasExecutionStatements: currentStatements.hasExecutionStatements);
  }

  void defineQueryResponseDynamic(dynamic querySpecifier, AFCreateQueryResultDelegate delegate) {
    currentStatements.addDefinitionStatement(_AFStateRegisterDynamicResultStatement(querySpecifier, delegate), hasExecutionStatements: currentStatements.hasExecutionStatements);
  }

  void defineDynamicCrossQueryResponse(dynamic querySpecifier, dynamic listenerSpecifier, List<AFCreateQueryResultDelegate> delegates) {
    currentStatements.addDefinitionStatement(_AFStateRegisterDynamicCrossQueryResultStatement(querySpecifier, listenerSpecifier, delegates), hasExecutionStatements: currentStatements.hasExecutionStatements);
  }

  void specifySecondaryError(dynamic querySpecifier, dynamic error) {
    registerResult(querySpecifier, (context, query) {
      query.testFinishAsyncWithError(context, error);
      return null;
    });
  }

  void executeVerifyState(AFStateTestVerifyStateDelegate verifyState) {
    currentStatements.addExecutionStatement(_AFStateTestVerifyStatement(verifyState), hasPreviousStatements: extendedStatements.hasExecutionStatements);
  }

  void executeAdvanceTime(Duration duration) {
    currentStatements.addExecutionStatement(_AFStateTestAdvanceTimeStatement(duration), hasPreviousStatements: extendedStatements.hasExecutionStatements);
  }

  void executeSetAbsoluteTime(DateTime time) {
    currentStatements.addExecutionStatement(_AFStateTestSetAbsoluteTimeStatement(time), hasPreviousStatements: extendedStatements.hasExecutionStatements);
  }

  void executeStartup() {
    final prevStartup = extendedStatements.executionStatements.firstWhereOrNull((e) => e is _AFStateTestStartupStatement);
    if(prevStartup != null) {
      throw AFException("Do not call executeStartup in a test, if it extends a test that has already called executeStartup");
    }
    final queries = AFibF.g.createStartupQueries().toList();
    currentStatements.addExecutionStatement(_AFStateTestStartupStatement(queries), hasPreviousStatements: extendedStatements.hasExecutionStatements);
  }

  void executeQuery(AFAsyncQuery query) {
    currentStatements.addExecutionStatement(_AFStateTestQueryStatement.fromOne(query), hasPreviousStatements: extendedStatements.hasExecutionStatements);
  }

  void executeScreen<TSPI extends AFStateProgrammingInterface>(AFScreenID screenId, AFStateTestScreenHandlerDelegate<TSPI> screenHandler) {
    currentStatements.addExecutionStatement(_AFStateTestScreenStatement<TSPI>(screenId, screenHandler), hasPreviousStatements: extendedStatements.hasExecutionStatements);
  }

  /// Execute the test by kicking of its queries, then 
  void execute(AFStateTestContext context, { bool shouldVerify = true }) {    
    AFStateTestContext.currentTest = context;
  
    // first, execute all the predecessor definitons.
    for(final exec in extendedStatements.definitionStatements) {
      exec.execute(context);
    }

    // then, execute all the current definitions, this may override some of the 
    // previous definitions
    for(final exec in currentStatements.definitionStatements) {
      exec.execute(context);
    }

    // then, execute all the predecessor executions, but don't do any verification,
    // not just because it would be redundant, but because it may be inaccurate due
    // to overriden definitions that impact the results of queries.
    for(final exec in extendedStatements.executionStatements) {
      exec.execute(context, verify: false);
    }

    // basically, we need to go through an execute each query that they specified.
    for(final exec in currentStatements.executionStatements) {
      exec.execute(context, verify: true);
    }
  }
}
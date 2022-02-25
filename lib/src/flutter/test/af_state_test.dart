import 'dart:async';

import 'package:afib/id.dart';
import 'package:afib/src/dart/redux/actions/af_always_fail_query.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/actions/af_deferred_query.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
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

abstract class AFStateTestContext<TState extends AFFlexibleState> extends AFStateTestExecute {
  AFStateTest test;
  final AFStore store;
  AFDispatcher dispatcher;
  static AFStateTestContext? currentTest;
  final bool isTrueTestContext;
  
  AFStateTestContext(this.test, this.store, this.dispatcher, { required this.isTrueTestContext } );

  AFStateTestID get testID { return this.test.id as AFStateTestID; }
  AFState get afState { return store.state; }
  TState? get state { return store.state.public.componentStateOrNull<TState>(); }
  AFRouteState get route { return store.state.public.route; }
  AFPublicState get public { return store.state.public; }
  AFTimeState get currentTime { return public.time; }

  void processQuery(AFAsyncQuery q) {
    AFibD.logQueryAF?.d("Processing ${q.runtimeType} for test $testID");
    AFStateTest.processQuery(this, q);
  }

  AFStateTestScreenContext<TSPI> createScreenContext<TSPI extends AFStateProgrammingInterface>({
    required AFScreenID screenId,
    required AFConnectedUIConfig screenConfig,
  });

  void finishAndUpdateStats(AFTestStats stats) {
    stats.addPasses(errors.pass);
    stats.addErrors(errors.errorCount);
  }
}

class AFStateTestContextForState<TState extends AFFlexibleState> extends AFStateTestContext<TState> {

  AFStateTestContextForState(
    AFStateTest test,
    AFStore store,
    AFDispatcher dispatcher, {
      required bool isTrueTestContext
    }
  ): super(test, store, dispatcher, isTrueTestContext: isTrueTestContext);


  AFStateTestScreenContext<TSPI> createScreenContext<TSPI extends AFStateProgrammingInterface>({
    required AFScreenID screenId,
    required AFConnectedUIConfig screenConfig,
  }) {
    return AFStateTestScreenContextForState<TSPI>(screenId: screenId, screenConfig: screenConfig);
  }
}

class AFStateTestContextForScreen<TState extends AFFlexibleState> extends AFStateTestContext<TState> {

  AFStateTestContextForScreen(
    AFStateTest test,
    AFStore store,
    AFDispatcher dispatcher, {
      required bool isTrueTestContext
    }
  ): super(test, store, dispatcher, isTrueTestContext: isTrueTestContext);


  AFStateTestScreenContext<TSPI> createScreenContext<TSPI extends AFStateProgrammingInterface>({
    required AFScreenID screenId,
    required AFConnectedUIConfig screenConfig,
  }) {
    return AFStateTestScreenContextForScreen<TSPI>(screenId: screenId, screenConfig: screenConfig);
  }
}


class AFStateTests<TState extends AFFlexibleState> {
  final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
  final List<AFStateTest<dynamic>> tests = <AFStateTest<dynamic>>[];
  AFStateTestContext<dynamic>? context;

  void addTest({
    required AFStateTestID id, 
    required AFStateTestID? extendTest, 
    required AFStateTestDefinitionsContext definitions, 
    required AFStateTestDefinitionDelegate body,
    String? description,
    String? disabled 
  }) {
    final test = AFStateTest<TState>(
      id: id, 
      idPredecessor: extendTest,
      tests: this,
      description: description,
      disabled: disabled,
    );
    if(extendTest != null) {
      test.extendsTest(extendTest);
    }
    tests.add(test);
    final defContext = AFStateTestDefinitionContext(definitions, test);
    body(defContext);
  }

  List<AFStateTest<dynamic>> get all {
    return tests;
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

class _AFStateResultEntry<TQuery extends AFAsyncQuery> {
  final dynamic querySpecifier;
  final AFProcessQueryDelegate<TQuery>? handler;
  final Map<String, AFProcessQueryDelegate<TQuery>?>? crossHandlers;
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
    AFProcessQueryDelegate<TQuery>? handler,
    Map<String, AFProcessQueryDelegate<TQuery>?>? crossHandlers
  }) {
    return _AFStateResultEntry<TQuery>(
      querySpecifier,
      handler ?? this.handler,
      crossHandlers ?? this.crossHandlers,
    );
  }
}

enum _AFStateTestExecutionNext {
  stop,
  keepGoing,
}

abstract class _AFStateTestExecutionStatement {
  _AFStateTestExecutionStatement();

  _AFStateTestExecutionNext execute(AFStateTestContext context, { required bool verify });
}

abstract class _AFStateTestDefinitionStatement {
  _AFStateTestDefinitionStatement();

  void execute(AFStateTestContext context);
}

class _AFStateTestInjectListenerQueryResponseStatement extends _AFStateTestExecutionStatement {
  final dynamic querySpecfier;
  final Object result;
  _AFStateTestInjectListenerQueryResponseStatement(this.querySpecfier, this.result);

  @override
  _AFStateTestExecutionNext execute(AFStateTestContext<AFFlexibleState> context, {required bool verify}) {
    // need to lookup the query
    final listenerId = AFStateTest.specifierToId(querySpecfier);
    final listenerQuery = AFibF.g.storeInternalOnly?.state.public.queries.findListenerQueryById(listenerId);
    if(listenerQuery == null) {
      throw AFException("No listener query found with id $querySpecfier");
    }
    listenerQuery.testFinishAsyncWithResponse(context, result);
    return _AFStateTestExecutionNext.keepGoing;
  }

}

class _AFStateTestDebugStopHereStatement extends _AFStateTestExecutionStatement {
  
  
  @override
  _AFStateTestExecutionNext execute(AFStateTestContext<AFFlexibleState> context, {required bool verify}) {
    return _AFStateTestExecutionNext.stop;
  }

}

class _AFStateTestScreenStatement<TSPI extends AFStateProgrammingInterface> extends _AFStateTestExecutionStatement {
  final AFScreenID screenId;
  final AFStateTestScreenHandlerDelegate<TSPI> screenHandler;
  final bool verifyIsActiveScreen;

  _AFStateTestScreenStatement(
    this.screenId,
    this.screenHandler, {
      required this.verifyIsActiveScreen
    }
  );

  @override
  _AFStateTestExecutionNext execute(AFStateTestContext context, { required bool verify }) {
    if(verify && verifyIsActiveScreen) {
        final state = AFibF.g.storeInternalOnly!.state;
        final route = state.public.route;
        context.expect(route.activeScreenId, ft.equals(screenId));      
    }
    final screen = AFibF.g.screenMap.createInstance(screenId, null);
    final config = screen.uiConfig;
    final ctx = context.createScreenContext<TSPI>(screenId: screenId, screenConfig: config);
     screenHandler(context, ctx);
    //final ctxFuture = ctx.future;
    //if(ctxFuture != null) {
      //await ctxFuture;
    //}
    return _AFStateTestExecutionNext.keepGoing;
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

  @override
  _AFStateTestExecutionNext execute(AFStateTestContext context, { required bool verify }) {
    for(final query in queries) {
      AFStateTest.processQuery(context, query);
    }
    return _AFStateTestExecutionNext.keepGoing;
  }
}

class _AFStateTestStartupStatement extends _AFStateTestQueryStatement {
  _AFStateTestStartupStatement(List<AFAsyncQuery> queries): super(queries);  
}

class _AFStateTestVerifyStatement extends _AFStateTestExecutionStatement {
  final AFStateTestVerifyStateDelegate verifyDelegate;
  _AFStateTestVerifyStatement(this.verifyDelegate);
  _AFStateTestExecutionNext execute(AFStateTestContext context, { required bool verify }) {
    if(verify) {
      final verifyContext = AFStateTestStateVerificationContext(afState: AFibF.g.storeInternalOnly!.state);
      verifyDelegate(context, verifyContext);
    }
    return _AFStateTestExecutionNext.keepGoing;
  }
}

class _AFStateTestAdvanceTimeStatement extends _AFStateTestExecutionStatement {
 final Duration duration;
  _AFStateTestAdvanceTimeStatement(this.duration);
  _AFStateTestExecutionNext execute(AFStateTestContext context, { required bool verify }) {
    if(verify) {
      final state = AFibF.g.storeInternalOnly!.state;
      final currentTime = state.public.time;
      final revised = currentTime.reviseAdjustOffset(duration);
      final dispatcher = context.dispatcher;

      final query = state.public.queries.findListenerQueryById(AFUIQueryID.time.toString());
      if(query != null) {
        final revisedQuery = AFTimeUpdateListenerQuery(baseTime: revised); 
        dispatcher.dispatch(revisedQuery);
      }

      // need to revise the listener query itself.
      AFTimeUpdateListenerQuery.processUpdatedTime(dispatcher, revised);
    }
    return _AFStateTestExecutionNext.keepGoing;
  }


}

class _AFStateTestSetAbsoluteTimeStatement extends _AFStateTestExecutionStatement {
 final DateTime time;
  _AFStateTestSetAbsoluteTimeStatement(this.time);
  _AFStateTestExecutionNext execute(AFStateTestContext context, { required bool verify }) {
    if(verify) {
      final state = AFibF.g.storeInternalOnly!.state;
      final currentTime = state.public.time;
      final revised = currentTime.reviseToAbsoluteTime(this.time);
      AFTimeUpdateListenerQuery.processUpdatedTime(context.dispatcher, revised);
    }
    return _AFStateTestExecutionNext.keepGoing;
  }
}


class _AFStateRegisterFixedResultStatement<TQuery extends AFAsyncQuery> extends _AFStateTestDefinitionStatement {
  final Object querySpecifier;
  final AFStateTestDefinitionsContext definitions;
  final Object idData;

  _AFStateRegisterFixedResultStatement(this.querySpecifier, this.definitions, this.idData);

  void execute(AFStateTestContext context) {
    final test = context.test;
    test.registerResult<TQuery>(querySpecifier, (context, query) {
      final data = definitions.td(idData);
      query.testFinishAsyncWithResponse(context, data);
      return data;
    });

  }
}

class _AFStateRegisterDynamicResultStatement<TQuery extends AFAsyncQuery> extends _AFStateTestDefinitionStatement {
  final Object querySpecifier;
  final AFCreateQueryResultDelegate<TQuery> delegate;
  _AFStateRegisterDynamicResultStatement(this.querySpecifier, this.delegate);

  void execute(AFStateTestContext context) {
    final test = context.test;
    test.registerResult<TQuery>(querySpecifier, (context, query) {
      final result = delegate(context, query);
      query.testFinishAsyncWithResponse(context, result);
      return result;
    });
  }
}

class _AFStateRegisterDynamicCrossQueryResultStatement<TQuerySource extends AFAsyncQuery> extends _AFStateTestDefinitionStatement {
  final dynamic querySpecifier; 
  final dynamic listenerSpecifier; 
  final List<AFCreateQueryResultDelegate<TQuerySource>> delegates;
   _AFStateRegisterDynamicCrossQueryResultStatement(this.querySpecifier, this.listenerSpecifier, this.delegates);

  void execute(AFStateTestContext context) {
    final test = context.test;
    test.registerResult<TQuerySource>(querySpecifier, (context, query) {
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

enum _AFStateRegisterSpecialResultKind {
  resultNone,
  resultNull,
}

class _AFStateRegisterSpecialResultStatement<TQuery extends AFAsyncQuery> extends _AFStateTestDefinitionStatement {
  final Object querySpecifier;
  final _AFStateRegisterSpecialResultKind specialResult;

  _AFStateRegisterSpecialResultStatement(this.querySpecifier, this.specialResult);

  factory _AFStateRegisterSpecialResultStatement.resultNull(Object querySpecifier) {
    return _AFStateRegisterSpecialResultStatement(querySpecifier,_AFStateRegisterSpecialResultKind.resultNull);
  }

  factory _AFStateRegisterSpecialResultStatement.resultNone(Object querySpecifier) {
    return _AFStateRegisterSpecialResultStatement(querySpecifier,_AFStateRegisterSpecialResultKind.resultNone);
  }

  void execute(AFStateTestContext context) {
    final test = context.test;
    test.registerResult(querySpecifier,  (context, q) {
      final query = q as TQuery;
      if(specialResult == _AFStateRegisterSpecialResultKind.resultNone) {
        // don't do a response.
      } else if(specialResult == _AFStateRegisterSpecialResultKind.resultNull) {
        query.testFinishAsyncWithResponse(context, null);
      } else {
        assert(false);
      }
      return null;
    });
  }
}

mixin AFExecuteWidgetMixin {
  AFStateTestScreenContext get screenContext;

  void executeWidgetUseChildParam<TSPIWidget extends AFStateProgrammingInterface>(AFWidgetID wid, AFWidgetConfig config, AFStateTestWidgetHandlerDelegate<TSPIWidget> delegate) {
    final widgetContext = AFStateTestWidgetContext<TSPIWidget>(widgetConfig: config, wid: wid, screenContext: screenContext, paramSource: AFWidgetParamSource.child, launchParam: null);
    return delegate(widgetContext);
  }

  void executeWidgetUseChildParamWithExecute<TSPIWidget extends AFStateProgrammingInterface>(AFWidgetID wid, AFWidgetConfig config, AFStateTestExecute e, AFStateTestWidgetWithExecuteHandlerDelegate<TSPIWidget> delegate) {
    final widgetContext = AFStateTestWidgetContext<TSPIWidget>(widgetConfig: config, wid: wid, screenContext: screenContext, paramSource: AFWidgetParamSource.child, launchParam: null);
    return delegate(e, widgetContext);
  }

  void executeWidgetUseLaunchParam<TSPIWidget extends AFStateProgrammingInterface>(AFRouteParam launchParam, AFWidgetConfig config, AFStateTestWidgetHandlerDelegate<TSPIWidget> delegate, {
    AFNavigateRoute parentRoute = AFNavigateRoute.routeHierarchy
  }) {
    final widgetContext = _createWidgetContextWithLaunchParam<TSPIWidget>(launchParam, config, parentRoute);
    // in this scenario, we need to install the paramter in the state, so that it can be referenced in the future.
    return delegate(widgetContext);
  }

  void executeWidgetUseLaunchParamAndExecute<TSPIWidget extends AFStateProgrammingInterface>(AFRouteParam launchParam, AFWidgetConfig config, AFStateTestExecute e, AFStateTestWidgetWithExecuteHandlerDelegate<TSPIWidget> delegate, {
    AFNavigateRoute parentRoute = AFNavigateRoute.routeHierarchy
  }) {
    final widgetContext = _createWidgetContextWithLaunchParam<TSPIWidget>(launchParam, config, parentRoute);
    return delegate(e, widgetContext);
  }

  AFStateTestWidgetContext<TSPIWidget> _createWidgetContextWithLaunchParam<TSPIWidget extends AFStateProgrammingInterface>(AFRouteParam launchParam, AFWidgetConfig config, AFNavigateRoute parentRoute) { 
    //store.dispatch(AFNavigateSetChildParamAction(screen: screenCtx.screenId, route: parentRoute, param: launchParam, paramSource: AFWidgetParamSource.child));
    return AFStateTestWidgetContext<TSPIWidget>(widgetConfig: config, wid: launchParam.id as AFWidgetID, screenContext: screenContext, paramSource: AFWidgetParamSource.child, launchParam: launchParam);
  }  

  void executeWidgetUseParentParam<TSPIWidget extends AFStateProgrammingInterface>(AFWidgetID wid, AFWidgetConfig config, AFStateTestWidgetHandlerDelegate<TSPIWidget> delegate) {
    final widgetContext = AFStateTestWidgetContext<TSPIWidget>(widgetConfig: config, wid: wid, screenContext: screenContext, paramSource: AFWidgetParamSource.parent, launchParam: null);
    return delegate(widgetContext);
  }

  void executeWidgetUseParentParamAndExecute<TSPIWidget extends AFStateProgrammingInterface>(AFWidgetID wid, AFWidgetConfig config, AFStateTestExecute e, AFStateTestWidgetWithExecuteHandlerDelegate<TSPIWidget> delegate) {
    final widgetContext = AFStateTestWidgetContext<TSPIWidget>(widgetConfig: config, wid: wid, screenContext: screenContext, paramSource: AFWidgetParamSource.parent, launchParam: null);
    return delegate(e, widgetContext);
  }
}

class AFStateTestWidgetContext<TSPI extends AFStateProgrammingInterface> with AFExecuteWidgetMixin {
  final AFStateTestScreenContext screenContext; 
  final AFWidgetConfig widgetConfig;
  final AFWidgetID wid;
  final AFWidgetParamSource paramSource;
  final AFRouteParam? launchParam;
  AFStateTestWidgetContext({
    required this.wid,
    required this.screenContext,
    required this.widgetConfig,
    required this.paramSource,
    required this.launchParam,
  });

  void executeBuild(AFStateTestScreenBuildContextDelegate<TSPI> delegate) {
    final spi = createWidgetSPI(paramSource: paramSource);
    return delegate(spi);
  }

  void executeBuildWithExecute(AFStateTestExecute e, AFStateTestScreenBuildWithExecuteContextDelegate<TSPI> delegate) {
    final spi = createWidgetSPI(paramSource: paramSource);
    delegate(e, spi);
  }

  TSPI createWidgetSPI({ required AFWidgetParamSource paramSource }) {
    return AFStateTestScreenContextForState.createSPI<TSPI>(widgetConfig, screenContext.screenId, wid, 
      paramSource: paramSource,
      launchParam: launchParam);
  }


}

abstract class AFStateTestScreenContext<TSPI extends AFStateProgrammingInterface>  with AFExecuteWidgetMixin  {
  final AFScreenID screenId;
  final AFConnectedUIConfig screenConfig;
  Future<void>? future;
  AFStateTestScreenContext({
    required this.screenId,
    required this.screenConfig,
  });

  AFStateTestScreenContext get screenContext {
    return this;
  }

  void executeBuild(AFStateTestScreenBuildContextDelegate<TSPI> delegate, {
    AFRouteParam? launchParam
  }) {
    final spi = createScreenSPI(launchParam: launchParam);
    delegate(spi);
  }

  void executeDebugStopHere() {
    throw AFExceptionStopHere();
  }

  void executeBuildWithExecute(AFStateTestExecute e, AFStateTestScreenBuildWithExecuteContextDelegate<TSPI> delegate, {
    AFRouteParam? launchParam
  }) async {
    final spi = createScreenSPI(launchParam: launchParam);
    delegate(e, spi);
  }

  TSPI createScreenSPI({ required AFRouteParam? launchParam });
}

class AFStateTestScreenContextForState<TSPI extends AFStateProgrammingInterface> extends AFStateTestScreenContext<TSPI>  {
  AFStateTestScreenContextForState({
    required AFScreenID screenId,
    required AFConnectedUIConfig screenConfig,
  }): super(screenId: screenId, screenConfig: screenConfig);

  @override
  TSPI createScreenSPI({ required AFRouteParam? launchParam }) {
    return createSPI<TSPI>(screenConfig, screenId, AFUIWidgetID.unused, paramSource: AFWidgetParamSource.child, launchParam: launchParam);    
  }

  static TSPI createSPI<TSPI extends AFStateProgrammingInterface>(AFConnectedUIConfig config, AFScreenID screenId, AFWidgetID wid, { required AFWidgetParamSource paramSource, required AFRouteParam? launchParam }) {
    final store = AFibF.g.storeInternalOnly!;
    final context = config.createContextForDiff(store, screenId, wid, paramSource: paramSource, launchParam: launchParam);
    if(context == null) {
      throw AFException("Failed to create context");
    }
    return config.createSPI(null, context, screenId, wid, paramSource) as TSPI;
  }
}

class AFStateTestScreenContextForScreen<TSPI extends AFStateProgrammingInterface> extends AFStateTestScreenContext<TSPI>  {
  AFStateTestScreenContextForScreen({
    required AFScreenID screenId,
    required AFConnectedUIConfig screenConfig,
  }): super(screenId: screenId, screenConfig: screenConfig);

  @override
  TSPI createScreenSPI({ required AFRouteParam? launchParam }) {
    // find the existing SPI.
    final spi = AFibF.g.testOnlyScreenSPIMap[screenId];
    if(spi == null) {
      throw AFException("No spi found for screen $screenId, maybe you have a test that is not navigating to that screen, but does reference its SPI?");
    }
    if(spi is! TSPI) {
      throw AFException("Found spi for $screenId but it has type ${spi.runtimeType} instead of $TSPI");
    }
    return spi;
  }
}

class AFStateTestScreenLikeShortcut<TSPI extends AFScreenStateProgrammingInterface> {
  final AFScreenID screenId;
  final AFStateTestDefinitionContext testContext;

  AFStateTestScreenLikeShortcut(this.testContext, this.screenId);

  AFStateTestWidgetShortcut<TSPIWidget> createWidgetShortcut<TSPIWidget extends AFWidgetStateProgrammingInterface>(
    AFWidgetID? wid,
    AFWidgetConfig config,
  ) {
    return AFStateTestWidgetShortcut<TSPIWidget>(wid, config);
  }
}

class AFStateTestScreenShortcut<TSPI extends AFScreenStateProgrammingInterface> extends AFStateTestScreenLikeShortcut<TSPI> {

  AFStateTestScreenShortcut(AFStateTestDefinitionContext testContext, AFScreenID screenId): super(testContext, screenId);

  void executeScreen(AFStateTestScreenHandlerDelegate<TSPI> handler, { bool verifyIsActiveScreen = true }) {
    testContext.executeScreen<TSPI>(screenId, handler, verifyIsActiveScreen: verifyIsActiveScreen);
  }

  void executeScreenBuild(AFStateTestScreenBuildHandlerDelegate<TSPI> handler, { bool verifyIsActiveScreen = true }) {
    testContext.executeScreen<TSPI>(screenId, (e, screenContext) {
      screenContext.executeBuildWithExecute(e, handler);
    }, verifyIsActiveScreen: verifyIsActiveScreen);
  }
}

class AFStateTestDrawerShortcut<TSPI extends AFDrawerStateProgrammingInterface> extends AFStateTestScreenLikeShortcut<TSPI> {

  AFStateTestDrawerShortcut(AFStateTestDefinitionContext testContext, AFScreenID screenId): super(testContext, screenId);

  void executeDrawer(AFStateTestScreenHandlerDelegate<TSPI> handler) {
    testContext.executeDrawer<TSPI>(screenId, handler);
  }

  void executeDrawerBuild(AFStateTestScreenBuildHandlerDelegate<TSPI> handler) {
    testContext.executeDrawer<TSPI>(screenId, (e, screenContext) {
      screenContext.executeBuildWithExecute(e, handler);
    });
  }

}

class AFStateTestDialogShortcut<TSPI extends AFDialogStateProgrammingInterface> extends AFStateTestScreenLikeShortcut<TSPI> {

  AFStateTestDialogShortcut(AFStateTestDefinitionContext testContext, AFScreenID screenId): super(testContext, screenId);

  void executeDialog(AFStateTestScreenHandlerDelegate<TSPI> handler) {
    testContext.executeDialog<TSPI>(screenId, handler);
  }

  void executeDialogBuild(AFStateTestScreenBuildHandlerDelegate<TSPI> handler) {
    testContext.executeDialog<TSPI>(screenId, (e, screenContext) {
      screenContext.executeBuildWithExecute(e, handler);
    });
  }

}

class AFStateTestBottomSheetShortcut<TSPI extends AFBottomSheetStateProgrammingInterface> extends AFStateTestScreenLikeShortcut<TSPI> {

  AFStateTestBottomSheetShortcut(AFStateTestDefinitionContext testContext, AFScreenID screenId): super(testContext, screenId);

  void executeBottomSheet(AFStateTestScreenHandlerDelegate<TSPI> handler) {
    testContext.executeBottomSheet<TSPI>(screenId, handler);
  }

  void executeBottomSheetBuild(AFStateTestScreenBuildHandlerDelegate<TSPI> handler) {
    testContext.executeBottomSheet<TSPI>(screenId, (e, screenContext) {
      screenContext.executeBuildWithExecute(e, handler);
    });
  }

}

class AFStateTestWidgetShortcut<TSPI extends AFWidgetStateProgrammingInterface> {
  static const noWidException = "You must specify a wid either in the widget shortcut, or using the option parameter to executeWidget...";
  final AFWidgetID? wid;
  final AFWidgetConfig config;

  AFStateTestWidgetShortcut(this.wid, this.config);

  void executeWidgetUseParentParam(AFStateTestScreenContext screenContext, { AFWidgetID? wid, required AFStateTestWidgetHandlerDelegate<TSPI> body}) {
    final widActual = wid ?? this.wid;
    if(widActual == null) {
      throw AFException(noWidException);
    }
    screenContext.executeWidgetUseParentParam<TSPI>(widActual, config, body);
  }

  void executeWidgetUseParentParamBuild(AFStateTestScreenContext screenContext, { AFWidgetID? wid, required AFStateTestWidgetBuildHandlerDelegate<TSPI> body}) {
    final widActual = wid ?? this.wid;
    if(widActual == null) {
      throw AFException(noWidException);
    }
    screenContext.executeWidgetUseParentParam<TSPI>(widActual, config, (widgetContext) {
      widgetContext.executeBuild(body);
    });
  }

  void executeWidgetUseLaunchParam(AFStateTestScreenContext screenContext, AFRouteParam launchParam,{ required AFStateTestWidgetHandlerDelegate<TSPI> body}) {
    screenContext.executeWidgetUseLaunchParam<TSPI>(launchParam, config, body);
  }

  void executeWidgetUseLaunchParamBuild(AFStateTestScreenContext screenContext, AFRouteParam launchParam,{ required AFStateTestWidgetBuildHandlerDelegate<TSPI> body}) {
    screenContext.executeWidgetUseLaunchParam<TSPI>(launchParam, config, (widgetContext) {
      widgetContext.executeBuild(body);
    });
  }

  void executeWidgetUseChildParam(AFStateTestScreenContext screenContext,{ AFWidgetID? wid, required AFStateTestWidgetHandlerDelegate<TSPI> body}) {
    final widActual = wid ?? this.wid;
    if(widActual == null) {
      throw AFException(noWidException);
    }
    screenContext.executeWidgetUseChildParam<TSPI>(widActual, config, body);
  }

  void executeWidgetUseChildParamBuild(AFStateTestScreenContext screenContext,{ AFWidgetID? wid, required AFStateTestWidgetBuildHandlerDelegate<TSPI> body}) {
    final widActual = wid ?? this.wid;
    if(widActual == null) {
      throw AFException(noWidException);
    }
    screenContext.executeWidgetUseChildParam<TSPI>(widActual, config, (widgetContext) { 
      widgetContext.executeBuild(body);
    });
  }


}

class AFStateTestDefinitionContext<TState extends AFFlexibleState> {
  static const errSpecifyTypeParameter = "You must specify a type parameter to this function call";
  final AFStateTestDefinitionsContext definitions;
  final AFStateTest<TState> test;
  AFStateTestDefinitionContext(this.definitions, this.test);

  AFStateTestScreenShortcut<TSPI> createScreenShortcut<TSPI extends AFScreenStateProgrammingInterface>(AFScreenID screenId) {
    return AFStateTestScreenShortcut<TSPI>(this, screenId);
  }

  AFStateTestDialogShortcut<TSPI> createDialogShortcut<TSPI extends AFDialogStateProgrammingInterface>(AFScreenID screenId) {
    return AFStateTestDialogShortcut<TSPI>(this, screenId);
  }

  AFStateTestDrawerShortcut<TSPI> createDrawerShortcut<TSPI extends AFDrawerStateProgrammingInterface>(AFScreenID screenId) {
    return AFStateTestDrawerShortcut<TSPI>(this, screenId);
  }

  AFStateTestBottomSheetShortcut<TSPI> createBottomSheetShortcut<TSPI extends AFBottomSheetStateProgrammingInterface>(AFScreenID screenId) {
    return AFStateTestBottomSheetShortcut<TSPI>(this, screenId);
  }

  /// Specify a response for a particular query.
  /// 
  /// When the query 'executes', its [AFAsyncQuery.startAsync] method will be skipped
  /// and its [AFAsyncQuery.finishAsyncWithResponse] method will be called with the 
  /// test data with the specified [idData] in the test data registry.
  void defineQueryResponseFixed<TQuery extends AFAsyncQuery>(dynamic idData, { Object? querySpecifier }) {
    assert(TQuery != AFAsyncQuery, errSpecifyTypeParameter);

    test.defineQueryResponse<TQuery>(querySpecifier ?? TQuery, definitions, idData);
  }

  void defineQueryResponseNone<TQuery extends AFAsyncQuery>({ Object? querySpecifier }) {
    assert(TQuery != AFAsyncQuery, errSpecifyTypeParameter);
    test.defineQueryResponseNone<TQuery>(querySpecifier ?? TQuery, definitions);
  }

  void defineQueryResponseNull<TQuery extends AFAsyncQuery>({ Object? querySpecifier }) {
    assert(TQuery != AFAsyncQuery, errSpecifyTypeParameter);
    test.defineQueryResponseNull<TQuery>(querySpecifier ?? TQuery, definitions);
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
  void defineQueryResponseDynamic<TQuery extends AFAsyncQuery>({ Object? querySpecifier, required AFCreateQueryResultDelegate<TQuery> body}) {
    assert(TQuery != AFAsyncQuery);
    test.defineQueryResponseDynamic<TQuery>(querySpecifier ?? TQuery, body);
  }

  void defineDynamicCrossQueryResponse<TQuerySource extends AFAsyncQuery, TQueryListener extends AFAsyncQuery>(List<AFCreateQueryResultDelegate> delegates, { Object? querySpecifier, Object? listenerSpecifier }) {
    test.defineDynamicCrossQueryResponse<TQuerySource>(delegates, querySpecifier: querySpecifier ?? TQuerySource, listenerSpecifier: listenerSpecifier ?? TQueryListener);
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
        pushUpdateFrequency: Duration(minutes: 1000),
        pushUpdateSpecificity: AFTimeStateUpdateSpecificity.minute
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

  void executeScreen<TSPI extends AFScreenStateProgrammingInterface>(AFScreenID screenId, AFStateTestScreenHandlerDelegate<TSPI> screenHandler, { bool verifyIsActiveScreen = true }) {
    test.executeScreen<TSPI>(screenId, screenHandler, verifyIsActiveScreen: verifyIsActiveScreen);
  }

  void executeDebugStopHere() {
    test.executeDebugStopHere();
  }

  void executeInjectListenerQueryResponse(dynamic querySpecifier, Object result) {
    test.executeInjectListenerQueryResponse(querySpecifier, result);
  }

  void executeDrawer<TSPI extends AFDrawerStateProgrammingInterface>(AFScreenID screenId, AFStateTestScreenHandlerDelegate<TSPI> screenHandler) {
    test.executeScreen<TSPI>(screenId, screenHandler, verifyIsActiveScreen: false);
  }

  void executeDialog<TSPI extends AFDialogStateProgrammingInterface>(AFScreenID screenId, AFStateTestScreenHandlerDelegate<TSPI> buildHandler) {
    executeScreen<TSPI>(screenId, buildHandler, verifyIsActiveScreen: false);
  }

  void executeBottomSheet<TSPI extends AFBottomSheetStateProgrammingInterface>(AFScreenID screenId, AFStateTestScreenHandlerDelegate<TSPI> buildHandler) {
    executeScreen<TSPI>(screenId, buildHandler, verifyIsActiveScreen: false);
  }
}

class _AFStateExecutionConfiguration {
  AFStateTestID? owner;
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

class _AFStateExtendedExecutionConfiguration {
  final configurations = <_AFStateExecutionConfiguration>[];

  bool get hasExecutionStatements {
    for(final config in configurations) {
      if(config.hasExecutionStatements) {
        return true;
      }
    }
    return false;
  }

  List<_AFStateTestDefinitionStatement> definitionStatements() {
    final result = <_AFStateTestDefinitionStatement>[];
    for(final config in configurations) {
      result.addAll(config.definitionStatements);
    }
    return result;
  }

  List<_AFStateTestExecutionStatement> executionStatements({ required AFStateTestID? upTo, required AFStateTestID? continueFrom }) {
    final result = <_AFStateTestExecutionStatement>[];
    for(final config in configurations) {
      if(continueFrom != null && config.owner != continueFrom) {
        continue;
      } else {
        continueFrom = null;
      }
      result.addAll(config.executionStatements);
      if(upTo != null && config.owner == upTo) {
        break;
      }
    }
    return result;
  }

  _AFStateTestStartupStatement? get startupStatement {
    for(final config in configurations) {
      final startup = config.executionStatements.firstWhereOrNull((e) => e is _AFStateTestStartupStatement);
      if(startup != null) {
        return startup as _AFStateTestStartupStatement;
      }
    }
    return null;
  }

  void addAll(_AFStateExtendedExecutionConfiguration other) {
    configurations.addAll(other.configurations);
  }

  void add(_AFStateExecutionConfiguration other) {
    configurations.add(other);
  }
  
}

class AFStateTest<TState extends AFFlexibleState> extends AFScreenTestDescription {
  final AFStateTests<TState> tests;
  final AFStateTestID? idPredecessor;
  final Map<String, _AFStateResultEntry> results = <String, _AFStateResultEntry>{};
  final extendedStatements = _AFStateExtendedExecutionConfiguration();
  _AFStateExecutionConfiguration currentStatements = _AFStateExecutionConfiguration();

  AFStateTest({
    required AFStateTestID id,
    String? description,
    String? disabled,
    required this.idPredecessor,
    required this.tests,
  }): super(id, description, disabled) {
    currentStatements.owner = id;
    registerResult<AFAlwaysFailQuery>(AFAlwaysFailQuery, (context, query) {
      query.testFinishAsyncWithError(context, AFQueryError(message: "Always fail in state test"));
    });
    if(TState.runtimeType == AFFlexibleState) {
      throw AFException("You must explicitly specify your app state on AFStateTest instances");
    }
  }


  void extendsTest(AFStateTestID idTest) {
    final test = tests.findById(idTest);
    if(test != null) {
      this.extendedStatements.addAll(test.extendedStatements);
      final cs = test.currentStatements;
      this.extendedStatements.add(cs);
    }
  }

  bool hasPredecessor(AFStateTestID desiredId) {
    final idPred = idPredecessor;
    if(idPred  == null) {
      return false;
    }
    if(idPred == desiredId) {
      return true;
    }
    final testPred = tests.findById(idPred);
    if(testPred == null) {
      throw AFException("Unknown predecessor test $idPred in $id");
    }
    return testPred.hasPredecessor(desiredId);
  }
    
  void registerResult<TQuery extends AFAsyncQuery>(dynamic querySpecifier, AFProcessQueryDelegate<TQuery> handler) {
    _registerHandler<TQuery>(querySpecifier, handler);
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

  void _registerHandler<TQuery extends AFAsyncQuery>(dynamic querySpecifier, AFProcessQueryDelegate<TQuery> handler) {
    final key = specifierToId(querySpecifier);
    var result = results[key];
    if(result == null) {
      result = _AFStateResultEntry(querySpecifier, (context, q) { 
        final query = q as TQuery;
        return handler(context, query);
      }, null);
      results[key] = result;
    }  else {
      results[key] = result.copyWith(handler: (context, q) {
        final query = q as TQuery;
        return handler(context, query);
      });
    }
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
  void defineQueryResponse<TQuery extends AFAsyncQuery>(dynamic querySpecifier, AFStateTestDefinitionsContext definitions, dynamic idData) {
    currentStatements.addDefinitionStatement(_AFStateRegisterFixedResultStatement<TQuery>(querySpecifier, definitions, idData), hasExecutionStatements: currentStatements.hasExecutionStatements);
  }

  void defineQueryResponseNone<TQuery extends AFAsyncQuery>(dynamic querySpecifier, AFStateTestDefinitionsContext definitions) {
    currentStatements.addDefinitionStatement(_AFStateRegisterSpecialResultStatement<TQuery>.resultNone(querySpecifier), hasExecutionStatements: currentStatements.hasExecutionStatements);
  }

  void defineQueryResponseNull<TQuery extends AFAsyncQuery>(dynamic querySpecifier, AFStateTestDefinitionsContext definitions) {
    currentStatements.addDefinitionStatement(_AFStateRegisterSpecialResultStatement<TQuery>.resultNull(querySpecifier), hasExecutionStatements: currentStatements.hasExecutionStatements);
  }

  void defineQueryResponseDynamic<TQuery extends AFAsyncQuery>(dynamic querySpecifier, AFCreateQueryResultDelegate<TQuery> delegate) {
    currentStatements.addDefinitionStatement(_AFStateRegisterDynamicResultStatement<TQuery>(querySpecifier, delegate), hasExecutionStatements: currentStatements.hasExecutionStatements);
  }

  void defineDynamicCrossQueryResponse<TQuerySource extends AFAsyncQuery>(List<AFCreateQueryResultDelegate> delegates, { Object? querySpecifier, Object? listenerSpecifier }) {
    currentStatements.addDefinitionStatement(_AFStateRegisterDynamicCrossQueryResultStatement<TQuerySource>(querySpecifier, listenerSpecifier, delegates), hasExecutionStatements: currentStatements.hasExecutionStatements);
  }

  void specifySecondaryError<TQuery extends AFAsyncQuery>(dynamic querySpecifier, dynamic error) {
    registerResult<TQuery>(querySpecifier, (context, query) {
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
    final prevStartup = extendedStatements.startupStatement;
    if(prevStartup != null) {
      throw AFException("Do not call executeStartup in a test, if it extends a test that has already called executeStartup");
    }
    final queries = AFibF.g.createStartupQueries().toList();
    currentStatements.addExecutionStatement(_AFStateTestStartupStatement(queries), hasPreviousStatements: extendedStatements.hasExecutionStatements);
  }

  void executeQuery(AFAsyncQuery query) {
    currentStatements.addExecutionStatement(_AFStateTestQueryStatement.fromOne(query), hasPreviousStatements: extendedStatements.hasExecutionStatements);
  }

  void executeScreen<TSPI extends AFStateProgrammingInterface>(AFScreenID screenId, AFStateTestScreenHandlerDelegate<TSPI> screenHandler, { 
    required bool verifyIsActiveScreen,
  }) {
    currentStatements.addExecutionStatement(_AFStateTestScreenStatement<TSPI>(screenId, screenHandler, 
      verifyIsActiveScreen: verifyIsActiveScreen
    ), hasPreviousStatements: extendedStatements.hasExecutionStatements);
  }

  void executeDebugStopHere() {
    currentStatements.addExecutionStatement(_AFStateTestDebugStopHereStatement(), hasPreviousStatements: extendedStatements.hasExecutionStatements);
  }

  void executeInjectListenerQueryResponse(dynamic querySpecifier, Object result) {
    currentStatements.addExecutionStatement(_AFStateTestInjectListenerQueryResponseStatement(querySpecifier, result), hasPreviousStatements: extendedStatements.hasExecutionStatements);
  }


  /// Execute the test by kicking of its queries, then 
  void execute(AFStateTestContext context, { bool shouldVerify = true,
    AFStateTestID? upTo,
    AFStateTestID? continueFrom }) {    
    AFStateTestContext.currentTest = context;
  
    // first, execute all the predecessor definitons.
    final defs = extendedStatements.definitionStatements();
    for(final exec in defs) {
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
    try {

      // don't validate the extended execution.
      context.disableValidation();
      final execs = extendedStatements.executionStatements(upTo: upTo, continueFrom: continueFrom);
      for(final exec in execs) {
        final result = exec.execute(context, verify: false);
        if(result == _AFStateTestExecutionNext.stop) {
          return;
        }
      }

      // don't validate the extended execution.
      context.enableValidation();
      if(upTo == null) {
        // basically, we need to go through an execute each query that they specified.
        for(final exec in currentStatements.executionStatements) {
          final result = exec.execute(context, verify: true);
          if(result == _AFStateTestExecutionNext.stop) {
            return;
          }
        }
      }
    } on AFExceptionStopHere {
      // nothing to do, just stop.
    }
  }
}
import 'package:afib/afib_dart.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/actions/af_deferred_query.dart';
import 'package:afib/src/dart/redux/actions/af_theme_actions.dart';
import 'package:afib/src/dart/redux/middleware/af_async_queries.dart';
import 'package:afib/src/dart/redux/middleware/af_query_middleware.dart';
import 'package:afib/src/dart/redux/middleware/af_route_middleware.dart';
import 'package:afib/src/dart/redux/reducers/af_reducer.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/redux/state/af_theme_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/core/af_screen_map.dart';
import 'package:afib/src/flutter/test/af_init_prototype_screen_map.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_data_registry.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

class AFibTestOnlyScreenElement {
  final AFScreenID screenId;
  BuildContext element;

  AFibTestOnlyScreenElement(this.screenId, this.element);
}

class AFWidgetsBindingObserver extends WidgetsBindingObserver {

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AFibF.g.dispatchLifecycleActions(AFibF.g.storeDispatcherInternalOnly, state);    
  }

  @override 
  void didChangeMetrics() {
    rebuildTheme();
  }

  @override
  void didChangeLocales(List<Locale> locale) {
    rebuildTheme();
  }

  @override 
  void didChangePlatformBrightness() {
    rebuildTheme();
  }

  @override 
  void didChangeTextScaleFactor() {
    rebuildTheme();
  }

  void rebuildTheme() {
    // rebuild our theme with the new values, and then update it.
    final revisedTheme = AFibF.g.initializeThemeState();
    AFibF.g.storeDispatcherInternalOnly.dispatch(AFUpdateThemeStateAction(revisedTheme));    
  }
}


class AFibGlobalState<TState extends AFAppStateArea> {
  final AFAppExtensionContext appContext;

  final AFScreenMap screenMap = AFScreenMap();
  final AFAsyncQueries _afAsyncQueries = AFAsyncQueries();
  final AFTestDataRegistry _afTestData = AFTestDataRegistry();
  final AFSingleScreenTests _afScreenTests = AFSingleScreenTests();
  final AFWidgetTests _afWidgetTests = AFWidgetTests();
  final AFWorkflowStateTests _afWorkflowStateTests = AFWorkflowStateTests<TState>();
  final AFStateTests _afStateTests = AFStateTests();
  final AFUnitTests _afUnitTests = AFUnitTests();
  final testOnlyScreens = <AFScreenID, AFibTestOnlyScreenElement>{};
  final _recentActions = <AFActionWithKey>[];
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final testExtractors = <AFExtractWidgetAction>[];
  final testApplicators = <AFApplyWidgetAction>[];
  final widgetsBindingObserver = AFWidgetsBindingObserver();

  AFScreenMap _afPrototypeScreenMap;
  AFScreenID forcedStartupScreen;
  int navDepth = 0;
  bool testOnlyShouldSuppressNavigation = false;
  Map<String, AFAsyncQueryListener> listenerQueries = <String, AFAsyncQueryListener>{};
  Map<String, AFDeferredQuery> deferredQueries = <String, AFDeferredQuery>{};

  /// The redux store, which contains the application state, NOT FOR PUBLIC USE.
  /// 
  /// WARNING: You should never
  /// call this.  AFib's testing and prototyping systems sometimes operate in contexts
  /// with a specially modified store, without a store at all, or with a special dispatcher.  If you try to access
  /// the store directly, or dispatch actions on it directly, you will compromise these systems.   
  /// 
  /// If you need to dispatch an action, you should typically call [AFBuildContext.dispatch].
  /// If you need access to items from your reduce state, you should typically override
  /// [AFConnectedScreen.createStateData] or [AFConnectedWidgetWithParam.createStateData].
  AFStore storeInternalOnly;

  /// WARNING: You should never call this.  See [internalOnlyStore] for details.
  AFStoreDispatcher storeDispatcherInternalOnly;

  AFibGlobalState({
    this.appContext
  });

  void initialize() {
    appContext.initScreenMap(screenMap);

    final middleware = <Middleware<AFState>>[];
    middleware.addAll(createRouteMiddleware());
    middleware.add(AFQueryMiddleware());
    
    if(AFibD.config.requiresTestData) {      
      appContext.test.initialize(
        testData: testData, 
        unitTests: unitTests,
        stateTests: stateTests,
        widgetTests: widgetTests,
        screenTests: screenTests,
        workflowTests: workflowTests,
      );
      testExtractors.addAll(appContext.test.extractors);
      testApplicators.addAll(appContext.test.applicators);
      _populateAllWidgetCollectors();
    }
    if(AFibD.config.requiresPrototypeData) {
      afInitPrototypeScreenMap(screenMap);
      setPrototypeScreenMap(screenMap);
    }

    storeInternalOnly = AFStore(
      afReducer,
      initialState: AFState.initialState(),
      middleware: middleware
    );
    storeDispatcherInternalOnly = AFStoreDispatcher(storeInternalOnly);
  }

  void testOnlyVerifyActiveScreen(AFScreenID screenId, {bool includePopups = false}) {
    if(screenId == null) {
      return;
    }

    final state = storeInternalOnly.state;
    final routeState = state.public.route;

    if(!routeState.isActiveScreen(screenId, includePopups: includePopups)) {
      throw AFException("Screen $screenId is not the currently active screen in route ${routeState.toString()}");
    }

    var info = AFibF.g.testOnlyScreens[screenId];    
    if(info == null || info.element == null) {
      throw AFException("Screen $screenId is active, but has not rendered (as there is no screen element), this might be an intenral problem in Afib.");
    }

  }

  AFScreenID get testOnlyActiveScreenId {
    final state = AFibF.g.storeInternalOnly.state;
    final routeState = state.public.route;
    return routeState.activeScreenId;
  }

  void correctForFlutterPopNavigation() {
    storeInternalOnly.dispatch(AFNavigatePopFromFlutterAction());
  }

  void doMiddlewareNavigation( Function(NavigatorState) underHere ) {
    navDepth++;
    if(navDepth > 1) {
      throw AFException("Unexpected navigation depth greater than 1");
    }
    final navState = AFibF.g.navigatorKey.currentState;
    if(navState != null) {
      underHere(navState);
    }
    navDepth--;
    if(navDepth < 0) {
      throw AFException("Unexpected navigation depth less than 0");
    }
  }

  bool get withinMiddewareNavigation {
    return navDepth > 0;
  }

  /// Used internally in tests to find widgets on the screen.  Not for public use.
  AFibTestOnlyScreenElement registerTestScreen(AFScreenID screenId, BuildContext screenElement) {
    var info = testOnlyScreens[screenId];
    if(info == null) {
      info = AFibTestOnlyScreenElement(screenId, screenElement);
      testOnlyScreens[screenId] = info;
    }
    info.element = screenElement;
    return info;
  }

  AFScreenPrototypeTest findScreenTestById(AFTestID testId) {
    final single = screenTests.findById(testId);
    if(single != null) {
      return single;
    }

    final multi = workflowTests.findById(testId);
    if(multi != null) {
      return multi;
    }

    final widget = widgetTests.findById(testId);
    if(widget != null) {
      return widget;
    }

    throw AFException("Unknown test id #{testId}");
  }

  /// Used internally to reset widget tracking between tests.
  void resetTestScreens() {
    testOnlyScreens.clear();
    _recentActions.clear();
  }


  /// Used internally in tests to find widgets on the screen.  Not for public use.
  AFibTestOnlyScreenElement findTestScreen(AFScreenID screenId) {
    return testOnlyScreens[screenId];
  }

  /// Used internally in tests to keep track of recently dispatched actions
  /// so that we can verify their contents.
  void testOnlyRegisterRegisterAction(AFActionWithKey action) {
    _recentActions.add(action);
  }

  /// Used internally to get the most recent action with the specified key.
  List<AFActionWithKey> get testOnlyRecentActions {
    return _recentActions;
  }

  void testOnlyClearRecentActions() {
    _recentActions.clear();
  }
 
  /// The screen map to use given the mode we are running in (its different in prototype mode, for example)
  AFScreenMap get effectiveScreenMap {
    if(AFibD.config.requiresPrototypeData) {
      return _afPrototypeScreenMap;
    }
    return screenMap;
  }

  /// returns the screen id of the startup screen.
  /// 
  /// This varies depending on the afib mode (e.g. prototype mode has a different starutp screen than debug/production)
  AFScreenID get effectiveStartupScreenId {
    if(forcedStartupScreen != null) {
      return forcedStartupScreen;
    }
    if(AFibD.config.requiresPrototypeData) {
      return AFUIID.screenPrototypeHome;
    }
    return AFUIID.screenStartupWrapper;
  }

  AFScreenID get actualStartupScreenId {
    return screenMap.startupScreenId;
  }

  /// Returns the route parameter used by the startup screen.
  AFCreateRouteParamDelegate get startupRouteParamFactory {
    return screenMap.startupRouteParamFactory;
  }

  /// Returns a function that creates the initial applications state, used to reset the state.
  AFAppStateAreas createInitialAppStateAreas() {
    return appContext.createInitialAppStateAreas();
  }


  AFThemeState initializeThemeState({AFAppStateAreas areas}) {
    if(areas == null) {
      areas = storeInternalOnly.state.public.areas;
    }
    final device = AFFundamentalDeviceTheme.create();
    final fundamentals = appContext.createFundamentalTheme(device, areas);
    final conceptuals = appContext.initializeConceptualThemes(fundamentals);  
    return AFThemeState.create(
      fundamentals: fundamentals,
      conceptuals: conceptuals
    );
  }

  /// Used internally by the framework.
  /// 
  /// If you'd like to dispatch a startup action, see [AFAppExtensionContext.initializeAppFundamentals]
  /// or [AFAppExtensionContext.addStartupAction]
  void dispatchStartupActions(AFDispatcher dispatcher) {
    appContext.dispatchStartupActions(dispatcher);
  }

  /// Used internally by the framework.
  void dispatchLifecycleActions(AFDispatcher dispatcher, AppLifecycleState lifecycle) {
    appContext.dispatchLifecycleActions(dispatcher, lifecycle);
  }

  /// A list of asynchronous queries the app uses to retrieve or manipulate remote data.
  /// 
  /// In redux terms, each query is a middleware processor, 
  AFAsyncQueries get asyncQueries {
    return _afAsyncQueries;
  }

  /// Retrieves screen/data pairings used for prototyping and for screen-specific
  /// testing.
  AFSingleScreenTests get screenTests {
    return _afScreenTests;
  }

  List<AFScreenPrototypeTest> findTestsForAreas(List<String> areas) {
    final result = <AFScreenPrototypeTest>[];
    final addAllScreen = areas.contains("screen");
    final addAllWorkflow  = areas.contains("workflow");
    _addTestsForAreas(screenTests.all, areas, addAllScreen, result);
    _addTestsForAreas(workflowTests.all, areas, addAllWorkflow, result);
    return result;
  }

  static void _addTestsForAreas(List<AFScreenPrototypeTest> tests, List<String> areas, bool addAll, List<AFScreenPrototypeTest> results) {
    final reusable = areas.indexWhere((element) => element.startsWith("reuse")) >= 0;
    for(final test in tests) {
      for(final area in areas) {        
        if((reusable && test.isReusable) || addAll || test.id.code == area || test.id.hasTag(area)) {
          results.add(test);
        }
      }
    } 
  }

  /// Retrieves widget/data pairings for connected and unconnected widget tests.
  AFWidgetTests get widgetTests {
    return _afWidgetTests;
  }

  /// Retrieves tests which pair an initial state, and then multiple screen/state tests
  /// to produce a higher-level multi-screen test.
  AFWorkflowStateTests get workflowTests {
    return _afWorkflowStateTests;
  }

  /// Retrieves unit/calculation tests
  AFUnitTests get unitTests {
    return _afUnitTests;
  }

  /// Mapping from string ids to builders for specific screens for the real app.
  AFTestDataRegistry get testData {
    return _afTestData;
  }

  // Retrieves tests used to manipulate the redux state and verify that it 
  // changed as expected.
  AFStateTests get stateTests {
    return _afStateTests;
  }

  AFCreateAFAppDelegate get createApp {
    return appContext.createApp;
  }

  /// Called internally when a query finishes successfully, see [AFFlutterParams.querySuccessDelegate] 
  /// to listen for query success.
  void onQuerySuccess(AFAsyncQuery query, AFFinishQuerySuccessContext successContext) {
    appContext.updateQueryListeners(query, successContext);
  }

  /// Register an ongoing listener query which must eventually be shut down.  
  /// 
  /// This is used internally by AFib anytime you dispatch a listener query,
  /// you should not call it directly.
  void registerListenerQuery(AFAsyncQueryListener query) {
    final key = query.key;
    AFibD.logQuery?.d("Registering listener query $key");
    final current = listenerQueries[key];
    if(current != null) {
      current.afShutdown();
    }
    listenerQueries[key] = query;
    
  }

  /// Register a query which executes asynchronously later.
  /// 
  /// This is used internally by AFib anytime you dispatch a deferred query,
  /// you should not call it directly.
  void registerDeferredQuery(AFDeferredQuery query) {
    final key = query.key;
    AFibD.logQuery?.d("Registering deferred query $key");
    final current = deferredQueries[key];
    if(current != null) {
      current.afShutdown();
    }
    deferredQueries[key] = query; 
  }

  /// Shutdown all outstanding listener queries using [AFAsyncQueryListener.shutdown]
  /// 
  /// You might use this to shut down outstanding listener queries when a user logs out.
  void shutdownOutstandingQueries() {
    for(var query in listenerQueries.values) { 
      query.afShutdown();
    }
    listenerQueries.clear();

    for(var query in deferredQueries.values) {
      query.afShutdown();
    }
    deferredQueries.clear();
  }

  /// Shutdown a single outstanding listener query using [AFAsyncQueryListener.shutdown]
  void shutdownListenerQuery(String key) {
    final query = listenerQueries[key];
    if(query != null) {
      query.shutdown();
      listenerQueries[key] = null;
    }
  }

  /// testOnlySetForcedStartupScreen
  void testOnlySetForcedStartupScreen(AFScreenID id) {
    forcedStartupScreen = id;
  }

  /// Do not call this method, AFApp.initialize will do it for you.
  void setPrototypeScreenMap(AFScreenMap screens) {
    _afPrototypeScreenMap = screens;
  }
  
  void _populateAllWidgetCollectors() async {
    final guard = _AFTestAsyncGuard();
    await _populateWidgetCollectors(guard, screenTests.all);
    await _populateWidgetCollectors(guard, widgetTests.all);
    await _populateWidgetCollectors(guard, workflowTests.all);
  }

  static Future<void> _populateWidgetCollectors(_AFTestAsyncGuard guard, List<AFScreenPrototypeTest> tests) async {

    for(final test in tests) {
      guard.startTest(test.id);
      await test.populateWidgetCollector();
      guard.finishTest();
    }

    return null;
  }

}

/// A class for finding accessing global utilities in AFib. 
/// 
/// Never use the globals to track or change state in your
/// application.  Globals contain debugging utilities (e.g. logging)
/// and configuration that is immutable after startup (e.g. configuration).
class AFibF {
  static AFibGlobalState global;

  static void initialize<TState extends AFAppStateArea>(AFAppExtensionContext appContext) {
    global = AFibGlobalState<TState>(
      appContext: appContext
    );

    global.initialize();
  }

  static AFibGlobalState get g { 
    return global;
  }
}

class _AFTestAsyncGuard {
  AFTestID activeTest;

  void startTest(AFTestID test) {
    if(activeTest != null) {
      throw AFException("The test $activeTest is missing an await somewhere, causing it to execute with asynchronous breaks.  Look for places you were calling a test API that required an await");
    }
    activeTest = test;
  }

  void finishTest() {
    activeTest = null;
  } 
}
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/actions/af_deferred_query.dart';
import 'package:afib/src/dart/redux/actions/af_wait_query.dart';
import 'package:afib/src/dart/redux/middleware/af_async_queries.dart';
import 'package:afib/src/dart/redux/middleware/af_query_middleware.dart';
import 'package:afib/src/dart/redux/middleware/af_route_middleware.dart';
import 'package:afib/src/dart/redux/reducers/af_reducer.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/af_app.dart';
import 'package:afib/src/flutter/core/af_screen_map.dart';
import 'package:afib/src/flutter/test/af_init_proto_screen_map.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/utils/af_flutter_params.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';




/// A class for finding accessing global utilities in AFib. 
/// 
/// Never use the globals to track or change state in your
/// application.  Globals contain debugging utilities (e.g. logging)
/// and configuration that is immutable after startup (e.g. configuration).
class AFibF {

  static bool _postStartup = false;
  static final AFScreenMap _afScreenMap = AFScreenMap();
  static InitializeAppState _afInitializeAppState;
  static AppReducer _appReducer;
  static AFStore _afStore;
  static AFAsyncQueries _afAsyncQueries = AFAsyncQueries();
  static CreateStartupQueryAction _afCreateStartupQueryAction;
  static final AFScreenTests _afScreenTests = AFScreenTests();
  static final AFStateTests _afStateTests = AFStateTests();
  static AFScreenMap _afPrototypeScreenMap;
  static CreateAFApp _afCreateApp;
  static AFScreenID forcedStartupScreen;
  static int testOnlyScreenUpdateCount = 0;
  static BuildContext testOnlyScreenElement;
  static Map<String, AFAsyncQueryListenerCustomError> listenerQueries = Map<String, AFAsyncQueryListenerCustomError>();
  static Map<String, AFDeferredQueryCustomError> deferredQueries = Map<String, AFDeferredQueryCustomError>();
  static Map<String, AFWaitQuery> waitQueries = Map<String, AFWaitQuery>();

  

  /// a key for referencing the Navigator for the material app.
  static final GlobalKey<NavigatorState> _afNavigatorKey = new GlobalKey<NavigatorState>();

  static void initialize<AppState>(AFFlutterParams p) {
      _afCreateApp = p.createApp;

    p.initScreenMap(AFibF.screenMap);

    AFibF.setInitialAppStateFactory(p.initialAppState);
    AFibF.setAppReducer(appReducer);
    AFibF.setCreateStartupQueryAction(p.createStartupQueryAction);

    List<Middleware<AFState>> middleware = List<Middleware<AFState>>();
    middleware.addAll(createRouteMiddleware());
    middleware.add(AFQueryMiddleware());
    
    final store = AFStore(
      afReducer,
      initialState: AFState.initialState(),
      middleware: middleware
    );
    setStore(store);

    if(AFibD.config.requiresTestData) {
      p.initScreenTests(AFibF.screenTests);
      p.initStateTests(AFibF.stateTests);
    }

    if(AFibD.config.requiresPrototypeData) {
      AFScreenMap protoScreenMap = AFScreenMap();
      afInitPrototypeScreenMap(protoScreenMap);
      setPrototypeScreenMap(protoScreenMap);
    }

    // Make sure all the globals in AF are immutable from now on.
    finishStartup();
  }


  /// The navigator key for referencing the Navigator for the material app.
  static GlobalKey<NavigatorState> get navigatorKey {
    return _afNavigatorKey;
  }
  
  /// Mapping from string ids to builders for specific screens for the real app.
  static AFScreenMap get screenMap {
    return _afScreenMap;
  }

  /// Static access to the store, should only be used for testing.
  static AFStore get testOnlyStore {
    return _afStore;
  }

  /// The screen map to use given the mode we are running in (its different in prototype mode, for example)
  static AFScreenMap get effectiveScreenMap {
    if(AFibD.config.requiresPrototypeData) {
      return _afPrototypeScreenMap;
    }
    return _afScreenMap;
  }

  static AFScreenID get effectiveStartupScreenId {
    if(forcedStartupScreen != null) {
      return forcedStartupScreen;
    }
    if(AFibD.config.requiresPrototypeData) {
      return AFUIID.screenPrototypeList;
    }
    return AFUIID.screenStartup;
  }

  /// Returns a function that creates the initial applications state, used to reset the state.
  static InitializeAppState get initializeAppState {
    return _afInitializeAppState;
  }

  /// Returns the a function that creates the query which kicks off the application on startup.
  static CreateStartupQueryAction get createStartupQueryAction {
    return _afCreateStartupQueryAction;
  }

  /// A list of asynchronous queries the app uses to retrieve or manipulate remote data.
  /// 
  /// In redux terms, each query is a middleware processor, 
  static AFAsyncQueries get asyncQueries {
    return _afAsyncQueries;
  }

  /// The redux reducer for the entire app.  Give a the current store/state and an action,
  /// it is responsible for producing a new state that reflects the impact of that action.
  static AppReducer get appReducer {
    return _appReducer;
  }

  /// Retrieves screen/data pairings used for prototyping and for screen-specific
  /// testing.
  static AFScreenTests get screenTests {
    return _afScreenTests;
  }

  // Retrieves tests used to manipulate the redux state and verify that it 
  // changed as expected.
  static AFStateTests get stateTests {
    return _afStateTests;
  }

  static CreateAFApp get createApp {
    return _afCreateApp;
  }

  /// The redux store, which contains the application state.   WARNING: You should never
  /// call this.  If you directly reference the store, you will cause testing and prototyping
  /// not to work.   Anywhere you need access to the state, you will be passed the state.
  /// Anywhere you might need to dispatch actions, you will be passed an [AFDispatcher].
  /// You should never ever reference this store directly, as it might not always exist.
  static AFStore get store {
    return _afStore;
  }

  /// Register an ongoing listener query which must eventually be shut down.  
  /// 
  /// This is used internally by AFib anytime you dispatch a listener query,
  /// you should not call it directly.
  static void registerListenerQuery(AFAsyncQueryListenerCustomError query) {
    final key = query.key;
    AFibD.logInternal?.fine("Registering listener query $key");
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
  static void registerDeferredQuery(AFDeferredQueryCustomError query) {
    final key = query.key;
    AFibD.logInternal?.fine("Registering deferred query $key");
    final current = deferredQueries[key];
    if(current != null) {
      current.afShutdown();
    }
    deferredQueries[key] = query; 
  }

  static void registerWaitQuery(AFWaitQuery query) {
    final key = query.key;
    AFibD.logInternal?.fine("Registering wait query $key");
    var current = waitQueries[key];
    if(current == null) {
      current = query;
    } else {
      current.mergeIn(query);
    }
    waitQueries[key] = query; 
  }

  static void handleFinish(AFAsyncQueryCustomError query, AFDispatcher dispatcher, dynamic state) {
    if(waitQueries.isEmpty) {
      return;
    }

    for(var waitQuery in waitQueries.values) {
      if(waitQuery.doesComplete(query)) {
        waitQuery.finishAsyncExecute(dispatcher, state);
        waitQueries.remove(waitQuery.key);
      }
    }
  }

  static void handleFinishWithResponse(AFAsyncQueryCustomError query, AFDispatcher dispatcher, dynamic state) {
    handleFinish(query, dispatcher, state);
  }

  static void handleFinishWithError(AFAsyncQueryCustomError query, AFDispatcher dispatcher, dynamic state) {
    handleFinish(query, dispatcher, state);
  }

  /// Shutdown all outstanding listener queries using [AFAsyncQueryListenerCustomError.shutdown]
  /// 
  /// You might use this to shut down outstanding listener queries when a user logs out.
  static void shutdownOutstandingQueries() {
    for(var query in listenerQueries.values) { 
      query.afShutdown();
    }
    listenerQueries.clear();

    for(var query in deferredQueries.values) {
      query.afShutdown();
    }
    deferredQueries.clear();
  }

  /// Shutdown a single outstanding listener query using [AFAsyncQueryListnerCustomError.shutdown]
  static void shutdownListenerQuery(String key) {
    final query = listenerQueries[key];
    if(query != null) {
      query.shutdown();
      listenerQueries[key] = null;
    }
  }

  /// Do not call this method, see AFApp.initialize instead.
  static void setInitialAppStateFactory(InitializeAppState initialState) {
    if(_afInitializeAppState != null) {
      _directCallException();
    }
    AFibF.verifyNotImmutable();
    _afInitializeAppState = initialState;
  }


  /// Do not call this method, AFApp.initialize will create the store for you.
  static void setStore(AFStore store) {
    if(_afStore != null) {
      _directCallException();
    }
    AFibF.verifyNotImmutable();
    _afStore = store;
  }

  /// Do not call this method, AFApp.initialize will do it for you.
  static setCreateStartupQueryAction(createStartupQueryAction) {
    if(_afCreateStartupQueryAction != null) {
      _directCallException();
    }
    AFibF.verifyNotImmutable();
    _afCreateStartupQueryAction = createStartupQueryAction;
  }

  /// Do not call this method, AFApp.initialize will do it for you.
  static void setAppReducer<TAppState>(AppReducer<TAppState> reducer) {
    if(reducer != null) {
      _appReducer = (dynamic state, dynamic action) {
        dynamic d = reducer(state, action);
        return d;
      };
    }
  }
  
  /// testOnlySetForcedStartupScreen
  static void testOnlySetForcedStartupScreen(AFScreenID id) {
    forcedStartupScreen = id;
  }

  /// Do not call this method, AFApp.initialize will do it for you.
  static void setPrototypeScreenMap(AFScreenMap screens) {
    AFibF.verifyNotImmutable();
    _afPrototypeScreenMap = screens;
  }

  /// Throws an exception if called after the startup process completes.  
  /// 
  /// Used to enforce immutability post startup.
  static void verifyNotImmutable() {
    if(_postStartup) {
      throw AFException("You cannot perform this operation after startup is complete.  Put mutable state in the application state/store using actions");
    }
  }

  /// Utility for error associated with directly calling global setters.
  static void _directCallException() {
      throw AFException("Do not call this directly, use AFApp.initialize");
  }

  static void finishStartup() {
    _postStartup = true;
  }
  


}
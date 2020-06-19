import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/actions/af_deferred_query.dart';
import 'package:afib/src/dart/redux/middleware/af_async_queries.dart';
import 'package:afib/src/dart/redux/middleware/af_query_middleware.dart';
import 'package:afib/src/dart/redux/middleware/af_route_middleware.dart';
import 'package:afib/src/dart/redux/reducers/af_reducer.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/utils/af_config_constants.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/af_app.dart';
import 'package:afib/src/flutter/core/af_screen_map.dart';
import 'package:afib/src/flutter/test/af_init_proto_screen_map.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:redux/redux.dart';


typedef dynamic InitializeAppState();

class AFInitParams<AppState> {
  final InitConfiguration initAfib;
  final InitConfiguration initAppConfig;
  final InitConfiguration initDebugConfig;
  final InitConfiguration initProductionConfig;
  final InitConfiguration initPrototypeConfig;
  final InitConfiguration initTestConfig;
  final InitScreenMap         initScreenMap;
  final InitializeAppState       initialAppState;
  final CreateStartupQueryAction createStartupQueryAction;
  final CreateAFApp createApp;
  final InitStateTests initStateTests;
  final InitScreenTests initScreenTests;
  final AppReducer<AppState>  appReducer;
  final Logger logger;
  final String forceEnv;
  
  AFInitParams({
    @required this.initAfib,
    @required this.initAppConfig,
    @required this.initDebugConfig,
    @required this.initProductionConfig,
    @required this.initPrototypeConfig,
    @required this.initTestConfig,
    @required this.initScreenMap,
    @required this.initialAppState,
    @required this.createStartupQueryAction,
    @required this.createApp,
    @required this.initStateTests,
    @required this.initScreenTests,
    this.appReducer,
    this.logger,
    this.forceEnv
  });
}


/// A class for finding accessing global utilities in AFib. 
/// 
/// Never use the globals to track or change state in your
/// application.  Globals contain debugging utilities (e.g. logging)
/// and configuration that is immutable after startup (e.g. configuration).
class AF {

  static bool _postStartup = false;
  static final AFConfig _afConfig = AFConfig();
  static Logger _afLogger;
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
  static Logger logInternal;
  static Map<String, AFAsyncQueryListenerCustomError> listenerQueries = Map<String, AFAsyncQueryListenerCustomError>();
  static Map<String, AFDeferredQueryCustomError> deferredQueries = Map<String, AFDeferredQueryCustomError>();

  /// a key for referencing the Navigator for the material app.
  static final GlobalKey<NavigatorState> _afNavigatorKey = new GlobalKey<NavigatorState>();

  static void initialize<AppState>(AFInitParams p) {
    _afCreateApp = p.createApp;
    Logger logger = p.logger;
    if(logger == null) {
      logger = Logger("AF");
    }
    AF.setLogger(logger);

    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });  

    // first do the separate initialization that just says what environment it is, since this
    p.initAfib(AF.config);
    if(p.forceEnv != null) {
      AF.config.setString(AFConfigConstants.environmentKey, p.forceEnv);
    }
    p.initAppConfig(AF.config);
    final String env = AF.config.environment;
    if(env == AFConfigConstants.debug) {
      p.initDebugConfig(AF.config);
    } else if(env == AFConfigConstants.production) {
      p.initProductionConfig(AF.config);
    } else if(env == AFConfigConstants.prototype) {
      p.initPrototypeConfig(AF.config);
    } else if(env == AFConfigConstants.testStore) {
      p.initTestConfig(AF.config);
    }

    bool verbose = AF.config.getBool(AFConfigConstants.internalLogging);
    if(verbose != null && verbose) {
      AF.logInternal = AF._afLogger;
    }

    AF.logInternal?.fine("Environment: " + AF.config.environment);

    p.initScreenMap(AF.screenMap);

    AF.setInitialAppStateFactory(p.initialAppState);
    AF.setAppReducer(appReducer);
    AF.setCreateStartupQueryAction(p.createStartupQueryAction);

    List<Middleware<AFState>> middleware = List<Middleware<AFState>>();
    middleware.addAll(createRouteMiddleware());
    middleware.add(AFQueryMiddleware());
    
    final store = AFStore(
      afReducer,
      initialState: AFState.initialState(),
      middleware: middleware
    );
    setStore(store);

    if(AF.config.requiresTestData) {
      p.initScreenTests(AF.screenTests);
      p.initStateTests(AF.stateTests);
    }

    if(AF.config.requiresPrototypeData) {
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
  
  /// Contains configuration data for the app, specific to test, production, etc.
  static AFConfig get config {
    return _afConfig;
  }

  /// A logger for use throughout the app.
  static Logger get logger {
    return _afLogger;
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
    if(AF.config.requiresPrototypeData) {
      return _afPrototypeScreenMap;
    }
    return _afScreenMap;
  }

  static AFScreenID get effectiveStartupScreenId {
    if(forcedStartupScreen != null) {
      return forcedStartupScreen;
    }
    if(AF.config.requiresPrototypeData) {
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
    AF.logInternal?.fine("Registering listener query $key");
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
    AF.logInternal?.fine("Registering deferred query $key");
    final current = deferredQueries[key];
    if(current != null) {
      current.afShutdown();
    }
    deferredQueries[key] = query;
    
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

  /// Prepends "AF: " to a fine level log message.
  /// 
  /// Meant to be used only within the AF framework itself.  Apps should use
  /// AF.logger.fine(...)
  static void fine(String msg) {
    _afLogger.fine("AF: " + msg);
  }

  static void debug(String msg) {
    _afLogger.fine("AF: " + msg);
  }

  /// Do not call this method, see AFApp.initialize instead.
  static void setLogger(Logger logger) {
    if(_afLogger != null) {
      _directCallException();
    }
    AF.verifyNotImmutable();
    _afLogger = logger;
  }

  /// Do not call this method, see AFApp.initialize instead.
  static void setInitialAppStateFactory(InitializeAppState initialState) {
    if(_afInitializeAppState != null) {
      _directCallException();
    }
    AF.verifyNotImmutable();
    _afInitializeAppState = initialState;
  }


  /// Do not call this method, AFApp.initialize will create the store for you.
  static void setStore(AFStore store) {
    if(_afStore != null) {
      _directCallException();
    }
    AF.verifyNotImmutable();
    _afStore = store;
  }

  /// Do not call this method, AFApp.initialize will do it for you.
  static setCreateStartupQueryAction(createStartupQueryAction) {
    if(_afCreateStartupQueryAction != null) {
      _directCallException();
    }
    AF.verifyNotImmutable();
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
    AF.verifyNotImmutable();
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
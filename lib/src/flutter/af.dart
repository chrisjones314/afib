import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/middleware/af_async_queries.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/flutter/af_app.dart';
import 'package:afib/src/flutter/af_screen_map.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:afib/src/dart/utils/af_config.dart';


typedef dynamic InitializeAppState();


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


  /// a key for referencing the Navigator for the material app.
  final GlobalKey<NavigatorState> afNavigatorKey = new GlobalKey<NavigatorState>();

  /// The navigator key for referencing the Navigator for the material app.
  static GlobalKey<NavigatorState> get navigatorKey {
    return AF.navigatorKey;
  }
  
  /// Contains configuration data for the app, specific to test, production, etc.
  static AFConfig get config {
    return _afConfig;
  }

  /// A logger for use throughout the app.
  static Logger get logger {
    return _afLogger;
  }

  /// Mapping from string ids to builders for specific screens.
  static AFScreenMap get screenMap {
    return _afScreenMap;
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

  /// The redux store, which contains the application state.   WARNING: You should never
  /// call this.  If you directly reference the store, you will cause testing and prototyping
  /// not to work.   Anywhere you need access to the state, you will be passed the state.
  /// Anywhere you might need to dispatch actions, you will be passed an [AFDispatcher].
  /// You should never ever reference this store directly, as it might not always exist.
  static AFStore get store {
    return _afStore;
  }

  /// Prepends "AF: " to a fine level log message.
  /// 
  /// Meant to be used only within the AF framework itself.  Apps should use
  /// AF.logger.fine(...)
  static void fine(String msg) {
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

  static void setAppReducer<TAppState>(AppReducer<TAppState> reducer) {
    _appReducer = (dynamic state, dynamic action) {
      dynamic d = reducer(state, action);
      return d;
    };
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
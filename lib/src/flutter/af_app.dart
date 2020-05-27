import 'package:afib/src/dart/redux/middleware/af_async_queries.dart';
import 'package:afib/src/dart/redux/middleware/af_query_middleware.dart';
import 'package:afib/src/dart/redux/middleware/af_route_middleware.dart';
import 'package:afib/src/dart/redux/reducers/af_reducer.dart';
import 'package:afib/src/dart/redux/state/af_store.dart';
import 'package:afib/src/dart/redux/state/af_state.dart';
import 'package:afib/src/flutter/af.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:afib/src/dart/utils/af_config_constants.dart';
import 'package:afib/src/flutter/test/af_init_proto_screen_map.dart';
import 'package:afib/src/flutter/test/af_user_interface_screen_tests.dart';
import 'package:flutter/material.dart';
import 'package:afib/afib_flutter.dart';
import 'package:logging/logging.dart';
import 'package:redux/redux.dart';

/// Used to populate the screen map used to associate keys with screens.
typedef void InitScreenMap(AFScreenMap map);
typedef void InitConfiguration(AFConfig config);
typedef void InitAsyncQueries(AFAsyncQueries queries);
typedef dynamic CreateStartupQueryAction();
typedef void InitUserInterfaceScreenTests(AFUserInterfaceScreenTests scenarios);

//typedef dynamic AppReducer(dynamic appState, dynamic action);
typedef TAppState AppReducer<TAppState>(TAppState appState, dynamic action);

/// The parent class of [MaterialApp] based AFib apps.
/// 
/// The framework creates a subclass of this app for you,
/// and configures it in the main function of your app.
abstract class AFApp<AppState> extends StatelessWidget {

  /// Construct an app with the specified [AFScreenMap]
  AFApp();

  /// The master function called to start up the app prior to
  /// calling flutter [runApp].
  /// 
  /// Rather than overriding this method, see if you can override
  /// one of the many other methods which it calls.
  void intialize({
    @required InitConfiguration initEnvironment,
    @required InitConfiguration initAppConfig,
    @required InitConfiguration initDebugConfig,
    @required InitConfiguration initProductionConfig,
    @required InitConfiguration initPrototypeConfig,
    @required InitConfiguration initTestConfig,
    @required InitScreenMap         initScreenMap,
    @required InitializeAppState       initialAppState,
    @required InitAsyncQueries initAsyncQueries,
    @required CreateStartupQueryAction createStartupQueryAction,
    @required InitUserInterfaceScreenTests initUserInterfaceScreenTests,
    AppReducer<AppState>  appReducer,
    Logger logger
  }) {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });  

    // first do the separate initialization that just says what environment it is, since this
    initEnvironment(AF.config);
    initAppConfig(AF.config);
    final String env = AF.config.environment;
    if(env == AFConfigConstants.debug) {
      initDebugConfig(AF.config);
    } else if(env == AFConfigConstants.production) {
      initProductionConfig(AF.config);
    } else if(env == AFConfigConstants.prototype) {
      initPrototypeConfig(AF.config);
    } else if(env == AFConfigConstants.test) {
      initTestConfig(AF.config);
    }


    if(logger == null) {
      logger = Logger("AF");
    }
    AF.setLogger(logger);

    AF.fine("Environment: " + AF.config.environment);

    initScreenMap(AF.screenMap);

    AF.setInitialAppStateFactory(initialAppState);
    AF.setAppReducer(appReducer);
    AF.setCreateStartupQueryAction(createStartupQueryAction);

    List<Middleware<AFState>> middleware = List<Middleware<AFState>>();
    middleware.addAll(createRouteMiddleware());
    middleware.add(AFQueryMiddleware());
    
    final store = AFStore(
      afReducer,
      initialState: AFState.initialState(),
      middleware: middleware
    );
    AF.setStore(store);

    if(AF.config.requiresPrototypeData) {
      initUserInterfaceScreenTests(AF.userInterfaceScenarios);
      AFScreenMap protoScreenMap = AFScreenMap();
      afInitPrototypeScreenMap(protoScreenMap);
      AF.setPrototypeScreenMap(protoScreenMap);
    }

    // Make sure all the globals in AF are immutable from now on.
    AF.finishStartup();
  }


  /// Called before the main flutter runApp loop.  
  /// Do setup here.
  void beforeRunApp() {
  }

  /// Called after the main runApp loop.  Do cleanup here.
  void afterRunApp() {

  }
}
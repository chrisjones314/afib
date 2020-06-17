import 'package:afib/src/dart/redux/middleware/af_async_queries.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:flutter/material.dart';
import 'package:afib/afib_flutter.dart';

import '../../afib_dart.dart';

/// Used to populate the screen map used to associate keys with screens.
typedef void InitScreenMap(AFScreenMap map);
typedef void InitConfiguration(AFConfig config);
typedef dynamic CreateStartupQueryAction();
typedef AFApp CreateAFApp();
typedef void InitScreenTests(AFScreenTests tests);
typedef void InitStateTests(AFStateTests tests);

//typedef dynamic AppReducer(dynamic appState, dynamic action);
typedef TAppState AppReducer<TAppState>(TAppState appState, dynamic action);

/// The parent class of [MaterialApp] based AFib apps.
/// 
/// The framework creates a subclass of this app for you,
/// and configures it in the main function of your app.
abstract class AFApp<AppState> extends StatelessWidget {
  /// Construct an app with the specified [AFScreenMap]
  AFApp();

  ///
  void afBeforeRunApp() {
    beforeRunApp();
  }

  void afAfterRunApp() {
    afterRunApp();
    AF.shutdownListenerQueries();
  }

  /// Called before the main flutter runApp loop.  
  /// 
  /// Do setup here.
  void beforeRunApp() {
  }

  /// Called after the main runApp loop.  
  /// 
  /// Do cleanup here.
  void afterRunApp() {

  }

}
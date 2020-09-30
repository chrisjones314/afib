import 'package:afib/src/flutter/test/af_screen_test.dart';
import 'package:afib/src/flutter/test/af_test_data_registry.dart';
import 'package:flutter/material.dart';
import 'package:afib/afib_flutter.dart';

/// Used to populate the screen map used to associate keys with screens.
typedef InitScreenMap = void Function(AFScreenMap map);
typedef CreateStartupQueryAction = dynamic Function();
typedef AFCreateLifecycleQueryAction = dynamic Function(AppLifecycleState state);
typedef CreateAFApp = AFApp Function();
typedef InitTestData = void Function(AFTestDataRegistry registry);
typedef InitUnitTests = void Function(AFUnitTests tests, AFTestDataRegistry testData);
typedef InitScreenTests = void Function(AFSingleScreenTests tests, AFTestDataRegistry testData);
typedef InitWidgetTests = void Function(AFWidgetTests tests, AFTestDataRegistry testData);
typedef InitStateTests = void Function(AFStateTests tests, AFTestDataRegistry testData);
typedef InitMultiScreenStateTests = void Function(AFMultiScreenStateTests tests, AFTestDataRegistry testData);

//typedef dynamic AppReducer(dynamic appState, dynamic action);
typedef AppReducer<TAppState> = TAppState Function(TAppState appState, dynamic action);

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
    AFibF.shutdownOutstandingQueries();
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
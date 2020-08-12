
import 'package:afib/src/flutter/af_app.dart';
import 'package:meta/meta.dart';

typedef dynamic InitializeAppState();

class AFFlutterParams<AppState> {
  final InitScreenMap         initScreenMap;
  final InitializeAppState       initialAppState;
  final CreateStartupQueryAction createStartupQueryAction;
  final CreateAFApp createApp;
  final InitTestData initTestData;
  final InitUnitTests initUnitTests;
  final InitStateTests initStateTests;
  final InitScreenTests initScreenTests;
  final AppReducer<AppState>  appReducer;
  final InitMultiScreenStateTests initMultiScreenStateTests;
  
  AFFlutterParams({
    @required this.initScreenMap,
    @required this.initialAppState,
    @required this.createStartupQueryAction,
    @required this.createApp,
    @required this.initTestData,
    @required this.initUnitTests,
    @required this.initStateTests,
    @required this.initScreenTests,
    @required this.initMultiScreenStateTests,
    this.appReducer
  });
}
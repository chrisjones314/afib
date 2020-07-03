
import 'package:afib/src/flutter/af_app.dart';
import 'package:meta/meta.dart';

typedef dynamic InitializeAppState();

class AFFlutterParams<AppState> {
  final InitScreenMap         initScreenMap;
  final InitializeAppState       initialAppState;
  final CreateStartupQueryAction createStartupQueryAction;
  final CreateAFApp createApp;
  final InitStateTests initStateTests;
  final InitScreenTests initScreenTests;
  final AppReducer<AppState>  appReducer;
  
  AFFlutterParams({
    @required this.initScreenMap,
    @required this.initialAppState,
    @required this.createStartupQueryAction,
    @required this.createApp,
    @required this.initStateTests,
    @required this.initScreenTests,
    this.appReducer
  });
}
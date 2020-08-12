import 'package:afib/src/dart/redux/state/af_route_state.dart';
import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:meta/meta.dart';


/// The full application state of an Afib app, which contains 
/// routing state managed by AFib, and the custom application state.
@immutable
class AFState {
  final AFTestState testState;
  final AFRouteState route;
  final dynamic app;

  /// Construct an AFib state with the specified route and app state.
  AFState({
    this.testState,
    this.route,
    this.app
  });

  /// 
  factory AFState.initialState() {
    return AFState(
      testState: AFTestState.initial(),
      route: AFRouteState.initialState(),
      app: AFibF.initializeAppState(),
    );
  }  

  /// Modify the specified properties and leave everything else the same.
  AFState copyWith({
    AFRouteState route, 
    dynamic app,
    AFTestState testState
  }) {
    return AFState(
      route: route ?? this.route,
      app: app ?? this.app,
      testState: testState ?? this.testState
    );
  }
}
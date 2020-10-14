import 'package:afib/src/dart/redux/state/af_route_state.dart';
import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:meta/meta.dart';

class AFPublicState {
  final AFRouteState route;
  final dynamic app;

  AFPublicState({
    this.route,
    this.app
  });

  AFPublicState copyWith({
    AFRouteState route,
    dynamic app
  }) {
    return AFPublicState(
      app: app ?? this.app,
      route: route ?? this.route,
    );
  }
}

/// The full application state of an Afib app, which contains 
/// routing state managed by AFib, and the custom application state.
@immutable
class AFState {
  final AFTestState testState;
  final AFPublicState public;

  /// Construct an AFib state with the specified route and app state.
  AFState({
    this.testState,
    this.public
  });

  /// 
  factory AFState.initialState() {
    return AFState(
      testState: AFTestState.initial(),
      public: AFPublicState(
        route: AFRouteState.initialState(),
        app: AFibF.initializeAppState()
      ),
    );
  }  

  /// Modify the specified properties and leave everything else the same.
  AFState copyWith({
    AFTestState testState,
    AFPublicState public
  }) {
    return AFState(
      testState: testState ?? this.testState,
      public: public ?? this.public,
    );
  }
}
// @dart=2.9
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_route_state.dart';
import 'package:afib/src/dart/redux/state/af_test_state.dart';
import 'package:afib/src/dart/redux/state/af_theme_state.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:meta/meta.dart';

/// State meant to be used by the app itself, including the
/// app-specific state.
class AFPublicState {
  final AFRouteState route;
  final AFThemeState themes;
  final AFAppStateAreas areas;

  AFPublicState({
    @required this.route,
    @required this.themes,
    @required this.areas
  });

  AFAppStateArea areaStateFor(Type areaType) {
    return areas.stateFor(areaType);
  }

  AFPublicState copyWith({
    AFRouteState route,
    AFThemeState themes,
    AFAppStateAreas areas,
  }) {
    return AFPublicState(
      areas: areas ?? this.areas,
      themes: themes ?? this.themes,
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
    final areas = AFibF.g.createInitialAppStateAreas();
    return AFState(
      testState: AFTestState.initial(),
      public: AFPublicState(
        route: AFRouteState.initialState(),
      themes: AFibF.g.initializeThemeState(areas: areas),
        areas: areas
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
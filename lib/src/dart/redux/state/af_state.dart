import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/redux/state/af_query_state.dart';
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
  final AFQueryState queries;
  final AFComponentStates components;

  AFPublicState({
    required this.route,
    required this.themes,
    required this.components,
    required this.queries,
  });

  T componentState<T extends AFFlexibleState>() {
    return components.stateFor(T) as T;
  }

  T? componentStateOrNull<T extends AFFlexibleState>() {
    return components.stateFor(T) as T?;
  }

  AFPublicState copyWith({
    AFRouteState? route,
    AFThemeState? themes,
    AFComponentStates? components,
    AFQueryState? queries,
  }) {
    return AFPublicState(
      components: components ?? this.components,
      themes: themes ?? this.themes,
      route: route ?? this.route,
      queries: queries ?? this.queries,
    );
  }
}


class AFPrivateState {
  final AFTestState testState;
  
  AFPrivateState({
    required this.testState,
  });

  AFPrivateState copyWith({
    AFTestState? testState,
  }) {
    return AFPrivateState(
      testState: testState ?? this.testState,
    );
  }

}

/// The full application state of an Afib app, which contains 
/// routing state managed by AFib, and the custom application state.
@immutable
class AFState {
  final AFPublicState public;
  final AFPrivateState private;

  /// Construct an AFib state with the specified route and app state.
  AFState({
    required this.private,
    required this.public
  });

  /// 
  factory AFState.initialState() {
    final components = AFibF.g.createInitialComponentStates();
    return AFState(
      public: AFPublicState(
        route: AFRouteState.initialState(),
        themes: AFibF.g.initializeThemeState(components: components),
        components: components,
        queries: AFQueryState.initialState()
      ),
      private: AFPrivateState(
        testState: AFTestState.initial(),
      )
    );
  }  

  /// Modify the specified properties and leave everything else the same.
  AFState copyWith({
    AFPrivateState? private,
    AFPublicState? public
  }) {
    return AFState(
      private: private ?? this.private,
      public: public ?? this.public,
    );
  }
}
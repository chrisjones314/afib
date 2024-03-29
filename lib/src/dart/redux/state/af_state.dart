import 'package:afib/src/dart/redux/state/models/af_app_platform_info_state.dart';
import 'package:afib/src/dart/redux/state/models/af_app_state.dart';
import 'package:afib/src/dart/redux/state/models/af_query_state.dart';
import 'package:afib/src/dart/redux/state/models/af_route_state.dart';
import 'package:afib/src/dart/redux/state/models/af_test_state.dart';
import 'package:afib/src/dart/redux/state/models/af_theme_state.dart';
import 'package:afib/src/dart/redux/state/models/af_time_state.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:meta/meta.dart';

class AFPublicStateChange {
  final dynamic action;
  final AFPublicState before;
  final AFPublicState after;

  AFPublicStateChange({
    required this.action,
    required this.before,
    required this.after,
  });
}

/// State meant to be used by the app itself, including the
/// app-specific state.
class AFPublicState {
  final AFConceptualStore conceptualStore;
  final AFRouteState route;
  final AFThemeState themes;
  final AFQueryState queries;
  final AFComponentStates components;
  final AFTimeState time;
  final AFAppPlatformInfoState appPlatformInfo;

  AFPublicState({
    required this.conceptualStore,
    required this.route,
    required this.themes,
    required this.components,
    required this.queries,
    required this.time,
    required this.appPlatformInfo,
  });

  T componentState<T extends AFComponentState>() {
    return components.stateFor(T) as T;
  }

  T? componentStateOrNull<T extends AFComponentState>() {
    return components.stateFor(T) as T?;
  }

  AFPublicState reviseComponents(AFComponentStates components) {
    return copyWith(components: components);
  }

  AFPublicState reviseRoute(AFRouteState route) {
    return copyWith(route: route);
  }

  AFPublicState copyWith({
    AFRouteState? route,
    AFThemeState? themes,
    AFComponentStates? components,
    AFQueryState? queries,
    AFTimeState? time,
    AFAppPlatformInfoState? appPlatformInfo,
  }) {
    return AFPublicState(
      conceptualStore: this.conceptualStore,
      components: components ?? this.components,
      themes: themes ?? this.themes,
      route: route ?? this.route,
      queries: queries ?? this.queries,
      time: time ?? this.time,
      appPlatformInfo: appPlatformInfo ?? this.appPlatformInfo
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
  const AFState({
    required this.private,
    required this.public
  });

  /// 
  factory AFState.initialState(AFConceptualStore conceptualStore) {
    final components = AFibF.g.createInitialComponentStates();
    return AFState(
      public: AFPublicState(
        conceptualStore: conceptualStore,
        route: AFRouteState.initialState(),
        themes: AFibF.g.initializeThemeState(components: components),
        components: components,
        queries: AFQueryState.initialState(),
        time: AFTimeState.initialState(),
        appPlatformInfo: AFAppPlatformInfoState.initialState(),
      ),
      private: AFPrivateState(
        testState: AFTestState.initial(),
      )
    );
  }  

  AFState revisePublic(AFPublicState public) {
    return copyWith(public: public);
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
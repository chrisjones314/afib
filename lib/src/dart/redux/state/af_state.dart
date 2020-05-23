import 'package:afib/src/dart/redux/state/af_route_state.dart';
import 'package:afib/src/flutter/af.dart';
import 'package:meta/meta.dart';


/// The full application state of an Afib app, which contains 
/// routing state managed by AFib, and the custom application state.
@immutable
class AFState {
  final AFRouteState route;
  final dynamic app;

  /// Construct an AFib state with the specified route and app state.
  AFState({
    this.route,
    this.app
  });

  /// 
  factory AFState.initialState() {
    return AFState(
      route: AFRouteState.initialState(),
      app: AF.initializeAppState(),
    );
  }  

  /// Modify the specified properties and leave everything else the same.
  AFState copyWith({
    AFRouteState route, 
    dynamic app
  }) {
    return AFState(
      route: route ?? this.route,
      app: app ?? this.app
    );
  }
}
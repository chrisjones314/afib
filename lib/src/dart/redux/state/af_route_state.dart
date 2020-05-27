
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/af.dart';
import 'package:meta/meta.dart';

/// A segment in the route which specifies a screen to display, and 
/// transient data associated with that screen.
@immutable 
class AFRouteSegment {
  final AFScreenID screen;
  final AFRouteParam param;

  AFRouteSegment({this.screen, this.param});

  AFRouteSegment copyWith({
    String screen,
    AFRouteParam param
  }) {
    return AFRouteSegment(
      screen: screen ?? this.screen,
      param: param ?? this.param
    );
  }

  String toString() {
    return screen.name;
  }

  factory AFRouteSegment.withScreen(AFScreenID screen) {
    return AFRouteSegment(screen: screen);
  }

  factory AFRouteSegment.withParam(AFScreenID screen, AFRouteParam param) {
    return AFRouteSegment(
      screen: screen,
      param: param);
  }
}

/// The current route, a list of nested screens and the data associated with them.
@immutable
class AFRouteState {
  final List<AFRouteSegment> route;

  AFRouteState({this.route});  

  /// Creates the default initial state.
  factory AFRouteState.initialState() {
    final route = List<AFRouteSegment>();
    route.add(AFRouteSegment.withScreen(AF.effectiveStartupScreenId));
    return AFRouteState(route: route);
  }

  /// Returns the segment in the current route associated with the 
  /// specified screen.
  AFRouteSegment findSegmentFor(AFScreenID screen) {
    for(int i = 0; i < route.length; i++) {
      AFRouteSegment segment = route[i];
      if(segment.screen == screen) {
        return segment;
      }
    }
    return null;

  }

  /// Finds the data associated with the specified screen in the current route.
  AFRouteParam findParamFor(AFScreenID screen) {
    AFRouteSegment seg = findSegmentFor(screen);
    if(seg == null) {
      return null;
    }
    return seg.param;
  }

  /// Returns the list of screen names, from the root to the leaf.
  String fullPath() { 
    StringBuffer buffer = StringBuffer();
    route.forEach((AFRouteSegment item) {
      buffer.write("/");
      buffer.write(item.screen);
    });
    return buffer.toString();
  }

  /// Removes the current leaf from the route, and adds the specified screen
  /// and data in its place.
  AFRouteState popAndPushNamed(AFScreenID screen, AFRouteParam param) {
    final newRoute = copyRoute();
    newRoute.removeLast();
    newRoute.add(AFRouteSegment.withParam(screen, param));
    return copyWith(
      route: newRoute
    );
  }

  /// Adds a new screen/data below the current screen in the route.
  AFRouteState pushNamed(AFScreenID screen, AFRouteParam param) {
    final newRoute = copyRoute();
    newRoute.add(AFRouteSegment.withParam(screen, param));
    return copyWith(
      route: newRoute
    );
  }

  /// Remove the leaf element from the route, returning back to the parent
  /// screen.
  AFRouteState pop(dynamic childReturn) {
    final revised = copyRoute();
    revised.removeLast();
    return copyWith(
      route: revised
    );
  }

  /// Replaces the data on the current leaf element without changing the segments
  /// in the route.
  AFRouteState setParam(AFScreenID screen, AFRouteParam param) {
    final revised = copyRoute();
    for(int i = 0; i < revised.length; i++) {
      AFRouteSegment seg = revised[i];
      if(seg.screen == screen) {
        revised[i] = seg.copyWith(param: param);
        break;
      }
    }

    return copyWith(route: revised);
  }

  /// Removes all existing segments in the route, and adds back the specified screen/data.
  AFRouteState replaceAll(AFScreenID screen, AFRouteParam param) {
    List<AFRouteSegment> revised = new List<AFRouteSegment>();
    revised.add(AFRouteSegment.withParam(screen, param));
    return copyWith(
      route: revised
    );
  }

  /// Utility to create a copy of the current route, so that it can be manipulated.
  List<AFRouteSegment> copyRoute() {
    return List<AFRouteSegment>.from(this.route);
  }

  //---------------------------------------------------------------------------------------
  AFRouteState copyWith({
    List<AFRouteSegment> route
  }) {
    return new AFRouteState(
      route: route ?? this.route
    );
  }

}


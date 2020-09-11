
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
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

  bool matchesScreen(AFScreenID screen) {
    if(screen == this.screen) {
      return true;
    }

    // this is used in testing, where the prototype screen
    // stands in for other screens.
    if(param != null && param.matchesScreen(screen)) {
      return true;
    }

    return false;
  }

  String toString() {
    return screen.code;
  }

  bool get isAFibScreen {
    return screen.code.startsWith(AFUIID.afibScreenPrefix);
  }

  /// called when the segment goes fully out of scope.
  void dispose() {
    param?.dispose();
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
  /// Tracks the segement which was just popped off the route. 
  /// 
  /// When Flutter animates a screen transition, it rebuilds both the current and
  /// new screens.  During this interim period, it is conventient to still have 
  /// access to the data in the route segment that was just popped, even though
  /// it is not the final route segment anymore.  This is where we store that value.
  final List<AFRouteSegment> priorLastSegment;
  
  
  final List<AFRouteSegment> route;

  AFRouteState({this.route, this.priorLastSegment});  

  /// Creates the default initial state.
  factory AFRouteState.initialState() {
    final route = List<AFRouteSegment>();
    route.add(AFRouteSegment.withScreen(AFibF.effectiveStartupScreenId));
    return AFRouteState(route: route, priorLastSegment: List<AFRouteSegment>());
  }

  /// Returns the segment in the current route associated with the 
  /// specified screen.
  AFRouteSegment _findSegmentFor(AFScreenID screen, bool includePrior) {
    for(int i = route.length - 1; i >= 0; i--) {
      AFRouteSegment segment = route[i];
      if(segment.matchesScreen(screen)) {
        return segment;
      }
    }
    if(includePrior) {
      return priorLastSegment.firstWhere((seg) => seg.screen == screen, orElse: () => null);
    }
    return null;

  }

  /// The number of screens in the route.
  int get segmentCount {
    return route.length;
  }

  /// Returns the number of pops to do to replace the entire path, but 
  /// does not replace any afib test screens.
  int get popCountToRoot {
    int nPop = 0;
    for(int i = route.length - 1; i >= 0; i--) {
      final segment = route[i];
      // the simple prototype screen is really a test of an app screen, so we do
      // want to pop it off.
      if(segment.isAFibScreen && 
        segment.screen != AFUIID.screenPrototypeSingleScreen &&
        segment.screen != AFUIID.screenPrototypeWidget) {
        return nPop;
      }
      nPop++;
    } 
    return nPop;
  }

  /// Finds the data associated with the specified [screen] in the current route.
  /// 
  /// If [includePrior] is true, it will also include the most recent final segment
  /// in the search.  This is useful when the final segement has been popped off the route,
  /// but still needs to be included in the search.
  AFRouteParam findParamFor(AFScreenID screen, bool includePrior) {
    AFRouteSegment seg = _findSegmentFor(screen, includePrior);
    if(seg == null) {
      return null;
    }
    return seg.param?.paramFor(screen);
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
    final revised = copyRoute();
    final priorLastSegment = _cyclePrior(revised, 1);

    revised.add(AFRouteSegment.withParam(screen, param));
    return copyWith(
      route: revised,
      priorLastSegment: priorLastSegment
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
    final priorLastSegment = _cyclePrior(revised, 1);
    return copyWith(
      route: revised,
      priorLastSegment: priorLastSegment
    );
  }

  /// Pops the route until we get to the first afib test screen.
  AFRouteState exitTest() {
    final revised = copyRoute();
    final popCount = this.popCountToRoot;
    final priorLastSegment = _cyclePrior(revised, popCount);
    return copyWith(
      route: revised,
      priorLastSegment: priorLastSegment
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

    // this prevent us from removing afib test screens.
    final revised = List<AFRouteSegment>.of(route);
    int popCount = this.popCountToRoot;
    final priorLastSegment = _cyclePrior(revised, popCount);

    revised.add(AFRouteSegment.withParam(screen, param));
    return copyWith(
      route: revised,
      priorLastSegment: priorLastSegment
    );
  }

  /// Utility to create a copy of the current route, so that it can be manipulated.
  List<AFRouteSegment> copyRoute() {
    return List<AFRouteSegment>.from(this.route);
  }

  List<AFRouteSegment> _cyclePrior(List<AFRouteSegment> revisedActive, int popCount) {
    final revisedPrior = List<AFRouteSegment>.of(this.priorLastSegment);
    
    for(int i = 0; i < popCount; i++) {
      final justRemoved = revisedActive.removeLast();
      revisedPrior.insert(0, justRemoved);
      if(revisedPrior.length >= 4) {
        final expiredPrior = revisedPrior.removeLast();
        expiredPrior.dispose();
      }
    }

    return revisedPrior;
  }



  //---------------------------------------------------------------------------------------
  AFRouteState copyWith({
    List<AFRouteSegment> route,
    List<AFRouteSegment> priorLastSegment
  }) {
    final revised = new AFRouteState(
      route: route ?? this.route,
      priorLastSegment: priorLastSegment ?? this.priorLastSegment
    );
    AFibD.logRoute?.d("Revised Route: $revised");
    return revised;
  }

  //---------------------------------------------------------------------------------------
  String toString() {
    final result = StringBuffer();
    for(final segment in route) {
      result.write(segment?.screen?.code);
      result.write(' / ');
    }
    return result.toString();
  }

}



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

  AFScreenID get screenId {
    final effective = param?.effectiveScreenId;
    return effective ?? screen;
  }

  String toString() {
    return screen.code;
  }

  bool get isAFibScreen {
    if(screen == AFUIID.screenStartupWrapper) {
      return false;
    }
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

/// A list of active route segements, and a list of priorSegements which are
/// sometimes referenced during navigate pop transitions.
@immutable
class AFRouteStateSegments {
  /// Tracks the segement which was just popped off the route. 
  /// 
  /// When Flutter animates a screen transition, it rebuilds both the current and
  /// new screens.  During this interim period, it is conventient to still have 
  /// access to the data in the route segment that was just popped, even though
  /// it is not the final route segment anymore.  This is where we store that value.
  final List<AFRouteSegment> prior;  
  final List<AFRouteSegment> active;

  AFRouteStateSegments({this.prior, this.active});

  AFRouteSegment get last {
    return active.last;
  }

  bool get isEmpty {
    return active.isEmpty;
  }

  bool get isNotEmpty {
    return !isEmpty;
  }

  int get length {
    return active.length;
  }

  bool get hasStartupWrapper { 
    return isNotEmpty && active.first.screen == AFUIID.screenStartupWrapper;
  }

  int get popCountToRoot {
    var nPop = 0;
    for(var i = active.length - 1; i >= 0; i--) {
      final segment = active[i];
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

  int popCountToScreen(AFScreenID screen) {
    var nPop = 0;
    for(var i = active.length - 1; i >= 0; i--) {
      final segment = active[i];
      if(segment.matchesScreen(screen)) {
        return nPop;
      }
      nPop++;
    } 
    return -1;
  }

  /// Returns the segment in the current route associated with the 
  /// specified screen.
  AFRouteSegment findSegmentFor(AFScreenID screen, { bool includePrior }) {
    for(var i = active.length - 1; i >= 0; i--) {
      final segment = active[i];
      if(segment.matchesScreen(screen)) {
        return segment;
      }
    }
    if(includePrior) {
      for(var i = 0; i < prior.length; i++) {
        final seg = prior[i];
        if(seg.matchesScreen(screen)) {
          return seg;
        }
      }
    }
    return null;
  }

  AFRouteStateSegments copyWith({
    List<AFRouteSegment> active,
    List<AFRouteSegment> prior
  }) {

    return AFRouteStateSegments(
      active: active ?? this.active,
      prior: prior ?? this.prior
    );
  }

  /// Removes the current leaf from the route, and adds the specified screen
  /// and data in its place.
  AFRouteStateSegments popAndPushNamed(AFScreenID screen, AFRouteParam param) {
    final revised = copyActive();
    final priorLastSegment = _cyclePrior(revised, 1);

    revised.add(AFRouteSegment.withParam(screen, param));
    return copyWith(
      active: revised,
      prior: priorLastSegment
    );
  }

  /// Adds a new screen/data below the current screen in the route.
  AFRouteStateSegments pushNamed(AFScreenID screen, AFRouteParam param) {
    final newRoute = copyActive();
    newRoute.add(AFRouteSegment.withParam(screen, param));
    return copyWith(
      active: newRoute
    );
  }

  /// Remove the leaf element from the route, returning back to the parent
  /// screen.
  AFRouteStateSegments pop(dynamic childReturn) {
    return popN(1, childReturn);
  }

  /// Remove the leaf element from the route, returning back to the parent
  /// screen.
  AFRouteStateSegments popTo(AFScreenID screen, dynamic childReturn) {
    final popCount = popCountToScreen(screen);
    return popN(popCount, childReturn);
  }

  /// Remove the leaf element from the route, returning back to the parent
  /// screen.
  AFRouteStateSegments popN(int popCount, dynamic childReturn) {
    final revised = copyActive();
    final priorLastSegment = _cyclePrior(revised, popCount);
    return copyWith(
      active: revised,
      prior: priorLastSegment
    );
  }

  /// Pops the route until we get to the first afib test screen.
  AFRouteStateSegments exitTest() {
    final popCount = this.popCountToRoot;
    return popN(popCount, null);
  }

  /// Replaces the data on the current leaf element without changing the segments
  /// in the route.
  AFRouteStateSegments setParam(AFScreenID screen, AFRouteParam param) {
    final revised = copyActive();
    for(var i = 0; i < revised.length; i++) {
      final seg = revised[i];
      if(seg.screen == screen) {
        revised[i] = seg.copyWith(param: param);
        break;
      }
    }

    return copyWith(active: revised);
  }

  /// Removes all existing segments in the route, and adds back the specified screen/data.
  AFRouteStateSegments replaceAll(AFScreenID screen, AFRouteParam param) {

    // this prevent us from removing afib test screens.
    final revised = List<AFRouteSegment>.of(active);
    final popCount = this.popCountToRoot;
    final priorLastSegment = _cyclePrior(revised, popCount);

    revised.add(AFRouteSegment.withParam(screen, param));
    return copyWith(
      active: revised,
      prior: priorLastSegment
    );
  }

  /// Utility to create a copy of the current route, so that it can be manipulated.
  List<AFRouteSegment> copyActive() {
    return List<AFRouteSegment>.from(this.active);
  }

  String toString() {
    final result = StringBuffer("ACTIVE=[");
    
    for(final segment in active) {
      result.write(segment?.screen?.code);
      result.write(' / ');
    }
    result.write("]");

    if(prior.isNotEmpty) {
      result.write("PRIOR=[");
      for(final segment in prior) {
        result.write(segment?.screen?.code);
        result.write(' / ');
      }
      result.write("]");
    }


    return result.toString();
  }


  List<AFRouteSegment> _cyclePrior(List<AFRouteSegment> revisedActive, int popCount) {
    // dispose any segments from the prior pop.
    for(final expiredSegment in this.prior) {
      // In prototype mode, it is possible to navigate in/out of a screen with a test
      // parameter containing things like TextEditingControllers.  However, because of the
      // way the test framework works, the route parameter will be the same each time, whereas
      // in a real app it would get recreated each time you visit the test screen.   
      // This can cause stuff in the param to get re-used after it is disposed.  So, in prototype
      // mode we don't call dispose.
      if(!AFibD.config.isPrototypeMode) {
        expiredSegment.dispose();
      }
    }

    // create a new prior segment with all the segments being popped off.
    final revisedPrior = <AFRouteSegment>[];
    for(var i = 0; i < popCount; i++) {
      final justRemoved = revisedActive.removeLast();
      revisedPrior.insert(0, justRemoved);
    }

    return revisedPrior;
  }

}

/// The current route, a list of nested screens and the data associated with them.
@immutable
class AFRouteState {
  final AFRouteStateSegments popupSegments;
  final AFRouteStateSegments screenSegments;

  AFRouteState({this.screenSegments, this.popupSegments});  

  /// Creates the default initial state.
  factory AFRouteState.initialState() {
    final screen = <AFRouteSegment>[];
    screen.add(AFRouteSegment.withParam(AFibF.effectiveStartupScreenId, AFibF.startupRouteParamFactory()));
    final empty = <AFRouteSegment>[];
    final screenSegs = AFRouteStateSegments(active: screen, prior: empty);
    final popupSegs  = AFRouteStateSegments(active: empty, prior: empty);
    return AFRouteState(screenSegments: screenSegs, popupSegments: popupSegs);
  }

  bool isActiveScreen(AFScreenID screen, { bool includePopups }) {
    var last = screenSegments.last;
    if(includePopups && popupSegments.isNotEmpty) {
      last = popupSegments.last;
    }
    return last.matchesScreen(screen);
  }

  bool get hasStartupWrapper {
    return screenSegments.hasStartupWrapper;
  }

  AFScreenID get activeScreenId {
    final last = screenSegments.last;
    return last.screenId;
  }

  /// The number of screens in the route.
  int get segmentCount {
    return screenSegments.length;
  }

  /// Returns the number of pops to do to replace the entire path, but 
  /// does not replace any afib test screens.
  int get popCountToRoot {
    return screenSegments.popCountToRoot;
  }

  /// Returns the number of pops to get to the specified screen in the root,
  /// or -1 if that screen isn't in the route.
  int popCountToScreen(AFScreenID screen) {
    return screenSegments.popCountToScreen(screen);
  }

  AFRouteParam findPopupParamFor(AFScreenID screen, { bool includePrior = true }) {
    final seg = popupSegments.findSegmentFor(screen, includePrior: includePrior);
    return seg?.param?.paramFor(screen);
  }


  /// Finds the data associated with the specified [screen] in the current route.
  /// 
  /// If [includePrior] is true, it will also include the most recent final segment
  /// in the search.  This is useful when the final segement has been popped off the route,
  /// but still needs to be included in the search.
  AFRouteParam findParamFor(AFScreenID screen, { bool includePrior = true }) {
    if(hasStartupWrapper && screen == AFibF.screenMap.startupScreenId) {
      screen = AFUIID.screenStartupWrapper;
    }
    final seg = screenSegments.findSegmentFor(screen, includePrior: includePrior);
    return seg?.param?.paramFor(screen);
  }

  bool routeEntryExists(AFScreenID screen, { bool includePrior = true }) {
    final seg = screenSegments.findSegmentFor(screen, includePrior: includePrior);
    return (seg != null);
  }

  /// Returns the list of screen names, from the root to the leaf.
  /*
  String fullPath() { 

    final buffer = StringBuffer();
    for(final item in route) {
      buffer.write("/");
      buffer.write(item.screen);
    }
    return buffer.toString();
  }
  */

  /// Removes the current leaf from the route, and adds the specified screen
  /// and data in its place.
  AFRouteState popAndPushNamed(AFScreenID screen, AFRouteParam param) {
    final revisedScreen = screenSegments.popAndPushNamed(screen, param);
    return _reviseScreen(revisedScreen);
  }

  /// Adds a new screen/data below the current screen in the route.
  AFRouteState pushNamed(AFScreenID screen, AFRouteParam param) {
    return _reviseScreen(screenSegments.pushNamed(screen, param));
  }

  AFRouteState pushPopup(AFScreenID popup, AFRouteParam param) {
    return _revisePopup(popupSegments.pushNamed(popup, param));
  }

  AFRouteState popPopup() {
    return _revisePopup(popupSegments.pop(null));
  }

  /// 
  AFRouteState popFromFlutter() {
    if(popupSegments.isNotEmpty) {
      return popPopup();
    } else {
      return pop(null);
    }
  }

  /// Remove the leaf element from the route, returning back to the parent
  /// screen.
  AFRouteState pop(dynamic childReturn) {
    return popN(1, childReturn);
  }

  /// Remove the leaf element from the route, returning back to the parent
  /// screen.
  AFRouteState popTo(AFScreenID screen, AFScreenID push, AFRouteParam pushParam, dynamic childReturn) {
    final popCount = popCountToScreen(screen);
    var revised = popN(popCount, childReturn);
    if(push != null) {
      revised = pushNamed(push, pushParam);
    }
    return revised;
  }

  /// Remove the leaf element from the route, returning back to the parent
  /// screen.
  AFRouteState popN(int popCount, dynamic childReturn) {
    return _reviseScreen(screenSegments.popN(popCount, childReturn));
  }

  /// Pops the route until we get to the first afib test screen.
  AFRouteState exitTest() {
    return _reviseScreen(screenSegments.exitTest());
  }


  /// Replaces the data on the current leaf element without changing the segments
  /// in the route.
  AFRouteState setParam(AFScreenID screen, AFRouteParam param) {
    if(hasStartupWrapper && screen == AFibF.screenMap.startupScreenId) {
      screen = AFUIID.screenStartupWrapper;
    }
    return _reviseScreen(screenSegments.setParam(screen, param));
  }

  /// Replaces the route parameter for the specified popup screen.
  AFRouteState setPopupParam(AFScreenID screen, AFRouteParam param) {
    return _revisePopup(popupSegments.setParam(screen, param));
  }

  /// Removes all existing segments in the route, and adds back the specified screen/data.
  AFRouteState replaceAll(AFScreenID screen, AFRouteParam param) {
    return _reviseScreen(screenSegments.replaceAll(screen, param));
  }

  //---------------------------------------------------------------------------------------
  AFRouteState _reviseScreen(AFRouteStateSegments screenSegs) {
    return copyWith(screenSegs: screenSegs);
  }

  //---------------------------------------------------------------------------------------
  AFRouteState _revisePopup(AFRouteStateSegments popupSegs) {
    return copyWith(popupSegs: popupSegs);
  }

  //---------------------------------------------------------------------------------------
  AFRouteState copyWith({
    AFRouteStateSegments screenSegs,
    AFRouteStateSegments popupSegs
  }) {
    final revised = AFRouteState(
      screenSegments: screenSegs ?? this.screenSegments,
      popupSegments: popupSegs ?? this.popupSegments
    );

    AFibD.logRoute?.d("Revised Route: $revised");
    return revised;
  }

  //---------------------------------------------------------------------------------------
  String toString() {
    final result = StringBuffer();
    result.write(screenSegments.toString());
    if(popupSegments.isNotEmpty) {
      result.write("POPUP PATH ");
      result.write(popupSegments.toString());
    }
    return result.toString();
  }

}


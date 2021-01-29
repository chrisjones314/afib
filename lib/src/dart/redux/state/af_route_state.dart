
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/redux/actions/af_route_actions.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/id.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/ui/screen/af_prototype_widget_screen.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:meta/meta.dart';

/// A segment in the route which specifies a screen to display, and 
/// transient data associated with that screen.
@immutable 
class AFRouteSegment {
  final AFScreenID screen;
  final AFRouteParam param;

  AFRouteSegment({
    @required this.screen, this.param});

  AFRouteSegment copyWith({
    String screen,
    AFRouteParam param
  }) {
    final testParam = this.param;
    if(param != null && AFibD.config.isTestContext) {
      /*
      if( testParam is AFPrototypeSingleScreenRouteParam && param is! AFPrototypeSingleScreenRouteParam) {
        final fixup = testParam.copyWith(param: param);
        param = fixup;
      }
      */
      if(testParam is AFPrototypeWidgetRouteParam && param is! AFPrototypeWidgetRouteParam) {
        final fixup = testParam.copyWith(param: param);
        param = fixup;
      }
    }
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
    if(screen == AFUIScreenID.screenStartupWrapper) {
      return false;
    }
    return screen.isLibrary(AFUILibraryID.id);
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

  AFRouteStateSegments({
    @required this.prior, 
    @required this.active
  });

  AFRouteSegment get last {
    return active.last;
  }

  AFRouteSegment get first {
    return active.first;
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
    return isNotEmpty && active.first.screen == AFUIScreenID.screenStartupWrapper;
  }

  int get popCountToRoot {
    var nPop = 0;
    for(var i = active.length - 1; i >= 0; i--) {
      final segment = active[i];
      // the simple prototype screen is really a test of an app screen, so we do
      // want to pop it off.
      if(segment.isAFibScreen && 
        segment.screen != AFUIScreenID.screenPrototypeSingleScreen &&
        segment.screen != AFUIScreenID.screenPrototypeWidget) {
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

  AFRouteStateSegments cleanTestRoute() {
    final revisedActive = _cleanTestRoute(active);
    final revisedPrior = _cleanTestRoute(prior);
    return copyWith(active: revisedActive, prior: revisedPrior);
  }

  List<AFRouteSegment> _cleanTestRoute(List<AFRouteSegment> original) {
    return original.where((seg) => !seg.isAFibScreen).toList();
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
  AFRouteStateSegments updateRouteParam(AFScreenID screen, AFRouteParam param) {
    final revised = copyActive();
    for(var i = revised.length - 1; i >= 0; i--) {
      final seg = revised[i];
      if(seg.matchesScreen(screen)) {
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
      result.write(" PRIOR=[");
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
  static const emptySegments = <AFRouteSegment>[];
  final AFRouteStateSegments screenHierarchy;
  final Map<AFScreenID, AFRouteSegment> globalPool;

  AFRouteState({
    @required this.screenHierarchy, 
    @required this.globalPool,
  });  

  /// Creates the default initial state.
  factory AFRouteState.initialState() {
    final screen = <AFRouteSegment>[];
    screen.add(AFRouteSegment.withParam(AFibF.g.effectiveStartupScreenId, AFibF.g.startupRouteParamFactory()));
    final screenSegs = AFRouteStateSegments(active: screen, prior: emptySegments);
    final globalPool = <AFScreenID, AFRouteSegment>{};
    return AFRouteState(screenHierarchy: screenSegs, globalPool: globalPool);
  }

  bool isActiveScreen(AFScreenID screen
  ) {
    var last = screenHierarchy.last;
    return last.matchesScreen(screen);
  }

  /// Used internally to convert a test route, which has the prototype screens at its base, into 
  /// a route that looks like what the app would have without the test stuff.
  AFRouteState cleanTestRoute() {
    final revisedSegments = screenHierarchy.cleanTestRoute();
    return copyWith(screenSegs: revisedSegments);
  }

  bool get hasStartupWrapper {
    return screenHierarchy.hasStartupWrapper;
  }

  AFScreenID get activeScreenId {
    final last = screenHierarchy.last;
    return last.screenId;
  }

  AFScreenID get rootScreenId {
    final first = screenHierarchy.first;
    return first.screenId;
  }

  AFRouteSegment get rootScreen {
    return screenHierarchy.first;
  }

  AFRouteSegment get activeScreen {
    return screenHierarchy.last;
  }

  /// The number of screens in the route.
  int get segmentCount {
    return screenHierarchy.length;
  }

  /// Returns the number of pops to do to replace the entire path, but 
  /// does not replace any afib test screens.
  int get popCountToRoot {
    return screenHierarchy.popCountToRoot;
  }

  /// Returns the number of pops to get to the specified screen in the root,
  /// or -1 if that screen isn't in the route.
  int popCountToScreen(AFScreenID screen) {
    return screenHierarchy.popCountToScreen(screen);
  }

  /// Finds the data associated with the specified [screen] in the current route.
  /// 
  /// If [includePrior] is true, it will also include the most recent final segment
  /// in the search.  This is useful when the final segement has been popped off the route,
  /// but still needs to be included in the search.
  AFRouteParam findParamFor(AFScreenID screen, { bool includePrior = true }) {
    if(globalPool != null && globalPool.containsKey(screen)) {
      return globalPool[screen]?.param;
    }
    if(hasStartupWrapper && screen == AFibF.g.screenMap.startupScreenId) {
      screen = AFUIScreenID.screenStartupWrapper;
    }
    final seg = screenHierarchy.findSegmentFor(screen, includePrior: includePrior);
    return seg?.param?.paramFor(screen);
  }

  /// Finds a drawer param for the drawer with the specified screen id. 
  /// 
  /// This may return null, in which case you should use the drawer's createRouteParam method
  /// to create an initial value.
  AFRouteParam findGlobalParam(AFScreenID screen) {
    return globalPool[screen]?.param;
  }

  bool routeEntryExists(AFScreenID screen, { bool includePrior = true }) {
    final seg = screenHierarchy.findSegmentFor(screen, includePrior: includePrior);
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
    final revisedScreen = screenHierarchy.popAndPushNamed(screen, param);
    return _reviseScreen(revisedScreen);
  }

  /// Adds a new screen/data below the current screen in the route.
  AFRouteState pushNamed(AFScreenID screen, AFRouteParam param) {
    return _reviseScreen(screenHierarchy.pushNamed(screen, param));
  }

  /// 
  AFRouteState popFromFlutter() {
    return pop(null);
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
    return _reviseScreen(screenHierarchy.popN(popCount, childReturn));
  }

  /// Pops the route until we get to the first afib test screen.
  AFRouteState exitTest() {
    return _reviseScreen(screenHierarchy.exitTest());
  }

  /// Replaces the data on the current leaf element without changing the segments
  /// in the route.
  AFRouteState setParam(AFScreenID screen, AFRouteParam param, AFNavigateRoute route) {
    if(route == AFNavigateRoute.routeHierarchy) {
      if(hasStartupWrapper && screen == AFibF.g.screenMap.startupScreenId) {
        screen = AFUIScreenID.screenStartupWrapper;
      }
      return _reviseScreen(screenHierarchy.updateRouteParam(screen, param));
    } else {
      return setGlobalPoolParam(screen, param);
    }
  }

  AFRouteState resetToInitialRoute() {
    final popCount = screenHierarchy.popCountToRoot;
    final revisedRootSegs = this.screenHierarchy.popN(popCount, null);
    final screenMap = AFibF.g.screenMap;

    final revisedSegs = revisedRootSegs.pushNamed(screenMap.trueAppStartupScreenId, screenMap.trueCreateStartupScreenParam());

    return copyWith(
      globalPool: <AFScreenID, AFRouteSegment>{},
      popupSegs: AFRouteStateSegments(active: emptySegments, prior: emptySegments),
      screenSegs: revisedSegs
    );
  }

  /// Replaces the data on the current leaf element without changing the segments
  /// in the route.
  AFRouteState addConnectedChild(AFScreenID screen, AFWidgetID widget, AFRouteParam param) {
    return _reviseParamWithChildren(screen, widget, param, (pwc) => pwc.reviseAddChild(widget, param));
  }

  /// Removes the route parameter for the specified child widget from the screen.
  AFRouteState removeConnectedChild(AFScreenID screen, AFWidgetID widget) {
    return _reviseParamWithChildren(screen, widget, null, (pwc) => pwc.reviseRemoveChild(widget));
  }

  AFRouteState setConnectedChildParam(AFScreenID screen, AFID widget, AFRouteParam param) {
    return _reviseParamWithChildren(screen, widget, param, (pwc) => pwc.reviseChild(widget, param));
  }

  
  AFRouteState sortConnectedChildren(AFScreenID screen, AFTypedSortDelegate sort, Type typeToSort) {
    return _reviseParamWithChildren(screen, null, null, (pwc) => pwc.reviseSortChildren(typeToSort, sort));
  }

  AFRouteState _reviseParamWithChildren(AFScreenID screen, AFID wid, AFRouteParam paramNew, AFRouteParamWithChildren Function(AFRouteParamWithChildren original) revise) { 
    final p = _findParamInHierOrPool(screen);
    var revisedParam;
    if(p is! AFRouteParamWithChildren) {
      final isPassthrough = wid.endsWith(AFUIWidgetID.afibPassthroughSuffix);
      assert(paramNew != null && isPassthrough, "This should only happen for passthrough widgets");
      assert(paramNew.runtimeType == p.runtimeType || p.runtimeType == AFPrototypeWidgetRouteParam);
      revisedParam = paramNew;
    } else {
      final AFRouteParamWithChildren pwc = p;
      revisedParam = revise(pwc);      
    }
    return _setParamInHierOrPool(screen, revisedParam);
  }

  AFRouteState _setParamInHierOrPool(AFScreenID screen, AFRouteParam revised) {
    if(globalPool.containsKey(screen)) {
      return setGlobalPoolParam(screen, revised);
    } else {
      return _reviseScreen(screenHierarchy.updateRouteParam(screen, revised));    
    }
  }

  AFRouteParam _findParamInHierOrPool(AFScreenID screen) {
    var p = globalPool[screen]?.param;
    if(p == null) {
      final segment = screenHierarchy.findSegmentFor(screen);
      p = segment?.param;
    }
    p = p.paramFor(screen);
    return p;
  }

  /// Replaces the data on the current leaf element without changing the segments
  /// in the route.
  AFRouteState setGlobalPoolParam(AFScreenID screen, AFRouteParam param) {
    final revised = Map<AFScreenID, AFRouteSegment>.from(globalPool);
    final current = revised[screen];
    var revisedSeg;
    if(current != null) {
      revisedSeg = current.copyWith(param: param);
    } else {
      revisedSeg = AFRouteSegment(param: param, screen: screen);
    }
    revised[screen] = revisedSeg;
    AFibD.logRoute?.d("Set global param for $screen to $param");
    return copyWith(globalPool: revised);
  }

  /// Removes all existing segments in the route, and adds back the specified screen/data.
  AFRouteState replaceAll(AFScreenID screen, AFRouteParam param) {
    return _reviseScreen(screenHierarchy.replaceAll(screen, param));
  }

  //---------------------------------------------------------------------------------------
  AFRouteState _reviseScreen(AFRouteStateSegments screenSegs) {
    return copyWith(screenSegs: screenSegs);
  }

  //---------------------------------------------------------------------------------------
  AFRouteState copyWith({
    AFRouteStateSegments screenSegs,
    AFRouteStateSegments popupSegs,
    Map<AFScreenID, AFRouteSegment> globalPool,
  }) {
    final revised = AFRouteState(
      screenHierarchy: screenSegs ?? this.screenHierarchy,
      globalPool: globalPool ?? this.globalPool,
    );

    if(screenSegs != null) {
      AFibD.logRoute?.d("Revised Nav Hierarchy: $revised");
    }
    return revised;
  }


  //---------------------------------------------------------------------------------------
  String toString() {
    final result = StringBuffer();
    result.write(screenHierarchy.toString());
    return result.toString();
  }

}


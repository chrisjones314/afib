import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/redux/state/models/af_time_state.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:meta/meta.dart';


@immutable
class AFRouteSegmentChildren {
  final Map<AFID, AFRouteSegment> children;

  AFRouteSegmentChildren({
    required this.children
  });

  factory AFRouteSegmentChildren.fromList(List<AFRouteParam> children) {
    final result = <AFID, AFRouteSegment>{};
    for(final child in children) {
      AFID wid = child.wid;
      if(wid.isKindOf(AFUIWidgetID.useScreenParam)) {
        wid = child.screenId;
      }
      
      result[wid] = AFRouteSegment(param: child, children: null, createDefaultChildParam: null);
    }
    return AFRouteSegmentChildren(children: result);
  }

  factory AFRouteSegmentChildren.create() {
    return AFRouteSegmentChildren(children: <AFID, AFRouteSegment>{});
  }

  int get size {
    return children.length;
  }

  AFRouteSegmentChildren reviseAddChild(AFRouteParam param) {
    final revised = Map<AFID, AFRouteSegment>.from(children);
    AFID? wid = param.wid;
    if(wid.isKindOf(AFUIWidgetID.useScreenParam)) {
      wid = param.screenId;
    }
    revised[wid] = AFRouteSegment(param: param, children: null, createDefaultChildParam: null);
    return AFRouteSegmentChildren(children: revised);
  }

  AFRouteSegmentChildren reviseRemoveChild(AFID widChild) {
    final revised = Map<AFID, AFRouteSegment>.from(children);
    revised.remove(widChild);
    return AFRouteSegmentChildren(children: revised);
  }

  AFRouteSegmentChildren reviseSetChild(AFRouteParam param) {
    final revised = Map<AFID, AFRouteSegment>.from(children);
    AFID? wid = param.wid;
    if(wid.isKindOf(AFUIWidgetID.useScreenParam)) {
      wid = param.screenId;
    }

    final existing = revised[wid];
    var merged = param;
    final existingParam = existing?.param;
    if(existingParam != null) {
      merged = param.mergeOnWrite(existingParam);
    } 

    revised[wid] = AFRouteSegment(param: merged, children: null, createDefaultChildParam: null);
    return AFRouteSegmentChildren(children: revised);
  }

  AFRouteSegment? findSegmentById(AFID id) {
    return children[id];
  }

  TRouteParam? findParamById<TRouteParam extends AFRouteParam>(AFID id) {
    final seg = findSegmentById(id);
    if(seg == null) {
      return null;
    }
    return seg.param as TRouteParam?;
  }

  int countOfChildren<TChildParam extends AFRouteParam>() {
    var result = 0;
    for(final childSeg in children.values) {
      final childParam = childSeg.param;
      if(childParam is TChildParam) {
        result++;
      }
    }
    return result;
  }

  List<TChildParam> paramsWithType<TChildParam extends AFRouteParam>() {
    final result = <TChildParam>[];

    for(final childSeg in children.values) {
      final childParam = childSeg.param;
      if(childParam is TChildParam) {
        result.add(childParam);
      }
    }
    return result;
  }

  Iterable<AFRouteSegment> get values {
    return children.values;
  }
}

/// A segment in the route which specifies a screen to display, and 
/// transient data associated with that screen.
@immutable 
class AFRouteSegment {
  final AFRouteParam param;
  final AFRouteSegmentChildren? children;
  final AFCreateDefaultChildParamDelegate? createDefaultChildParam;

  AFRouteSegment({
    required this.param,
    required this.children,
    required this.createDefaultChildParam,
  });

  AFScreenID get screen  {
    return param.screenId;
  }

  AFRouteSegment? findChild(AFID wid) {
    return children?.findSegmentById(wid);
  }

  AFRouteSegment reviseChildren(AFRouteSegmentChildren children) {
    return copyWith(children: children);
  }

  AFRouteSegment copyWith({
    AFScreenID? screen,
    AFRouteParam? param,
    AFRouteSegmentChildren? children,
    AFCreateDefaultChildParamDelegate? createDefaultChildParam,
  }) {
    return AFRouteSegment(
      param: param ?? this.param,
      children: children ?? this.children,
      createDefaultChildParam: createDefaultChildParam ?? this.createDefaultChildParam
    );
  }

  bool matchesScreen(AFID screen) {
    if(screen == this.screen) {
      return true;
    }

    // this is used in testing, where the prototype screen
    // stands in for other screens.
    if(param.matchesScreen(screen)) {
      return true;
    }

    return false;
  }

  AFScreenID get screenId {
    final effective = param.effectiveScreenId;
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
    param.dispose();
  }

  factory AFRouteSegment.withParam(AFRouteParam param, List<AFRouteParam>? children, AFCreateDefaultChildParamDelegate? createDefaultChildParam) {
    var childrenSeg;
    if(children != null) {
      childrenSeg = AFRouteSegmentChildren.fromList(children);
    }
    return AFRouteSegment(
      param: param,
      children: childrenSeg,
      createDefaultChildParam: createDefaultChildParam
    );
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
    required this.prior, 
    required this.active
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
      final screen = segment.screen;
      if(segment.isAFibScreen && 
        screen != AFUIScreenID.screenPrototypeSingleScreen &&
        screen != AFUIScreenID.screenPrototypeWidget &&
        screen != AFUIScreenID.screenPrototypeDialog &&
        screen != AFUIScreenID.screenPrototypeBottomSheet &&
        screen != AFUIScreenID.screenPrototypeDrawer) {
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
  AFRouteSegment? findSegmentFor(AFID screen, { required bool includePrior }) {
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
    List<AFRouteSegment>? active,
    List<AFRouteSegment>? prior
  }) {

    return AFRouteStateSegments(
      active: active ?? this.active,
      prior: prior ?? this.prior
    );
  }

  /// Removes the current leaf from the route, and adds the specified screen
  /// and data in its place.
  AFRouteStateSegments popAndPushNamed(AFScreenID screen, AFRouteParam param, List<AFRouteParam>? children, AFCreateDefaultChildParamDelegate? createDefaultChildParam) {
    final revised = copyActive();
    final priorLastSegment = _cyclePrior(revised, 1);

    revised.add(AFRouteSegment.withParam(param, children, createDefaultChildParam));
    return copyWith(
      active: revised,
      prior: priorLastSegment
    );
  }

  /// Adds a new screen/data below the current screen in the route.
  AFRouteStateSegments pushNamed(AFRouteParam param, List<AFRouteParam>? children, AFCreateDefaultChildParamDelegate? createDefaultChildParam) {
    final newRoute = copyActive();
    newRoute.add(AFRouteSegment.withParam( param, children, createDefaultChildParam));
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

  AFRouteStateSegments updateRouteSegment(AFID screen, AFRouteSegment revisedSeg) {
    final revised = copyActive();
    for(var i = revised.length - 1; i >= 0; i--) {
      final seg = revised[i];
      if(seg.matchesScreen(screen)) {
        revised[i] = revisedSeg;
        break;
      }
    }

    return copyWith(active: revised);
  }



  /// Removes all existing segments in the route, and adds back the specified screen/data.
  AFRouteStateSegments replaceAll(AFRouteParam param, List<AFRouteParam>? children, AFCreateDefaultChildParamDelegate? createDefaultChildParam) {

    // this prevent us from removing afib test screens.
    final revised = List<AFRouteSegment>.of(active);
    final popCount = this.popCountToRoot;
    final priorLastSegment = _cyclePrior(revised, popCount);

    revised.add(AFRouteSegment.withParam(param, children, createDefaultChildParam));
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
      result.write(segment.screen.code);
      result.write(' / ');
    }
    result.write("]");

    if(prior.isNotEmpty) {
      result.write(" PRIOR=[");
      for(final segment in prior) {
        result.write(segment.screen.code);
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
      if(!AFibD.config.isPrototypeMode && !AFibF.g.isDemoMode) {
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

enum AFUIType {
  screen,
  drawer,
  dialog,
  bottomSheet,
  widget,
}

class AFRouteStateShowScreen {
  final AFScreenID screenId;
  final AFUIType kind;
  const AFRouteStateShowScreen({
    required this.screenId,
    required this.kind,
  });

  bool hasScreenId(AFScreenID id) {
    return id == screenId;
  }
}

/// The current route, a list of nested screens and the data associated with them.
@immutable
class AFRouteState {
  static const showScreenUnused = AFRouteStateShowScreen(screenId: AFUIScreenID.unused, kind: AFUIType.dialog);
  static const emptySegments = <AFRouteSegment>[];
  final AFRouteStateSegments screenHierarchy;
  final AFTimeState timeLastUpdate;
  final Map<AFID, AFRouteSegment> globalPool;
  final Map<AFUIType, AFRouteStateShowScreen> showingScreens;

  AFRouteState({
    required this.screenHierarchy, 
    required this.globalPool,
    required this.timeLastUpdate,
    required this.showingScreens,
  });  

  /// Creates the default initial state.
  factory AFRouteState.initialState() {
    final screen = <AFRouteSegment>[];
    final routeParamFactory = AFibF.g.startupRouteParamFactory;
    if(routeParamFactory == null) throw AFException("Missing startup route");
    screen.add(AFRouteSegment.withParam(routeParamFactory(), null, null));
    final screenSegs = AFRouteStateSegments(active: screen, prior: emptySegments);
    final globalPool = <AFScreenID, AFRouteSegment>{};
    globalPool[AFUIScreenID.unused] = AFRouteSegment(param: AFRouteParamUnused.unused, children: null, createDefaultChildParam: null);
    return AFRouteState(screenHierarchy: screenSegs, globalPool: globalPool, timeLastUpdate: AFTimeState.createNow(), showingScreens: <AFUIType, AFRouteStateShowScreen>{});
  }

  bool isActiveScreen(AFScreenID screen) {
    var last = screenHierarchy.last;
    return last.matchesScreen(screen);
  }

  AFRouteSegment findUnusedParam() {
    final result = findRouteParamFull(screenId: AFUIScreenID.unused, wid: AFUIWidgetID.useScreenParam, routeLocation: AFRouteLocation.globalPool);
    return result!;
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

  String get simpleTextRoute {
    final result = StringBuffer();
    for(final item in screenHierarchy.active) {
      result.write(item.screenId.toString());
      result.write("/");
    }
    return result.toString();
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

  AFRouteSegment? findRouteParamInHierarchy({
    required AFScreenID screenId,
    required AFWidgetID wid,
    bool includePrior = true,
  }) {
    final parentSeg = screenHierarchy.findSegmentFor(screenId, includePrior: includePrior);
    return _findChildIfApplicable(parentSeg: parentSeg, wid: wid);
  }

  AFRouteSegment? findRouteParamInGlobalPool({
    required AFScreenID screenId,
    required AFWidgetID wid,
  }) {
    final parentSeg = globalPool[screenId];
    return _findChildIfApplicable(parentSeg: parentSeg, wid: wid);
  }

  AFRouteSegment? _findChildIfApplicable({
    required AFRouteSegment? parentSeg,
    required AFWidgetID wid,
  }) {
    if(parentSeg == null) {
      return null;
    }

    if(wid == AFUIWidgetID.useScreenParam) {
      return parentSeg;
    }

    return parentSeg.findChild(wid);
  }

  AFRouteSegment? findRouteParamFull({
    required AFScreenID screenId,
    required AFWidgetID wid,
    required AFRouteLocation routeLocation,
  }) {
    if(routeLocation == AFRouteLocation.screenHierarchy) {
      return findRouteParamInHierarchy(screenId: screenId, wid: wid);
    } else {
      return findRouteParamInGlobalPool(screenId: screenId, wid: wid);
    }
  }

  /// Finds the data associated with the specified [screen] in the current route.
  /// 
  /// If [includePrior] is true, it will also include the most recent final segment
  /// in the search.  This is useful when the final segement has been popped off the route,
  /// but still needs to be included in the search.
  AFRouteSegment? findParamFor(AFID screen, { bool includePrior = true }) {
    final gp = globalPool;
    if(gp.containsKey(screen)) {
      return gp[screen];
    }
    if(hasStartupWrapper && screen == AFibF.g.screenMap.startupScreenId) {
      screen = AFUIScreenID.screenStartupWrapper;
    }
    final seg = screenHierarchy.findSegmentFor(screen as AFScreenID, includePrior: includePrior);
    return seg; //?.param.paramFor(screen);
  }

  AFRouteSegment? findChildParamFor(AFID screen, AFWidgetID wid, { bool includePrior = true }) {
    final screenSeg = findParamFor(screen, includePrior: includePrior);
    if(screenSeg == null) {
      return null;
    }
    return screenSeg.findChild(wid);
  }

  /// Finds a drawer param for the drawer with the specified screen id. 
  /// 
  /// This may return null, in which case you should use the drawer's createRouteParam method
  /// to create an initial value.
  AFRouteSegment? findGlobalParam(AFID screen) {
    return globalPool[screen];
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
  AFRouteState popAndPushNamed(AFRouteParam? param, List<AFRouteParam>? children, AFCreateDefaultChildParamDelegate? createDefaultChildParam) {
    assert(param != null);
    if(param != null) {
      final screen = param.screenId;
      AFibD.logRouteAF?.d("popAndPushNamed: $screen / $param");
      final revisedScreen = screenHierarchy.popAndPushNamed(screen, param, children, createDefaultChildParam);
      return _reviseScreen(revisedScreen);
    }
    return this;
  }

  /// Adds a new screen/data below the current screen in the route.
  AFRouteState pushNamed(AFRouteParam param, List<AFRouteParam>? children, AFCreateDefaultChildParamDelegate? createDefaultChildParam) {
    var routeState = this;
    if(param is AFRouteParamRef) {
      assert(param.routeLocation == AFRouteLocation.globalPool, "You can only AFRouteParamUseExistingOrDefault for a global screen.");

      // first, revise it with the default.
      routeState = updateRouteParamWithExistingOrDefault(param);

      // then, revise the route parameter 
    }

    AFibD.logRouteAF?.d("pushNamed: $param");
    return routeState._reviseScreen(screenHierarchy.pushNamed(param, children, createDefaultChildParam));
  }

  /// 
  AFRouteState popFromFlutter() {
    return pop(null);
  }

  /// Remove the leaf element from the route, returning back to the parent
  /// screen.
  AFRouteState pop(dynamic childReturn) {
    AFibD.logRouteAF?.d("pop returned $childReturn");
    return popN(1, childReturn);
  }

  /// Remove the leaf element from the route, returning back to the parent
  /// screen.
  AFRouteState popTo(AFScreenID screen, AFRouteParam? pushParam, List<AFRouteParam>? pushChildren, AFCreateDefaultChildParamDelegate? createDefaultChildParam, dynamic childReturn) {
    AFibD.logRouteAF?.d("popTo: $screen and push($pushParam) with return $childReturn");
    final popCount = popCountToScreen(screen);
    var revised = popN(popCount, childReturn);
    if(pushParam != null) {
      revised = pushNamed(pushParam, pushChildren, createDefaultChildParam);
    }
    return revised;
  }

  /// Remove the leaf element from the route, returning back to the parent
  /// screen.
  AFRouteState popN(int popCount, dynamic childReturn) {
    AFibD.logRouteAF?.d("popN($popCount) with return $childReturn");
    return _reviseScreen(screenHierarchy.popN(popCount, childReturn));
  }

  /// Pops the route until we get to the first afib test screen.
  AFRouteState exitTest() {
    AFibD.logRouteAF?.d("exitTest");
    if(isShowing(AFUIType.dialog)) {
      // our navigation in flutter fails if a dialog is active.  
      // so, require that all dialog tests lose the dialog at the end.
      assert(false, "Please make sure all your UI tests for dialogs close the dialog at the end of the test.");
    }

    return _reviseScreen(screenHierarchy.exitTest());
  }

  AFRouteState updateRouteParamWithExistingOrDefault(AFRouteParamRef param) {
    // first, see if it exists
    final seg = this.findRouteParamFull(screenId: param.screenId, routeLocation: param.routeLocation, wid: param.wid);
    if(seg != null) {
      // it already exists, so nothing to do to the state
      return this;
    }

    final uiConfig = AFibF.g.screenMap.findUIConfig(param.screenId);

    // if it doens't already exist, then the UI config must have a way to create a default value.
    final create = uiConfig?.createDefaultRouteParam;
    if(create == null) {
      assert(false, "If you are using AFRouteParamUseExistingOrDefault, and there is no existing value, you must specify a createDefaultRouteParam delegate in our AFConnectedUIConfig declaration.");
      return this;
    }

    final defaultParam = create(param, AFibF.g.internalOnlyActiveStore.state.public);
    return updateRouteParam(defaultParam);    
  }

  /// Replaces the data on the current leaf element without changing the segments
  /// in the route.
  AFRouteState updateRouteParam(AFRouteParam param) {
    // in this case, we obviously don't want to set this value as the param. Instead,
    // we want to verify that it already exists, or else create it using the uiConfig's default
    // method.
    if(param is AFRouteParamRef) {
      return updateRouteParamWithExistingOrDefault(param);
    }

    if(param.hasChildWID) { 
      return setChildParam(param);
    }


    var screen = param.screenId;
    var route = param.routeLocation;
    if(route == AFRouteLocation.screenHierarchy) {
      if(hasStartupWrapper && screen == AFibF.g.screenMap.startupScreenId) {
        screen = AFUIScreenID.screenStartupWrapper;
      }
      AFibD.logRouteAF?.d("updateHierarchyParam: $screen, $param");
      final seg = screenHierarchy.findSegmentFor(screen, includePrior: true);
      if(seg == null) {
        throw AFException("No route segment for screen $screen");
      }
      final merged = param.mergeOnWrite(seg.param);
      final revisedSeg = seg.copyWith(param: merged);      
      return _reviseScreen(screenHierarchy.updateRouteSegment(screen, revisedSeg));
    } else {
      var globalSeg = globalPool[screen];
      if(globalSeg == null) {
        globalSeg = AFRouteSegment(param: param, children: null, createDefaultChildParam: null);
      } else {
        final merged = param.mergeOnWrite(globalSeg.param);
        globalSeg = globalSeg.copyWith(param: merged);
      }

      return setGlobalPoolParam(screen, globalSeg);
    }
  }

  AFRouteState updateTimeRouteParameters(AFTimeState now) {
    final revisedSegs = <AFRouteSegment>[];
    for(final segment in screenHierarchy.active) {
      revisedSegs.add(_updateTimeRouteSegment(segment, now));
    }
    final revisedHier = screenHierarchy.copyWith(active: revisedSegs);
    
    return copyWith(timeLastUpdate: now, screenSegs: revisedHier);  
  }

  AFRouteSegment _updateTimeRouteSegment(AFRouteSegment segment, AFTimeState now) {
    final param = segment.param;
    final specificity = param.timeSpecificity;
    if(specificity == null) {
      return segment;
    }
    final nowSpecific = now.reviseSpecificity(specificity);
    if(timeLastUpdate == nowSpecific) {
      return segment;
    }

    final revisedParam = param.reviseForTime(nowSpecific);
    if(revisedParam == null) {
      return segment;
    }

    return segment.copyWith(param: revisedParam);    
  }

  AFRouteState resetToInitialRoute() {
    AFibD.logRouteAF?.d("resetToInitialRoute");

    final popCount = screenHierarchy.popCountToRoot;
    final revisedRootSegs = this.screenHierarchy.popN(popCount, null);
    final screenMap = AFibF.g.screenMap;

    //final startupScreenId = screenMap.trueAppStartupScreenId;
    var startupScreenParam = screenMap.trueCreateStartupScreenParam?.call();
    if(startupScreenParam == null) throw AFException("Missing startup screen id or parameter");

    final revisedSegs = revisedRootSegs.pushNamed(startupScreenParam, null, null);

    return copyWith(
      globalPool: <AFScreenID, AFRouteSegment>{},
      popupSegs: AFRouteStateSegments(active: emptySegments, prior: emptySegments),
      screenSegs: revisedSegs
    );
  }

  /// Replaces the data on the current leaf element without changing the segments
  /// in the route.
  AFRouteState addChildParam(AFRouteParam param) {
    AFID? widget = param.wid;
    if(widget.isKindOf(AFUIWidgetID.useScreenParam)) {
      widget = param.screenId;
    }
    final screen = param.screenId;
    final route = param.routeLocation;
    AFibD.logRouteAF?.d("addConnectedChild $screen/$widget with $param");
    return _reviseParamWithChildren(screen, widget, route, param, (pwc) => pwc.reviseAddChild(param));
  }

  /// Removes the route parameter for the specified child widget from the screen.
  AFRouteState removeChildParam({
    required AFScreenID screenId, 
    required AFID wid, 
    required AFRouteLocation routeLocation
  }) {
    AFibD.logRouteAF?.d("addConnectedChild $screenId/$wid");
    return _reviseParamWithChildren(screenId, wid, routeLocation, null, (pwc) => pwc.reviseRemoveChild(wid));
  }


  Iterable<AFRouteStateShowScreen> get activeShowingScreens {
    return showingScreens.values.where((ss) => ss.screenId != AFUIScreenID.unused);
  }

  AFRouteState showScreenBegin(AFScreenID screenId, AFUIType kind) {
    final revised = Map<AFUIType, AFRouteStateShowScreen>.from(showingScreens);
    revised[kind] = AFRouteStateShowScreen(screenId: screenId, kind: kind);
    return copyWith(showScreen: revised);
  }

  AFRouteState showScreenEnd(AFScreenID screenId) {
    // the screen must be showing, so look up its type based on its screen id.
    var uiType;
    for(final show in showingScreens.values) {
      if(show.hasScreenId(screenId)) {
        uiType = show.kind;
        break;
      }
    }

    if(uiType == null) {
      assert(false, "ending a screen that wasn't showing?");
      return this;
    }

    final revised = Map<AFUIType, AFRouteStateShowScreen>.from(showingScreens);
    revised[uiType] = AFRouteState.showScreenUnused;

    return copyWith(showScreen: revised);
  }

  bool isShowingSpecific(AFUIType uiType, AFScreenID screenId) {
    final show = _findShowFor(uiType);
    return show.hasScreenId(screenId);
  }

  bool isShowing(AFUIType uiType) {
    final show = _findShowFor(uiType);
    return show != AFRouteState.showScreenUnused;
  }

  bool isNotShowing(AFUIType uiType) {
    final show = _findShowFor(uiType);
    return show.hasScreenId(AFUIScreenID.unused);
  }

  AFRouteStateShowScreen _findShowFor(AFUIType uiType) {
    final result = showingScreens[uiType];
    if(result == null) {
      return AFRouteState.showScreenUnused;
    }
    return result;
  }


  AFRouteState setChildParam(AFRouteParam param) {
    if(param.wid == AFUIWidgetID.useScreenParam) {
      return updateRouteParam(param);
    }
    final widget = param.wid;
    final screen = param.screenId;
    final route = param.routeLocation;
    AFibD.logRouteAF?.d("setConnectedChild $screen/$widget with $param");
    return _reviseParamWithChildren(screen, widget, route, param, (pwc) => pwc.reviseSetChild(param));
  }

  AFRouteState _reviseParamWithChildren(AFScreenID screen, AFID? wid, AFRouteLocation route, AFRouteParam? paramNew, AFRouteSegmentChildren Function(AFRouteSegmentChildren original) revise) { 
    final p = _findParamInHierOrPool(screen, route);
    if(p == null) {
      throw AFException("Could not find route parameter for screen $screen");
    }
    var children = p.children;
    if(children == null) { 
      if(paramNew != null) {
        children = AFRouteSegmentChildren.create();
      } else {
        throw AFException("Cannot remove or sort empty list of children!");
      }
    }
    final revisedChildren = revise(children);   
    final revisedSeg = p.reviseChildren(revisedChildren);  
    
    return _setParamInHierOrPool(screen, route, revisedSeg);
  }

  AFRouteState _setParamInHierOrPool(AFScreenID screen, AFRouteLocation route, AFRouteSegment revised) {
    if(route == AFRouteLocation.globalPool) {
      return setGlobalPoolParam(screen, revised);
    } else {
      return _reviseScreen(screenHierarchy.updateRouteSegment(screen, revised));    
    }
  }

  AFRouteSegment? _findParamInHierOrPool(AFScreenID screen, AFRouteLocation route) {
    if(route == AFRouteLocation.globalPool) {
      return globalPool[screen];
    } else { 
      return screenHierarchy.findSegmentFor(screen, includePrior: true);
    }
  }

  /// Replaces the data on the current leaf element without changing the segments
  /// in the route.
  AFRouteState setGlobalPoolParam(AFID screen, AFRouteSegment revisedSeg) {
    final revised = Map<AFID, AFRouteSegment>.from(globalPool);
    revised[screen] = revisedSeg;
    return copyWith(globalPool: revised);
  }


  /// Removes all existing segments in the route, and adds back the specified screen/data.
  AFRouteState replaceAll(AFRouteParam param, List<AFRouteParam>? children, AFCreateDefaultChildParamDelegate? createDefaultChildParam) {
    return _reviseScreen(screenHierarchy.replaceAll(param, children, createDefaultChildParam));
  }

  //---------------------------------------------------------------------------------------
  AFRouteState _reviseScreen(AFRouteStateSegments screenSegs) {
    return copyWith(screenSegs: screenSegs);
  }

  //---------------------------------------------------------------------------------------
  AFRouteState copyWith({
    AFRouteStateSegments? screenSegs,
    AFRouteStateSegments? popupSegs,
    Map<AFID, AFRouteSegment>? globalPool,
    AFTimeState? timeLastUpdate,
    Map<AFUIType,  AFRouteStateShowScreen>? showScreen,
  }) {
    var gp = globalPool ?? this.globalPool;
    if(!gp.containsKey(AFUIScreenID.unused)) {
      gp = Map<AFID, AFRouteSegment>.from(gp);
      gp[AFUIScreenID.unused] = AFRouteSegment(param: AFRouteParamUnused.unused, children: null, createDefaultChildParam: null);
    }

    final revised = AFRouteState(
      screenHierarchy: screenSegs ?? this.screenHierarchy,
      globalPool: gp,
      timeLastUpdate: timeLastUpdate ?? this.timeLastUpdate,
      showingScreens: showScreen ?? this.showingScreens,
    );

    if(screenSegs != null) {
      AFibD.logRouteAF?.d("Revised Route $revised");
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


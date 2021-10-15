import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// Base class for action that manipulates the route (pushing, popping, replacing)
/// and determines which screen is showing, and what data is visible.
@immutable
class AFNavigateAction extends AFActionWithKey {
  final AFRouteParam param;
  final List<AFRouteParam>? children;

  AFNavigateAction({
    AFID? id,
    required this.param,
    required this.children,
  }): super(id: id);

  AFScreenID get screenId { return param.id as AFScreenID; }
}

/// The two different 'route' types in AFib.
enum AFNavigateRoute {
  /// The primary hierarchical route, as you push screens using [AFNavigatePushAction],
  /// this route gets longer/deeper.   As you pop them with [AFNavigatePopAction] it gets
  /// shorter/shallower.
  routeHierarchy,

  /// The global pool just a pool of route paramaters organized by screen id.  This is used
  /// for things like drawers that can be dragged onto the screen, dialogs and popups, and 
  /// third party widgets that want to maintain a global root parameter across many different
  /// screens.
  routeGlobalPool
}

/// Action that changes the data associated with the current screen, but 
/// does not change the screen itself.
class AFNavigateSetParamAction extends AFNavigateAction {
  final AFNavigateRoute route;
  AFNavigateSetParamAction({
    AFID? id, 
    required AFRouteParam param,
    required this.route,
    List<AFRouteParam>? children,
  }): super(id: id, param: param, children: children);
}


class AFNavigateActionWithReturn extends AFNavigateAction {
  final AFActionOnReturnDelegate? onReturn;
  AFNavigateActionWithReturn({
    AFID? id, 
    required AFRouteParam param, 
    this.onReturn,
    List<AFRouteParam>? children,
  }): super(id: id, param: param, children: children);

}

/// Action that replaces the current leaf screen with a new screen.
class AFNavigateReplaceAction extends AFNavigateAction {  
  AFNavigateReplaceAction({
    AFID? id, 
    required AFScreenID screen, 
    required AFRouteParam param,
    List<AFRouteParam>? children,
  }): super(id: id, param: param, children: children);
}

/// Action that exits the current test screen in prototype mode.
class AFNavigateExitTestAction extends AFNavigateAction {  
  AFNavigateExitTestAction({AFID? id}): super(id: id, param: AFRouteParamUnused.unused, children: null);
}

/// Action that removes all screens in the route, and replaces them with
/// a single new screen at the root.
class AFNavigateReplaceAllAction extends AFNavigateAction {
  AFNavigateReplaceAllAction({
    AFID? id, 
    required AFRouteParam param,
    List<AFRouteParam>? children,
  }): super(id: id, param: param, children: children);

  //factory AFNavigateReplaceAllAction.toStartupScreen({required AFRouteParam param}) {
  //  return AFNavigateReplaceAllAction(screen: AFUIScreenID.screenStartupWrapper, param: param);
  //}
}

/// Action that adds a new screen after the current screen in the route.
/// 
/// Subsequently, [AFNavigatePopAction] will return you to the parent screen.
class AFNavigatePushAction extends AFNavigateActionWithReturn {
  AFNavigatePushAction({
    AFID? id, 
    required AFRouteParam routeParam, 
    List<AFRouteParam>? children,
    AFActionOnReturnDelegate? onReturn
  }): super(id: id, param: routeParam, children: children, onReturn: onReturn);

}

class AFNavigateActionWithReturnData extends AFNavigateAction {
  final dynamic returnData;

  /// This flag is used so that the standard back button can work in single
  /// screen test prototypes, but generally navigation does not
  final bool worksInSingleScreenTest;

  AFNavigateActionWithReturnData({
    AFID? id, 
    required this.returnData, 
    this.worksInSingleScreenTest = false,
    List<AFRouteParam>? children,
  }): super(id: id, param: AFRouteParamUnused.unused, children: children);
}

/// Action that navigates on screen up in the route, discarding the current leaf route.
/// 
/// Important: If you want to navigate up several screens, use [AFNavigatePopNAction] or [AFNavigatePopToAction]
/// rather than dispatching this action multiple times.  Failing to do so can cause cases where 
/// your [AFRouteParam] is null in widgets that are transitioning/animating off the screen.
/// 
/// If you want to test for the presence of a pop action in response to an event in 
/// prototype mode, you can make [worksInSingleScreenTest] false.   By default, pop actions
/// navigate you out of a prototype screen in test mode.
class AFNavigatePopAction extends AFNavigateActionWithReturnData {
  
  AFNavigatePopAction({
    AFID? id, 
    dynamic returnData, 
    bool worksInSingleScreenTest = false
  }): super(id: id, returnData: returnData, worksInSingleScreenTest: worksInSingleScreenTest);
}

/// Pops [popCount] screens off the navigation stack.
class AFNavigatePopNAction extends AFNavigateActionWithReturnData {
  final int popCount;

  AFNavigatePopNAction({
    required this.popCount,
    AFID? id, 
    dynamic returnData, 
    bool worksInPrototypeMode = true
    }): super(
      id: id,
      returnData: returnData,
      worksInSingleScreenTest: worksInPrototypeMode
    );
}

class AFNavigatePopToAction extends AFNavigateActionWithReturnData {
  final AFScreenID popTo;
  final AFNavigatePushAction? push;

  AFNavigatePopToAction({
    required this.popTo,
    this.push,
    AFID? id, 
    dynamic returnData, 
    bool worksInPrototypeMode = true
  }): super(
    id: id,
    returnData: returnData,
    worksInSingleScreenTest: worksInPrototypeMode
  );
}


class AFNavigateAddChildParamAction extends AFNavigateAction {
  final AFScreenID screen;
  final AFNavigateRoute route;
  AFNavigateAddChildParamAction({
    AFID? id, 
    required this.screen, 
    required AFRouteParam param, 
    required this.route,
  }): super(id: id, param: param, children: null); 
}

class AFNavigateRemoveChildParamAction extends AFNavigateAction {
  final AFScreenID screen;
  final AFID widget;
  final AFNavigateRoute route;
  AFNavigateRemoveChildParamAction({
    AFID? id, 
    required this.screen, 
    required this.widget,
    required this.route,
  }): super(id: id, param: AFRouteParamUnused.unused, children: null); 
}

class AFNavigateSetChildParamAction extends AFNavigateAction {
  final AFScreenID screen;
  final AFNavigateRoute route;
  final bool useParentParam;
  AFNavigateSetChildParamAction({
    AFID? id, 
    required this.screen, 
    required this.route,
    required AFRouteParam param,
    required this.useParentParam,
  }): super(id: id, param: param, children: null); 
}

class AFNavigateWireframeAction {
  final AFScreenID screen;
  final AFID widget;
  final dynamic eventParam;

  AFNavigateWireframeAction({
    required this.screen,
    required this.widget,
    this.eventParam,
  });
}


import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/redux/actions/af_async_query.dart';
import 'package:afib/src/dart/redux/state/models/af_route_state.dart';
import 'package:afib/src/dart/redux/state/models/af_time_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/utils/af_api_mixins.dart';
import 'package:flutter/widgets.dart';

/// Base class for action that manipulates the route (pushing, popping, replacing)
/// and determines which screen is showing, and what data is visible.
@immutable
class AFNavigateAction extends AFActionWithKey implements AFExecuteBeforeInterface, AFExecuteDuringInterface {
  final AFRouteParam param;
  final List<AFRouteParam>? children;
  final AFAsyncQuery? executeBefore;
  final AFAsyncQuery? executeDuring;
  final AFConnectedUIConfig? uiConfig;
  final RouteTransitionsBuilder? transitionsBuilder;

  AFNavigateAction({
    AFID? id,
    required this.param,
    required this.children,
    required this.executeBefore,
    required this.executeDuring,
    required this.transitionsBuilder,
    this.uiConfig,
    
  }): super(id: id);

  AFScreenID get screenId { return param.screenId; }
}

/// Action that changes the data associated with the current screen, but 
/// does not change the screen itself.
class AFNavigateSetParamAction extends AFNavigateAction {
  AFNavigateSetParamAction({
    AFID? id, 
    required AFRouteParam param,
    List<AFRouteParam>? children,
    AFConnectedUIConfig? uiConfig,
  }): super(
    id: id, 
    param: param, 
    children: children, 
    executeBefore: null, 
    executeDuring: null,
    uiConfig: uiConfig,
    transitionsBuilder: null,
  );
}

class AFNavigateActionWithReturn extends AFNavigateAction {
  final AFActionOnReturnDelegate? onReturn;
  final AFCreateDefaultChildParamDelegate? createDefaultChildParam;
  AFNavigateActionWithReturn({
    AFID? id, 
    required AFRouteParam param, 
    this.onReturn,
    List<AFRouteParam>? children,
    this.createDefaultChildParam,
    AFAsyncQuery? executeBefore,
    AFAsyncQuery? executeDuring,
    AFConnectedUIConfig? uiConfig,
    RouteTransitionsBuilder? transitionsBuilder,
  }): super(
    id: id, 
    param: param, 
    children: children, 
    executeBefore: executeBefore, 
    executeDuring: executeDuring,
    uiConfig: uiConfig,
    transitionsBuilder: transitionsBuilder
    );
}

/// Action that replaces the current leaf screen with a new screen.
class AFNavigateReplaceAction extends AFNavigateAction {  
  final AFCreateDefaultChildParamDelegate? createDefaultChildParam;
  AFNavigateReplaceAction({
    AFID? id, 
    required AFRouteParam param,
    List<AFRouteParam>? children,
    this.createDefaultChildParam,
    AFAsyncQuery? executeBefore,
    AFAsyncQuery? executeDuring,
    RouteTransitionsBuilder? transitionsBuilder,
  }): super(
    id: id, 
    param: param, 
    children: children, 
    executeBefore: executeBefore, 
    executeDuring: executeDuring,
    transitionsBuilder: transitionsBuilder,
  );
}

/// Action that exits the current test screen in prototype mode.
class AFNavigateExitTestAction extends AFNavigateAction {  
  AFNavigateExitTestAction({AFID? id}): super(
    id: id, 
    param: AFRouteParamUnused.unused, 
    children: null, 
    executeBefore: null, 
    executeDuring: null,
    transitionsBuilder: null,
  );
}

class AFNavigateSyncNavigatorStateWithRoute extends AFNavigateAction {
  final AFRouteState route;
  AFNavigateSyncNavigatorStateWithRoute(this.route, {AFID? id}): super(
    id: id, 
    param: AFRouteParamUnused.unused, 
    children: null, 
    executeBefore: null, 
    executeDuring: null,
    transitionsBuilder: null,
  );
}

/// Action that removes all screens in the route, and replaces them with
/// a single new screen at the root.
class AFNavigateReplaceAllAction extends AFNavigateAction {
  final AFCreateDefaultChildParamDelegate? createDefaultChildParam;
  AFNavigateReplaceAllAction({
    AFID? id, 
    required AFRouteParam param,
    List<AFRouteParam>? children,
    this.createDefaultChildParam,
    AFAsyncQuery? executeBefore,
    AFAsyncQuery? executeDuring,
    RouteTransitionsBuilder? transitionsBuilder,
  }): super(
    id: id, 
    param: param, 
    children: children, 
    executeBefore: executeBefore, 
    executeDuring: executeDuring,
    transitionsBuilder: transitionsBuilder
  );

  factory AFNavigateReplaceAllAction.toStartupScreen({required AFRouteParam param}) {
    return AFNavigateReplaceAllAction(param: param);
  }

  AFNavigatePushAction castToPush() {
    return AFNavigatePushAction(
      id: id,
      param: param,
      children: children,
      createDefaultChildParam: createDefaultChildParam,
      executeBefore: executeBefore,
      executeDuring: executeDuring,
      transitionsBuilder: transitionsBuilder,
    );
  }
}

/// Action that adds a new screen after the current screen in the route.
/// 
/// Subsequently, [AFNavigatePopAction] will return you to the parent screen.
class AFNavigatePushAction extends AFNavigateActionWithReturn {
  AFNavigatePushAction({
    AFID? id, 
    required AFRouteParam param, 
    List<AFRouteParam>? children,
    AFActionOnReturnDelegate? onReturn,
    AFCreateDefaultChildParamDelegate? createDefaultChildParam,
    AFAsyncQuery? executeBefore,
    AFAsyncQuery? executeDuring,
    AFConnectedUIConfig? uiConfig,
    RouteTransitionsBuilder? transitionsBuilder,
  }): super(
    id: id, 
    param: param, 
    children: children, 
    onReturn: onReturn, 
    createDefaultChildParam: createDefaultChildParam, 
    executeBefore: executeBefore, 
    executeDuring: executeDuring,
    uiConfig: uiConfig,
    transitionsBuilder: transitionsBuilder,
  );

  AFNavigateReplaceAllAction castToReplaceAll() {
    return AFNavigateReplaceAllAction(
      id: id,
      param: param,
      children: children,
      createDefaultChildParam: this.createDefaultChildParam,
      executeBefore: executeBefore,
      executeDuring: executeDuring,
      transitionsBuilder: transitionsBuilder,
    );
  }

  AFNavigatePopToAction castToPopToThenPush({
    required AFScreenID popTo,
  }) {
    return AFNavigatePopToAction(
      id: id,
      popTo: popTo,
      push: this,
    );
  }

  AFNavigateReplaceAction castToReplace() {
    return AFNavigateReplaceAction(
      id: id,
      param: param,
      children: children,
      createDefaultChildParam: this.createDefaultChildParam,
      executeBefore: executeBefore,
      executeDuring: executeDuring,
      transitionsBuilder: transitionsBuilder,
    );
  }

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
    AFAsyncQuery? executeBefore,
    AFAsyncQuery? executeDuring,
    RouteTransitionsBuilder? transitionsBuilder,
  }): super(
    id: id, 
    param: AFRouteParamUnused.unused, 
    children: children, 
    executeBefore: executeBefore, 
    executeDuring: executeDuring,
    transitionsBuilder: transitionsBuilder,
  );
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
  AFNavigateAddChildParamAction({
    AFID? id, 
    required AFRouteParam param, 
  }): super(id: id, param: param, children: null, executeBefore: null, executeDuring: null, transitionsBuilder: null);
}

class AFNavigateRemoveChildParamAction extends AFNavigateAction {
  final AFScreenID screen;
  final AFID widget;
  final AFRouteLocation route;
  AFNavigateRemoveChildParamAction({
    AFID? id, 
    required this.screen, 
    required this.widget,
    required this.route,
  }): super(id: id, param: AFRouteParamUnused.unused, children: null, executeBefore: null, executeDuring: null, transitionsBuilder: null); 
}

class AFNavigateShowScreenBeginAction extends AFNavigateAction {
    final AFScreenID screen;
    final AFUIType uiType; 
    AFNavigateShowScreenBeginAction(
      this.screen, 
      this.uiType,
      AFAsyncQuery? executeBefore,
      AFAsyncQuery? executeDuring,
    ): super(
      children: null, param: AFRouteParamUnused.unused, executeBefore: executeBefore, executeDuring: executeDuring, transitionsBuilder: null);
}

class AFNavigateShowScreenEndAction extends AFNavigateAction {
    final AFScreenID screen;
    AFNavigateShowScreenEndAction(this.screen): super(
      children: null, param: AFRouteParamUnused.unused, executeBefore: null, executeDuring: null, transitionsBuilder: null);
}

class AFUpdateTimeRouteParametersAction {
  final AFTimeState now;
  AFUpdateTimeRouteParametersAction(this.now);
}

class AFWireframeEventAction {
  final AFStateProgrammingInterface spi;
  final AFScreenID screen;
  final AFID widget;
  final dynamic eventParam;

  AFWireframeEventAction({
    required this.spi,
    required this.screen,
    required this.widget,
    this.eventParam,
  });
}


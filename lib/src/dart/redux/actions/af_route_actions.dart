import 'package:afib/afib_command.dart';
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/flutter/utils/af_api_mixins.dart';
import 'package:flutter/widgets.dart';

/// Base class for action that manipulates the route (pushing, popping, replacing)
/// and determines which screen is showing, and what data is visible.
@immutable
class AFNavigateAction extends AFActionWithKey implements AFExecuteBeforeInterface, AFExecuteDuringInterface {
  final AFRouteParam param;
  final List<AFRouteParam>? children;
  @override
  final AFAsyncQuery? executeBefore;
  @override
  final AFAsyncQuery? executeDuring;
  final RouteTransitionsBuilder? transitionsBuilder;

  AFNavigateAction({
    super.id,
    required this.param,
    required this.children,
    required this.executeBefore,
    required this.executeDuring,
    required this.transitionsBuilder,    
  });

  AFScreenID get screenId { return param.screenId; }
}

/// Action that changes the data associated with the current screen, but 
/// does not change the screen itself.
class AFNavigateSetParamAction extends AFNavigateAction {
  final AFCreateDefaultChildParamDelegate? createDefaultChildParam;
  AFNavigateSetParamAction({
    super.id, 
    required super.param,
    super.children,
    this.createDefaultChildParam,
  }): super(
    executeBefore: null, 
    executeDuring: null,
    transitionsBuilder: null,
  );
}

class AFNavigateActionWithReturn extends AFNavigateAction {
  final AFActionOnReturnDelegate? onReturn;
  final AFCreateDefaultChildParamDelegate? createDefaultChildParam;
  AFNavigateActionWithReturn({
    super.id, 
    required super.param, 
    this.onReturn,
    super.children,
    this.createDefaultChildParam,
    super.executeBefore,
    super.executeDuring,
    super.transitionsBuilder,
  });
}

/// Action that replaces the current leaf screen with a new screen.
class AFNavigateReplaceAction extends AFNavigateAction {  
  final AFCreateDefaultChildParamDelegate? createDefaultChildParam;
  AFNavigateReplaceAction({
    super.id, 
    required AFRouteParam launchParam,
    super.children,
    this.createDefaultChildParam,
    super.executeBefore,
    super.executeDuring,
    super.transitionsBuilder,
  }): super(
    param: launchParam,
  );
}

/// Action that exits the current test screen in prototype mode.
class AFNavigateExitTestAction extends AFNavigateAction {  
  AFNavigateExitTestAction({super.id}): super(
    param: AFRouteParamUnused.unused, 
    children: null, 
    executeBefore: null, 
    executeDuring: null,
    transitionsBuilder: null,
  );
}

class AFNavigateSyncNavigatorStateWithRoute extends AFNavigateAction {
  final AFRouteState route;
  AFNavigateSyncNavigatorStateWithRoute(this.route, {super.id}): super(
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
    super.id, 
    required AFRouteParam launchParam,
    super.children,
    this.createDefaultChildParam,
    super.executeBefore,
    super.executeDuring,
    super.transitionsBuilder,
  }): super(
    param: launchParam
  );

  factory AFNavigateReplaceAllAction.toStartupScreen({required AFRouteParam param}) {
    return AFNavigateReplaceAllAction(launchParam: param);
  }

  AFNavigatePushAction castToPush() {
    return AFNavigatePushAction(
      id: id,
      launchParam: param,
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
    super.id, 
    required AFRouteParam launchParam, 
    super.children,
    super.onReturn,
    super.createDefaultChildParam,
    super.executeBefore,
    super.executeDuring,
    super.transitionsBuilder,
  }): super(
    param: launchParam,
  );

  AFNavigateReplaceAllAction castToReplaceAll() {
    return AFNavigateReplaceAllAction(
      id: id,
      launchParam: param,
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
      launchParam: param,
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
    super.id, 
    required this.returnData, 
    this.worksInSingleScreenTest = false,
    super.children,
    super.executeBefore,
    super.executeDuring,
    super.transitionsBuilder,
  }): super(
    param: AFRouteParamUnused.unused,
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
    super.id, 
    super.returnData, 
    super.worksInSingleScreenTest
  });

}

/// Pops [popCount] screens off the navigation stack.
class AFNavigatePopNAction extends AFNavigateActionWithReturnData {
  final int popCount;

  AFNavigatePopNAction({
    required this.popCount,
    super.id, 
    super.returnData, 
    bool worksInPrototypeMode = true
    }): super(
      worksInSingleScreenTest: worksInPrototypeMode
    );
}

class AFNavigatePopToAction extends AFNavigateActionWithReturnData {
  final AFScreenID popTo;
  final AFNavigatePushAction? push;

  AFNavigatePopToAction({
    required this.popTo,
    this.push,
    super.id, 
    super.returnData, 
    bool worksInPrototypeMode = true
  }): super(
    worksInSingleScreenTest: worksInPrototypeMode
  );

  @override
  AFAsyncQuery? get executeBefore {
    final pushAction = push?.executeBefore;
    final actionAbove = super.executeBefore;
    assert(pushAction == null || actionAbove == null);
    return pushAction ?? actionAbove;
  }

}

class AFNavigateAddChildParamAction extends AFNavigateAction {
  AFNavigateAddChildParamAction({
    super.id, 
    required super.param, 
  }): super(children: null, executeBefore: null, executeDuring: null, transitionsBuilder: null);
}

class AFNavigateRemoveChildParamAction extends AFNavigateAction {
  final AFScreenID screen;
  final AFID widget;
  final AFRouteLocation route;
  AFNavigateRemoveChildParamAction({
    super.id, 
    required this.screen, 
    required this.widget,
    required this.route,
  }): super(param: AFRouteParamUnused.unused, children: null, executeBefore: null, executeDuring: null, transitionsBuilder: null); 
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
  final AFScreenID screen;
  final AFID widget;
  final dynamic eventParam;
  final AFFlexibleStateView? stateView;
  final AFPressedDelegate? onSuccess;

  AFWireframeEventAction({
    required this.screen,
    required this.widget,
    required this.stateView,
    required this.onSuccess,
    this.eventParam,
    
  });
}


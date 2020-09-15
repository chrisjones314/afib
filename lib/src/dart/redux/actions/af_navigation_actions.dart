import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/utils/af_bottom_popup_theme.dart';
import 'package:afib/src/flutter/utils/af_custom_popup_route.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

typedef void AFReturnFunc(dynamic returnData);

/// Base class for action that manipulates the route (pushing, popping, replacing)
/// and determines which screen is showing, and what data is visible.
@immutable
class AFNavigateAction extends AFActionWithKey {
  final AFID screen;
  final AFRouteParam param;

  AFNavigateAction({
    @required AFID id,
    @required this.screen,
    this.param
  }): super(id: id);
}

class AFNavigateActionWithReturn extends AFNavigateAction {
  final AFReturnFunc onReturn;
  AFNavigateActionWithReturn({AFID id, AFScreenID screen, AFRouteParam param, this.onReturn}): super(id: id, screen: screen, param: param);

}

/// Action that replaces the current leaf screen with a new screen.
class AFNavigateReplaceAction extends AFNavigateAction {  
  AFNavigateReplaceAction({AFID id, AFScreenID screen, AFRouteParam param}): super(id: id, screen: screen, param: param);
}

/// Action that exits the current test screen in prototype mode.
class AFNavigateExitTestAction extends AFNavigateAction {  
  AFNavigateExitTestAction({AFID id}): super(id: id, screen: null, param: null);
}

/// Action that removes all screens in the route, and replaces them with
/// a single new screen at the root.
class AFNavigateReplaceAllAction extends AFNavigateAction {
  AFNavigateReplaceAllAction({AFID id, AFScreenID screen, AFRouteParam param}): super(id: id, screen: screen, param: param);
}

/// Action that changes the data associated with the current screen, but 
/// does not change the screen itself.
class AFNavigateSetParamAction extends AFNavigateAction {
  AFNavigateSetParamAction({AFID id, AFScreenID screen, AFRouteParam param}): super(id: id, screen: screen, param: param);
}

/// Action that adds a new screen after the current screen in the route.
/// 
/// Subsequently, [AFNavigatePopAction] will return you to the parent screen.
class AFNavigatePushAction extends AFNavigateActionWithReturn {
  AFNavigatePushAction({AFID id, AFScreenID screen, AFRouteParam param, AFReturnFunc onReturn}): super(id: id, screen: screen, param: param, onReturn: onReturn);
}

/// Pushes a popup with a custom route.
class AFNavigatePushPopupAction extends AFNavigateActionWithReturn {
  final BuildContext context;
  final AFBottomPopupTheme theme;
  final AFRouteWidgetBuilder popupBuilder;
  
  AFNavigatePushPopupAction({
    AFID id, 
    @required this.context,
    @required AFScreenID screen, 
    @required AFRouteParam param,
    AFReturnFunc onReturn,
    @required this.theme,
    @required this.popupBuilder}): super(id: id, screen: screen, param: param, onReturn: onReturn);
}


/// Action that navigates on screen up in the route, discarding the current leaf route.
/// 
/// Important: If you want to navigate up several screens, use [AFNavigatePopNAction] or [AFNavigatePopToAction]
/// rather than dispatching this action multiple times.  Failing to do so can cause cases where 
/// your [AFRouteParam] is null in widgets that are transitioning/animating off the screen.
/// 
/// If you want to test for the presence of a pop action in response to an event in 
/// prototype mode, you can make [worksInPrototypeMode] false.   By default, pop actions
/// navigate you out of a prototype screen in test mode.
class AFNavigatePopAction extends AFNavigateAction {
  final dynamic returnData;
  final bool worksInPrototypeMode;
  
  AFNavigatePopAction({AFID id, this.returnData, this.worksInPrototypeMode = true}): super(id: id, screen: null, param: null);
}

/// Pops [popCount] screens off the navigation stack.
class AFNavigatePopNAction extends AFNavigatePopAction {
  final int popCount;

  AFNavigatePopNAction({
    @required this.popCount,
    AFID id, 
    dynamic returnData, 
    bool worksInPrototypeMode = true
    }): super(
      id: id,
      returnData: returnData,
      worksInPrototypeMode: worksInPrototypeMode
    );
}

class AFNavigatePopToAction extends AFNavigatePopAction {
  final AFScreenID popTo;

  AFNavigatePopToAction({
    @required this.popTo,
    AFID id, 
    dynamic returnData, 
    bool worksInPrototypeMode = true
  }): super(
    id: id,
    returnData: returnData,
    worksInPrototypeMode: worksInPrototypeMode
  );
}

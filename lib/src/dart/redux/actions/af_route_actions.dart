import 'package:afib/src/dart/redux/actions/af_action_with_key.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';
import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/utils/af_bottom_popup_theme.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

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
    AFID id, 
    @required AFScreenID screen, 
    @required AFRouteParam param,
    @required this.route 
  }): super(id: id, screen: screen, param: param);
}


class AFNavigateActionWithReturn extends AFNavigateAction {
  final AFActionOnReturnDelegate onReturn;
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

  factory AFNavigateReplaceAllAction.toStartupScreen({AFRouteParam param}) {
    return AFNavigateReplaceAllAction(screen: AFUIScreenID.screenStartupWrapper, param: param);
  }
}

class AFNavigateSetPopupParamAction extends AFNavigateAction {
  AFNavigateSetPopupParamAction({AFID id, AFScreenID screen, AFRouteParam param}): super(id: id, screen: screen, param: param);
}

/// Action that adds a new screen after the current screen in the route.
/// 
/// Subsequently, [AFNavigatePopAction] will return you to the parent screen.
class AFNavigatePushAction extends AFNavigateActionWithReturn {
  AFNavigatePushAction({
    AFID id, 
    @required AFScreenID screen, 
    @required AFRouteParam param, 
    AFActionOnReturnDelegate onReturn
  }): super(id: id, screen: screen, param: param, onReturn: onReturn);
}

/// Pushes a popup with a custom route.
class AFNavigatePushPopupAction extends AFNavigateActionWithReturn {
  final BuildContext context;
  final AFBottomPopupTheme theme;
  final AFPopupRouteWidgetBuilderDelegate popupBuilder;
  final String barrierLabel;
  
  AFNavigatePushPopupAction({
    AFID id, 
    @required this.context,
    @required AFScreenID screen, 
    AFRouteParam param,
    AFActionOnReturnDelegate onReturn,
    this.barrierLabel,
    @required this.theme,
    @required this.popupBuilder}): super(id: id, screen: screen, param: param, onReturn: onReturn);
}

class AFNavigatePopFromFlutterAction extends AFNavigateAction {
  AFNavigatePopFromFlutterAction({AFID id}): super(id:id, screen:null, param: null);
}

class AFNavigateActionWithReturnData extends AFNavigateAction {
  final dynamic returnData;
  final bool worksInPrototypeMode;

  AFNavigateActionWithReturnData({AFID id, this.returnData, this.worksInPrototypeMode = true}): super(id: id, screen: null, param: null);
}

/// Used when you only want to call Navigator.pop(context), without updating the 
/// internal route state.   
/// 
/// Note that this should be called instead of calling Navigator.pop(context directly),
/// because in that case we will catch it and pop the internal route state.
class AFNavigatePopNavigatorOnlyAction extends AFNavigateAction {
  AFNavigatePopNavigatorOnlyAction({AFID id}): super(id: id, screen: null, param: null);
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
class AFNavigatePopAction extends AFNavigateActionWithReturnData {
  
  AFNavigatePopAction({AFID id, dynamic returnData, bool worksInPrototypeMode = true}): super(id: id, returnData: returnData, worksInPrototypeMode: worksInPrototypeMode);
}

/// Used to close a popup screen
class AFNavigatePopPopupAction extends AFNavigateActionWithReturnData {
  final BuildContext context;
  AFNavigatePopPopupAction(this.context, {AFID id, dynamic returnData}): super(id: id, returnData: returnData);
}


/// Pops [popCount] screens off the navigation stack.
class AFNavigatePopNAction extends AFNavigateActionWithReturnData {
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

class AFNavigatePopToAction extends AFNavigateActionWithReturnData {
  final AFScreenID popTo;
  final AFNavigatePushAction push;

  AFNavigatePopToAction({
    @required this.popTo,
    this.push,
    AFID id, 
    dynamic returnData, 
    bool worksInPrototypeMode = true
  }): super(
    id: id,
    returnData: returnData,
    worksInPrototypeMode: worksInPrototypeMode
  );
}

class AFNavigateAddConnectedChildAction extends AFNavigateAction {
  final AFWidgetID widget;
  AFNavigateAddConnectedChildAction({
    AFID id, 
    @required AFScreenID screen, 
    @required AFRouteParam param, 
    @required this.widget,
  }): super(id: id, screen: screen, param: param); 
}

class AFNavigateRemoveConnectedChildAction extends AFNavigateAction {
  final AFWidgetID widget;
  AFNavigateRemoveConnectedChildAction({
    AFID id, 
    @required AFScreenID screen, 
    @required this.widget,
  }): super(id: id, screen: screen, param: null); 
}

class AFNavigateSortConnectedChildrenAction extends AFNavigateAction {
  final AFTypedSortDelegate sort;
  final Type typeToSort;
  AFNavigateSortConnectedChildrenAction({
    AFID id, 
    @required AFScreenID screen, 
    @required this.sort,
    @required this.typeToSort,
  }): super(id: id, screen: screen, param: null); 
}

class AFNavigateSetChildParamAction extends AFNavigateAction {
  final AFID widget;
  AFNavigateSetChildParamAction({
    AFID id, 
    @required AFScreenID screen, 
    @required this.widget,
    @required AFRouteParam param,
  }): super(id: id, screen: screen, param: param); 
}
